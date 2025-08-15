import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/message_model.dart';
import '../../data/models/swap_item_model.dart';
import '../../data/models/store_item_model.dart';
import '../../services/cloud_messaging_service.dart';

class ChatController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudMessagingService _cloudMessagingService =
      CloudMessagingService.instance;

  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxList<ChatModel> filteredChats = <ChatModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString searchQuery = ''.obs;

  // Para rastrear el chat actualmente visible
  String? _currentVisibleChatId;
  bool _isAppInForeground = true;

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    // El CloudMessagingService maneja la inicialización de notificaciones
    if (currentUserId != null) {
      loadUserChats();
    }

    // Inicializar filteredChats con todos los chats
    ever(chats, (List<ChatModel> chatList) {
      if (searchQuery.value.isEmpty) {
        filteredChats.value = chatList;
      } else {
        searchChats(searchQuery.value);
      }
    });
  }

  // Métodos para controlar el estado de notificaciones
  void setCurrentVisibleChat(String? chatId) {
    _currentVisibleChatId = chatId;
  }

  void setAppForegroundState(bool isInForeground) {
    _isAppInForeground = isInForeground;
  }

  bool shouldSendPushNotification(String chatId) {
    // No enviar notificación si:
    // 1. La app está en primer plano Y
    // 2. El usuario está viendo este chat específico
    return !(_isAppInForeground && _currentVisibleChatId == chatId);
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
    for (final ChatModel chat in chats) {
      if (chat.isExpired && chat.status == ChatStatus.active) {
        try {
          await _firestore.collection('chats').doc(chat.id).update({
            'status': ChatStatus.expired.name,
          });
        } catch (e) {
          debugPrint('Error actualizando chat expirado ${chat.id}: $e');
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
      await _cloudMessagingService.sendNotificationToUser(
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

  Future<String?> createChatForStoreItem({
    required StoreItemModel storeItem,
    required String interestedUserId,
  }) async {
    if (currentUserId == null) return null;

    try {
      // Primero, necesitamos obtener el dueño de la tienda
      final DocumentSnapshot storeDoc = await _firestore
          .collection('stores')
          .doc(storeItem.storeId)
          .get();

      if (!storeDoc.exists) {
        error.value = 'La tienda no existe';
        return null;
      }

      final Map<String, dynamic> storeData =
          storeDoc.data() as Map<String, dynamic>;
      final String storeOwnerId = storeData['ownerId'] as String;

      // Verificar si ya existe un chat para este item de tienda
      final QuerySnapshot existingChat = await _firestore
          .collection('chats')
          .where('storeItemId', isEqualTo: storeItem.id)
          .where('interestedUserId', isEqualTo: interestedUserId)
          .where('storeOwnerId', isEqualTo: storeOwnerId)
          .limit(1)
          .get();

      if (existingChat.docs.isNotEmpty) {
        final ChatModel chat = ChatModel.fromFirestore(existingChat.docs.first);
        if (!chat.isExpired) {
          return chat.id; // Retornar chat existente si no ha expirado
        }
      }

      // Crear nuevo chat para item de tienda
      final DateTime now = DateTime.now();
      final DateTime expiresAt = now.add(const Duration(days: 7));

      final Map<String, dynamic> chatData = {
        'storeItemId': storeItem.id,
        'storeOwnerId': storeOwnerId,
        'interestedUserId': interestedUserId,
        'storeItemName': storeItem.name,
        'storeItemImageUrl': storeItem.imageUrl,
        'storeItemPrice': storeItem.price,
        'participants': [storeOwnerId, interestedUserId],
        'createdAt': Timestamp.fromDate(now),
        'lastMessageAt': Timestamp.fromDate(now),
        'expiresAt': Timestamp.fromDate(expiresAt),
        'status': ChatStatus.active.name,
        'readBy': {storeOwnerId: true, interestedUserId: false},
        'hasUnreadMessages': false,
        'lastMessage': '',
        'chatType': 'store_item', // Diferenciar del chat de swap
      };

      final DocumentReference chatRef = await _firestore
          .collection('chats')
          .add(chatData);

      // Enviar mensaje inicial del sistema
      await sendSystemMessage(
        chatId: chatRef.id,
        content:
            'Chat iniciado para el intercambio del producto "${storeItem.name}" (Precio: \$${storeItem.price.toStringAsFixed(0)}). Este chat expira en 7 días.',
      );

      // Enviar notificación push al dueño de la tienda
      await _cloudMessagingService.sendNotificationToUser(
        userId: storeOwnerId,
        title: 'Nuevo interés en tu producto',
        body: 'Alguien está interesado en tu producto "${storeItem.name}"',
        data: {
          'type': 'new_store_chat',
          'chatId': chatRef.id,
          'storeItemId': storeItem.id,
        },
      );

      return chatRef.id;
    } catch (e) {
      error.value = 'Error creando chat para item de tienda: $e';
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

        // Enviar notificación push solo si es necesario
        if (shouldSendPushNotification(chatId)) {
          await _cloudMessagingService.sendNotificationToUser(
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
      debugPrint('Error enviando mensaje del sistema: $e');
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

        // Limpiar contadores de mensajes no leídos
        await _clearUnreadCounters(chatId);

        // Actualizar la lista local de chats
        _updateLocalChatReadStatus(chatId, newReadBy, hasUnreadMessages);
      }
    } catch (e) {
      debugPrint('Error marcando chat como leído: $e');
    }
  }

  /// Limpia los contadores de mensajes no leídos cuando se marca como leído
  Future<void> _clearUnreadCounters(String chatId) async {
    if (currentUserId == null) return;

    try {
      final WriteBatch batch = _firestore.batch();

      // Marcar este chat como leído (crear el documento si no existe)
      batch.set(
        _firestore
            .collection('users')
            .doc(currentUserId!)
            .collection('unread_chats')
            .doc(chatId),
        {'hasUnread': false, 'lastUpdate': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      // Verificar si el documento del usuario existe y crear/actualizar contador
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId!)
          .get();

      if (userDoc.exists) {
        // El documento existe, decrementar contador
        batch.update(_firestore.collection('users').doc(currentUserId!), {
          'unreadChatsCount': FieldValue.increment(-1),
          'lastUnreadUpdate': FieldValue.serverTimestamp(),
        });
      } else {
        // El documento no existe, crearlo con valores iniciales
        batch.set(
          _firestore.collection('users').doc(currentUserId!),
          {
            'unreadChatsCount': 0,
            'lastUnreadUpdate': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      }

      await batch.commit();

      // Actualizar badge count después de limpiar contadores
      await _cloudMessagingService.updateBadgeFromDatabase();

      debugPrint(
        'Contadores de mensajes no leídos limpiados para chat: $chatId',
      );
    } catch (e) {
      debugPrint('Error limpiando contadores no leídos: $e');
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
      debugPrint('Error verificando mensajes no leídos: $e');
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

  // Métodos de búsqueda
  void searchChats(String query) {
    searchQuery.value = query.toLowerCase().trim();

    if (searchQuery.value.isEmpty) {
      filteredChats.value = chats;
      return;
    }

    filteredChats.value = chats.where((chat) {
      // Buscar en el nombre del artículo
      final bool matchesItemName = chat.swapItemName.toLowerCase().contains(
        searchQuery.value,
      );

      // Buscar en el último mensaje
      final bool matchesLastMessage =
          chat.lastMessage != null &&
          chat.lastMessage!.toLowerCase().contains(searchQuery.value);

      return matchesItemName || matchesLastMessage;
    }).toList();
  }

  void clearSearch() {
    searchQuery.value = '';
    filteredChats.value = chats;
  }

  List<ChatModel> get displayedChats {
    return searchQuery.value.isEmpty ? chats : filteredChats;
  }

  Future<List<MessageModel>> searchMessagesInChat(
    String chatId,
    String query,
  ) async {
    if (query.trim().isEmpty) return [];

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .orderBy('createdAt', descending: true)
          .get();

      final List<MessageModel> allMessages = snapshot.docs
          .map((doc) => MessageModel.fromFirestore(doc))
          .toList();

      return allMessages.where((message) {
        return message.content.toLowerCase().contains(query.toLowerCase()) ||
            message.senderName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    } catch (e) {
      debugPrint('Error buscando mensajes: $e');
      return [];
    }
  }
}
