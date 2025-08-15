import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Servicio centralizado para manejo de Firebase Cloud Messaging
/// Permite envío de notificaciones individuales, masivas y por temas
class CloudMessagingService extends GetxService {
  static CloudMessagingService get instance => Get.put(CloudMessagingService());

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? _fcmToken;

  // Temas predefinidos para notificaciones masivas
  static const String allUsersTopicName = 'all_users';
  static const String newSwapsTopicName = 'new_swaps';
  static const String systemUpdatesTopicName = 'system_updates';

  String? get fcmToken => _fcmToken;
  String? get currentUserId => _auth.currentUser?.uid;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeCloudMessaging();
  }

  /// Inicializa el servicio de Cloud Messaging
  Future<void> _initializeCloudMessaging() async {
    try {
      // Solicitar permisos
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
        _fcmToken = await _messaging.getToken();
        if (_fcmToken != null && currentUserId != null) {
          await _saveTokenToDatabase(_fcmToken!);
          await _subscribeToDefaultTopics();
        }

        // Configurar manejadores de mensajes
        _setupMessageHandlers();

        // Escuchar cambios de token
        _messaging.onTokenRefresh.listen((String token) async {
          _fcmToken = token;
          print('Token FCM actualizado: $token');
          if (currentUserId != null) {
            await _saveTokenToDatabase(token);
          }
        });
      } else {
        print('Usuario denegó permisos para notificaciones');
      }
    } catch (e) {
      print('Error inicializando Cloud Messaging: $e');
    }
  }

  /// Configura los manejadores de mensajes
  void _setupMessageHandlers() {
    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Mensaje recibido en primer plano: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Manejar mensajes cuando la app está en segundo plano pero no terminada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Mensaje abrió la app desde segundo plano: ${message.messageId}');
      _handleMessageTap(message);
    });

    // Manejar mensajes cuando la app está completamente cerrada
    _handleInitialMessage();
  }

  /// Maneja mensajes cuando la app se abre desde estado cerrado
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print(
        'Mensaje abrió la app desde estado cerrado: ${initialMessage.messageId}',
      );
      _handleMessageTap(initialMessage);
    }
  }

  /// Maneja mensajes en primer plano
  void _handleForegroundMessage(RemoteMessage message) {
    final String? title = message.notification?.title;
    final String? body = message.notification?.body;

    // Solo mostrar snackbar si no estamos en el chat específico
    if (title != null &&
        body != null &&
        _shouldShowForegroundNotification(message)) {
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        onTap: (_) => _handleMessageTap(message),
      );
    }

    // Registrar la notificación recibida
    _logNotificationReceived(message);
  }

  /// Determina si debe mostrar notificación en primer plano
  bool _shouldShowForegroundNotification(RemoteMessage message) {
    // Lógica para determinar si mostrar notificación
    // Por ejemplo, no mostrar si estamos en el chat específico
    // Esta lógica se puede extender según necesidades
    return true;
  }

  /// Maneja cuando el usuario toca una notificación
  void _handleMessageTap(RemoteMessage message) {
    final String? type = message.data['type'];

    switch (type) {
      case 'new_chat':
        final String? chatId = message.data['chatId'];
        if (chatId != null) {
          _navigateToChat(chatId);
        }
        break;

      case 'new_message':
        final String? chatId = message.data['chatId'];
        if (chatId != null) {
          _navigateToChat(chatId);
        }
        break;

      case 'swap_proposal':
      case 'swap_response':
        final String? chatId = message.data['chatId'];
        if (chatId != null) {
          _navigateToChat(chatId);
        }
        break;

      case 'new_swap_item':
        final String? swapItemId = message.data['swapItemId'];
        if (swapItemId != null) {
          _navigateToSwapDetail(swapItemId);
        }
        break;

      case 'system_announcement':
        _navigateToHome();
        break;

      default:
        print('Tipo de notificación no manejado: $type');
        _navigateToHome();
    }

    // Registrar interacción con notificación
    _logNotificationInteraction(message);
  }

  /// Guarda el token FCM en la base de datos
  Future<void> _saveTokenToDatabase(String token) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('users').doc(currentUserId).update({
        'fcmToken': token,
        'lastTokenUpdate': FieldValue.serverTimestamp(),
        'platform': defaultTargetPlatform.name,
      });
      print('Token FCM guardado en base de datos');
    } catch (e) {
      print('Error guardando token FCM: $e');
    }
  }

  /// Suscribe a temas por defecto
  Future<void> _subscribeToDefaultTopics() async {
    try {
      await subscribeToTopic(allUsersTopicName);
      await subscribeToTopic(newSwapsTopicName);

      // Suscribir a temas específicos según preferencias del usuario
      await _subscribeToUserSpecificTopics();
    } catch (e) {
      print('Error suscribiendo a temas por defecto: $e');
    }
  }

  /// Suscribe a temas específicos del usuario
  Future<void> _subscribeToUserSpecificTopics() async {
    if (currentUserId == null) return;

    try {
      // Obtener preferencias del usuario
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        final Map<String, dynamic>? userData =
            userDoc.data() as Map<String, dynamic>?;

        // Suscribir basado en ubicación, intereses, etc.
        final String? city = userData?['city'];
        if (city != null) {
          await subscribeToTopic('city_$city');
        }

        final List<String>? interests = userData?['interests']?.cast<String>();
        if (interests != null) {
          for (String interest in interests) {
            await subscribeToTopic('interest_$interest');
          }
        }
      }
    } catch (e) {
      print('Error suscribiendo a temas específicos: $e');
    }
  }

  /// Suscribe a un tema específico
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      print('Suscrito al tema: $topic');

      // Registrar suscripción en base de datos
      await _logTopicSubscription(topic, true);
    } catch (e) {
      print('Error suscribiéndose al tema $topic: $e');
    }
  }

  /// Desuscribe de un tema específico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      print('Desuscrito del tema: $topic');

      // Registrar desuscripción en base de datos
      await _logTopicSubscription(topic, false);
    } catch (e) {
      print('Error desuscribiéndose del tema $topic: $e');
    }
  }

  /// Envía notificación a un usuario específico
  Future<bool> sendNotificationToUser({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      // Obtener token del usuario
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        print('Usuario no encontrado: $userId');
        return false;
      }

      final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;
      final String? userToken = userData?['fcmToken'];

      if (userToken == null) {
        print('Token FCM no encontrado para usuario: $userId');
        return false;
      }

      return await _sendNotificationWithToken(
        token: userToken,
        title: title,
        body: body,
        data: data,
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Error enviando notificación a usuario $userId: $e');
      return false;
    }
  }

  /// Envía notificación a un tema (grupo de usuarios)
  Future<bool> sendNotificationToTopic({
    required String topic,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      // Registrar envío en base de datos para analytics
      await _logNotificationSent(
        type: 'topic',
        target: topic,
        title: title,
        body: body,
        data: data,
      );

      // En un entorno real, esto se haría desde el backend
      print('Enviando notificación al tema: $topic');
      print('Título: $title');
      print('Cuerpo: $body');
      print('Data: $data');

      return true;
    } catch (e) {
      print('Error enviando notificación al tema $topic: $e');
      return false;
    }
  }

  /// Envía notificación a todos los usuarios activos
  Future<bool> sendNotificationToAllUsers({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    return await sendNotificationToTopic(
      topic: allUsersTopicName,
      title: title,
      body: body,
      data: data,
      imageUrl: imageUrl,
    );
  }

  /// Envía notificación con token específico
  Future<bool> _sendNotificationWithToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      // Registrar envío en base de datos
      await _logNotificationSent(
        type: 'individual',
        target: token,
        title: title,
        body: body,
        data: data,
      );

      // En un entorno real, esto se haría desde el backend usando Firebase Admin SDK
      print('Enviando notificación individual');
      print('Token: $token');
      print('Título: $title');
      print('Cuerpo: $body');
      print('Data: $data');

      return true;
    } catch (e) {
      print('Error enviando notificación individual: $e');
      return false;
    }
  }

  /// Registra suscripción/desuscripción a tema
  Future<void> _logTopicSubscription(String topic, bool subscribed) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('user_topic_subscriptions').add({
        'userId': currentUserId,
        'topic': topic,
        'subscribed': subscribed,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error registrando suscripción a tema: $e');
    }
  }

  /// Registra notificación enviada
  Future<void> _logNotificationSent({
    required String type,
    required String target,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _firestore.collection('notification_logs').add({
        'type': type,
        'target': target,
        'title': title,
        'body': body,
        'data': data ?? {},
        'sentBy': currentUserId,
        'sentAt': FieldValue.serverTimestamp(),
        'status': 'sent',
      });
    } catch (e) {
      print('Error registrando notificación enviada: $e');
    }
  }

  /// Registra notificación recibida
  Future<void> _logNotificationReceived(RemoteMessage message) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('notification_interactions').add({
        'userId': currentUserId,
        'messageId': message.messageId,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'action': 'received',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error registrando notificación recibida: $e');
    }
  }

  /// Registra interacción con notificación
  Future<void> _logNotificationInteraction(RemoteMessage message) async {
    if (currentUserId == null) return;

    try {
      await _firestore.collection('notification_interactions').add({
        'userId': currentUserId,
        'messageId': message.messageId,
        'title': message.notification?.title,
        'body': message.notification?.body,
        'data': message.data,
        'action': 'tapped',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error registrando interacción con notificación: $e');
    }
  }

  // Métodos de navegación
  void _navigateToChat(String chatId) {
    try {
      Get.toNamed('/chat', arguments: {'chatId': chatId});
    } catch (e) {
      print('Error navegando al chat: $e');
      Get.toNamed('/messages');
    }
  }

  void _navigateToSwapDetail(String swapItemId) {
    try {
      Get.toNamed('/swap-detail', arguments: {'swapItemId': swapItemId});
    } catch (e) {
      print('Error navegando al detalle de swap: $e');
      Get.toNamed('/home');
    }
  }

  void _navigateToHome() {
    try {
      Get.toNamed('/home');
    } catch (e) {
      print('Error navegando al home: $e');
    }
  }

  /// Obtiene estadísticas de notificaciones
  Future<Map<String, dynamic>> getNotificationStats() async {
    if (currentUserId == null) return {};

    try {
      // Obtener notificaciones enviadas
      final QuerySnapshot sentQuery = await _firestore
          .collection('notification_logs')
          .where('sentBy', isEqualTo: currentUserId)
          .get();

      // Obtener interacciones
      final QuerySnapshot interactionsQuery = await _firestore
          .collection('notification_interactions')
          .where('userId', isEqualTo: currentUserId)
          .get();

      return {
        'notificationsSent': sentQuery.docs.length,
        'notificationsReceived': interactionsQuery.docs
            .where(
              (doc) =>
                  (doc.data() as Map<String, dynamic>?)?['action'] ==
                  'received',
            )
            .length,
        'notificationsTapped': interactionsQuery.docs
            .where(
              (doc) =>
                  (doc.data() as Map<String, dynamic>?)?['action'] == 'tapped',
            )
            .length,
      };
    } catch (e) {
      print('Error obteniendo estadísticas de notificaciones: $e');
      return {};
    }
  }

  /// Limpia datos de notificaciones antiguos
  Future<void> cleanupOldNotificationData() async {
    try {
      final DateTime cutoffDate = DateTime.now().subtract(
        const Duration(days: 30),
      );

      // Eliminar logs antiguos
      final QuerySnapshot oldLogs = await _firestore
          .collection('notification_logs')
          .where('sentAt', isLessThan: Timestamp.fromDate(cutoffDate))
          .get();

      final WriteBatch batch = _firestore.batch();
      for (QueryDocumentSnapshot doc in oldLogs.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Datos antiguos de notificaciones limpiados');
    } catch (e) {
      print('Error limpiando datos antiguos: $e');
    }
  }
}

/// Manejador de mensajes en segundo plano (función de nivel superior)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje recibido en segundo plano: ${message.messageId}');

  // Aquí puedes manejar lógica específica para mensajes en segundo plano
  final String? type = message.data['type'];

  switch (type) {
    case 'new_message':
      // Incrementar contador de mensajes no leídos
      break;
    case 'new_chat':
      // Actualizar lista de chats
      break;
    case 'system_announcement':
      // Manejar anuncios del sistema
      break;
    default:
      break;
  }
}
