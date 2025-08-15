import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/swap_item_model.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    _initializePushNotifications();
    if (currentUserId != null) {
      loadUserChats();
    }
  }

  Future<void> _initializePushNotifications() async {
    try {
      // Solicitar permisos para notificaciones
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Usuario otorgó permisos para notificaciones');

        // Obtener token FCM
        String? token = await _messaging.getToken();
        if (token != null && currentUserId != null) {
          await _saveTokenToDatabase(token);
        }

        // Escuchar cambios de token
        _messaging.onTokenRefresh.listen(_saveTokenToDatabase);
      }
    } catch (e) {
      print('Error inicializando notificaciones push: $e');
    }
  }

  Future<void> _saveTokenToDatabase(String token) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'fcmToken': token,
      });
    } catch (e) {
      print('Error guardando token FCM: $e');
    }
  }

  void loadUserChats() {
    if (currentUserId == null) return;

    isLoading.value = true;
    error.value = '';

    _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessageAt', descending: true)
        .snapshots()
        .listen(
          (QuerySnapshot snapshot) {
            final List<ChatModel> loadedChats = snapshot.docs
                .map((doc) => ChatModel.fromFirestore(doc))
                .where(
                  (chat) =>
                      !chat.isExpired || chat.status != ChatStatus.expired,
                )
                .toList();

            chats.value = loadedChats;
            isLoading.value = false;

            // Actualizar chats expirados
            _updateExpiredChats(loadedChats);
          },
          onError: (e) {
            error.value = 'Error cargando chats: $e';
            isLoading.value = false;
          },
        );
  }

  Future<void> _updateExpiredChats(List<ChatModel> chats) async {
    final DateTime now = DateTime.now();

    for (final ChatModel chat in chats) {
      if (chat.isExpired && chat.status == ChatStatus.active) {
        try {
          await _firestore.collection('chats').doc(chat.id).update({
            'status': ChatStatus.expired.name,
          });
        } catch (e) {
          print('Error actualizando chat expirado ${chat.id}: $e');
        }
      }
    }
  }

  Future<String?> createChat({
    required SwapItemModel swapItem,
    required String interestedUserId,
  }) async {
    if (currentUserId == null) return null;

    try {
      // Verificar si ya existe un chat para este intercambio
      final QuerySnapshot existingChat = await _firestore
          .collection('chats')
          .where('swapItemId', isEqualTo: swapItem.id)
          .where('interestedUserId', isEqualTo: interestedUserId)
          .where('swapItemOwnerId', isEqualTo: swapItem.userId)
          .limit(1)
          .get();

      if (existingChat.docs.isNotEmpty) {
        final ChatModel chat = ChatModel.fromFirestore(existingChat.docs.first);
        if (!chat.isExpired) {
          return chat.id; // Retornar chat existente si no ha expirado
        }
      }

      // Crear nuevo chat
      final DateTime now = DateTime.now();
      final DateTime expiresAt = now.add(const Duration(days: 7));

      final ChatModel newChat = ChatModel(
        id: '',
        swapItemId: swapItem.id,
        swapItemOwnerId: swapItem.userId,
        interestedUserId: interestedUserId,
        swapItemName: swapItem.name,
        swapItemImageUrl: swapItem.imageUrl,
        createdAt: now,
        expiresAt: expiresAt,
        status: ChatStatus.active,
        readBy: {swapItem.userId: true, interestedUserId: false},
      );

      final DocumentReference chatRef = await _firestore
          .collection('chats')
          .add(
            newChat.toFirestore()..addAll({
              'participants': [swapItem.userId, interestedUserId],
            }),
          );

      // Enviar mensaje inicial del sistema
      await sendSystemMessage(
        chatId: chatRef.id,
        content:
            'Chat iniciado para el intercambio de "${swapItem.name}". Este chat expira en 7 días.',
      );

      // Enviar notificación push al dueño del artículo
      await _sendPushNotification(
        userId: swapItem.userId,
        title: 'Nuevo intercambio propuesto',
        body: 'Alguien está interesado en tu artículo "${swapItem.name}"',
        data: {
          'type': 'new_chat',
          'chatId': chatRef.id,
          'swapItemId': swapItem.id,
        },
      );

      return chatRef.id;
    } catch (e) {
      error.value = 'Error creando chat: $e';
      return null;
    }
  }

  Stream<List<MessageModel>> getChatMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MessageModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<bool> sendMessage({
    required String chatId,
    required String content,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    if (currentUserId == null || content.trim().isEmpty) return false;

    try {
      // Obtener información del usuario actual
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;
      final String userName = userData?['name'] ?? 'Usuario';
      final String? userPhotoUrl = userData?['photoUrl'];

      final MessageModel message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: currentUserId!,
        senderName: userName,
        senderPhotoUrl: userPhotoUrl,
        content: content,
        type: type,
        createdAt: DateTime.now(),
        metadata: metadata,
      );

      // Agregar mensaje a la colección
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toFirestore());

      // Obtener información del chat para actualizar correctamente los unread
      final DocumentSnapshot chatDoc = await _firestore
          .collection('chats')
          .doc(chatId)
          .get();

      if (chatDoc.exists) {
        final ChatModel chat = ChatModel.fromFirestore(chatDoc);
        final String otherUserId = chat.getOtherUserId(currentUserId!);

        // Actualizar último mensaje en el chat
        final Map<String, bool> newReadBy = Map<String, bool>.from(chat.readBy);
        newReadBy[currentUserId!] = true;
        newReadBy[otherUserId] =
            false; // El otro usuario tiene mensajes sin leer

        await _firestore.collection('chats').doc(chatId).update({
          'lastMessage': content,
          'lastMessageAt': Timestamp.fromDate(DateTime.now()),
          'hasUnreadMessages': true,
          'readBy': newReadBy,
        });

        // Enviar notificación push
        await _sendPushNotification(
          userId: otherUserId,
          title: userName,
          body: content,
          data: {
            'type': 'new_message',
            'chatId': chatId,
            'senderId': currentUserId!,
          },
        );
      }

      return true;
    } catch (e) {
      error.value = 'Error enviando mensaje: $e';
      return false;
    }
  }

  Future<bool> sendSystemMessage({
    required String chatId,
    required String content,
  }) async {
    try {
      final MessageModel message = MessageModel(
        id: '',
        chatId: chatId,
        senderId: 'system',
        senderName: 'Sistema',
        content: content,
        type: MessageType.system,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(message.toFirestore());

      return true;
    } catch (e) {
      print('Error enviando mensaje del sistema: $e');
      return false;
    }
  }

  Future<void> markChatAsRead(String chatId) async {
    if (currentUserId == null) return;

    try {
      // Obtener el chat actual
      final DocumentSnapshot chatDoc = await _firestore
          .collection('chats')
          .doc(chatId)
          .get();

      if (!chatDoc.exists) return;

      final ChatModel chat = ChatModel.fromFirestore(chatDoc);
      final String otherUserId = chat.getOtherUserId(currentUserId!);

      // Verificar si hay mensajes no leídos del otro usuario
      final QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: otherUserId)
          .where('isRead', isEqualTo: false)
          .get();

      if (unreadMessages.docs.isNotEmpty) {
        // Marcar mensajes como leídos
        final WriteBatch batch = _firestore.batch();
        for (final QueryDocumentSnapshot doc in unreadMessages.docs) {
          batch.update(doc.reference, {'isRead': true});
        }

        // Actualizar el estado del chat
        final Map<String, bool> newReadBy = Map<String, bool>.from(chat.readBy);
        newReadBy[currentUserId!] = true;

        // Verificar si ambos usuarios han leído todos los mensajes
        final bool hasUnreadMessages = await _hasUnreadMessages(chatId);

        batch.update(_firestore.collection('chats').doc(chatId), {
          'readBy': newReadBy,
          'hasUnreadMessages': hasUnreadMessages,
        });

        await batch.commit();

        // Actualizar la lista local de chats
        _updateLocalChatReadStatus(chatId, newReadBy, hasUnreadMessages);
      }
    } catch (e) {
      print('Error marcando chat como leído: $e');
    }
  }

  Future<bool> _hasUnreadMessages(String chatId) async {
    try {
      final QuerySnapshot unreadMessages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('isRead', isEqualTo: false)
          .limit(1)
          .get();

      return unreadMessages.docs.isNotEmpty;
    } catch (e) {
      print('Error verificando mensajes no leídos: $e');
      return false;
    }
  }

  void _updateLocalChatReadStatus(
    String chatId,
    Map<String, bool> readBy,
    bool hasUnreadMessages,
  ) {
    final int chatIndex = chats.indexWhere((chat) => chat.id == chatId);
    if (chatIndex != -1) {
      final ChatModel updatedChat = chats[chatIndex].copyWith(
        readBy: readBy,
        hasUnreadMessages: hasUnreadMessages,
      );
      chats[chatIndex] = updatedChat;
    }
  }

  Future<void> proposeSwap({
    required String chatId,
    required String proposalMessage,
  }) async {
    await sendMessage(
      chatId: chatId,
      content: proposalMessage,
      type: MessageType.swapProposal,
      metadata: {'timestamp': DateTime.now().millisecondsSinceEpoch},
    );
  }

  Future<void> respondToSwap({
    required String chatId,
    required bool accepted,
    String? responseMessage,
  }) async {
    final String content =
        responseMessage ??
        (accepted
            ? 'Propuesta de intercambio aceptada'
            : 'Propuesta de intercambio rechazada');

    await sendMessage(
      chatId: chatId,
      content: content,
      type: accepted ? MessageType.swapAccepted : MessageType.swapRejected,
    );

    // Actualizar estado del chat
    await _firestore.collection('chats').doc(chatId).update({
      'swapDecision': accepted
          ? SwapDecision.accepted.name
          : SwapDecision.rejected.name,
    });
  }

  Future<void> createAgreement({
    required String chatId,
    required String agreementDetails,
  }) async {
    await sendMessage(
      chatId: chatId,
      content: agreementDetails,
      type: MessageType.agreement,
    );

    // Actualizar estado del chat
    await _firestore.collection('chats').doc(chatId).update({
      'swapDecision': SwapDecision.agreement.name,
    });
  }

  Future<void> _sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Obtener token FCM del usuario
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;
      final String? fcmToken = userData?['fcmToken'];

      if (fcmToken == null) return;

      // Aquí normalmente usarías un servicio backend para enviar la notificación
      // Por ahora, solo registramos la intención
      print('Enviando notificación push a $userId: $title - $body');

      // En un entorno real, harías una llamada HTTP a tu backend
      // que use Firebase Admin SDK para enviar la notificación
    } catch (e) {
      print('Error enviando notificación push: $e');
    }
  }

  int getUnreadChatsCount() {
    if (currentUserId == null) return 0;

    return chats
        .where(
          (chat) =>
              chat.hasUnreadMessages &&
              (chat.readBy[currentUserId] != true) &&
              !chat.isExpired, // No contar chats expirados
        )
        .length;
  }

  int getUnreadMessagesCount(String chatId) {
    if (currentUserId == null) return 0;

    final ChatModel? chat = chats.firstWhereOrNull((c) => c.id == chatId);
    if (chat == null ||
        !chat.hasUnreadMessages ||
        chat.readBy[currentUserId] == true) {
      return 0;
    }

    // En una implementación real, podrías mantener un contador de mensajes no leídos
    // Por ahora, retornamos 1 si hay mensajes no leídos
    return 1;
  }

  bool hasUnreadMessages(String chatId) {
    if (currentUserId == null) return false;

    final ChatModel? chat = chats.firstWhereOrNull((c) => c.id == chatId);
    if (chat == null) return false;

    return chat.hasUnreadMessages && (chat.readBy[currentUserId] != true);
  }

  Future<void> deleteChat(String chatId) async {
    try {
      // Eliminar mensajes
      final QuerySnapshot messages = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .get();

      final WriteBatch batch = _firestore.batch();
      for (final QueryDocumentSnapshot doc in messages.docs) {
        batch.delete(doc.reference);
      }

      // Eliminar chat
      batch.delete(_firestore.collection('chats').doc(chatId));

      await batch.commit();
    } catch (e) {
      error.value = 'Error eliminando chat: $e';
    }
  }
}
