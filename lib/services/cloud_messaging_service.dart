import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

// Necesitamos importar las opciones de Firebase para el background handler
import '../firebase_options.dart';

/// Servicio centralizado para manejo de Firebase Cloud Messaging
/// Permite envío de notificaciones individuales, masivas y por temas
class CloudMessagingService extends GetxService {
  static CloudMessagingService get instance => Get.put(CloudMessagingService());

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

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
    // No inicializar automáticamente, se hará manualmente cuando sea necesario
  }

  /// Inicializa el servicio manualmente cuando la app esté lista
  Future<void> initializeWhenReady() async {
    await _initializeCloudMessaging();
  }

  /// Inicializa el servicio de Cloud Messaging
  Future<void> _initializeCloudMessaging() async {
    try {
      // Inicializar notificaciones locales primero
      await _initializeLocalNotifications();

      // Configurar opciones de presentación para iOS
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );

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
        debugPrint('Usuario otorgó permisos para notificaciones');

        // Configurar manejadores de mensajes primero
        _setupMessageHandlers();

        // Para iOS, usar un enfoque más conservador
        if (defaultTargetPlatform == TargetPlatform.iOS) {
          await _initializeForIOS();
        } else {
          // Para Android, inicialización normal
          await _handlePushNotificationsToken();
          await _subscribeToDefaultTopics();
        }
      } else {
        debugPrint('Usuario denegó permisos para notificaciones');
      }
    } catch (e) {
      debugPrint('Error inicializando Cloud Messaging: $e');
    }
  }

  /// Inicialización específica para iOS con manejo robusto de errores
  Future<void> _initializeForIOS() async {
    try {
      // Esperar un poco más para que iOS esté completamente listo
      await Future.delayed(const Duration(seconds: 2));

      // Intentar obtener token APNS de manera más suave
      try {
        final String? apnsToken = await _messaging.getAPNSToken();
        if (apnsToken != null) {
          debugPrint('Token APNS obtenido: $apnsToken');
        } else {
          debugPrint('Token APNS no disponible, continuando sin él');
        }
      } catch (e) {
        debugPrint('No se pudo obtener token APNS: $e');
      }

      // Intentar obtener token FCM con manejo de errores
      try {
        await _handlePushNotificationsToken();
        await _subscribeToDefaultTopics();
        debugPrint('FCM inicializado correctamente en iOS');
      } catch (e) {
        debugPrint('Error inicializando FCM en iOS: $e');
        // Reintentar después de un delay
        Future.delayed(const Duration(seconds: 3), () async {
          try {
            await _handlePushNotificationsToken();
            await _subscribeToDefaultTopics();
            debugPrint('FCM inicializado en reintento');
          } catch (retryError) {
            debugPrint('Error en reintento de FCM: $retryError');
          }
        });
      }
    } catch (e) {
      debugPrint('Error en inicialización iOS: $e');
    }
  }

  /// Maneja el token FCM para notificaciones push
  Future<void> _handlePushNotificationsToken() async {
    try {
      // En iOS, esperar un poco más si no tenemos token APNS
      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final String? token = await _messaging.getToken();
      final String? userId = currentUserId;

      if (token != null && userId != null) {
        // Actualizar token en Firestore
        await _saveTokenToDatabase(token);
        _fcmToken = token;
        debugPrint('FCM Token actualizado: $token');
      } else if (token == null) {
        debugPrint(
          'No se pudo obtener token FCM, reintentando en 2 segundos...',
        );
        // Reintentar después de un delay
        Future.delayed(const Duration(seconds: 2), () async {
          try {
            final String? retryToken = await _messaging.getToken();
            if (retryToken != null && currentUserId != null) {
              await _saveTokenToDatabase(retryToken);
              _fcmToken = retryToken;
              debugPrint('FCM Token obtenido en reintento: $retryToken');
            }
          } catch (e) {
            debugPrint('Error en reintento de FCM token: $e');
          }
        });
      }

      // Escuchar cambios en el token
      _messaging.onTokenRefresh.listen((String fcmToken) async {
        _fcmToken = fcmToken;
        debugPrint('FCM Token refrescado: $fcmToken');
        if (currentUserId != null) {
          await _saveTokenToDatabase(fcmToken);
        }
      });
    } catch (e) {
      debugPrint('Error manejando FCM token: $e');
    }
  }

  /// Inicializa las notificaciones locales
  Future<void> _initializeLocalNotifications() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      debugPrint('Notificaciones locales inicializadas');
    } catch (e) {
      debugPrint('Error inicializando notificaciones locales: $e');
    }
  }

  /// Maneja cuando el usuario toca una notificación local
  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final String? payload = notificationResponse.payload;
    if (payload != null) {
      try {
        // El payload contiene información para navegar
        debugPrint('Notificación local tocada con payload: $payload');
        // Aquí puedes parsear el payload y navegar según corresponda
        if (payload.contains('chatId:')) {
          final String chatId = payload.split('chatId:')[1].split(',')[0];
          _navigateToChat(chatId);
        }
      } catch (e) {
        debugPrint('Error procesando tap de notificación local: $e');
      }
    }
  }

  /// Configura los manejadores de mensajes
  void _setupMessageHandlers() {
    // Registrar manejador para mensajes en background (app terminada)
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Mensaje recibido en primer plano: ${message.messageId}');
      _handleForegroundMessage(message);
    });

    // Manejar mensajes cuando la app está en segundo plano pero no terminada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint(
        'Mensaje abrió la app desde segundo plano: ${message.messageId}',
      );
      _handleMessageTap(message);
    });

    // Manejar mensajes cuando la app está completamente cerrada
    _handleInitialMessage();
  }

  /// Maneja mensajes cuando la app se abre desde estado cerrado
  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        'Mensaje abrió la app desde estado cerrado: ${initialMessage.messageId}',
      );
      _handleMessageTap(initialMessage);
    }
  }

  /// Maneja mensajes en primer plano
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Mensaje recibido en primer plano: ${message.data}');

    final RemoteNotification? notification = message.notification;

    if (notification != null) {
      await _showLocalNotification(
        title: notification.title ?? 'Nueva notificación',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    }
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
        debugPrint('Tipo de notificación no manejado: $type');
        _navigateToHome();
    }
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
      debugPrint('Token FCM guardado en base de datos');
    } catch (e) {
      debugPrint('Error guardando token FCM: $e');
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
      debugPrint('Error suscribiendo a temas por defecto: $e');
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
          final String cleanCity = _cleanTopicName(city);
          await subscribeToTopic('city_$cleanCity');
        }

        final List<String>? interests = userData?['interests']?.cast<String>();
        if (interests != null) {
          for (String interest in interests) {
            // Limpiar el nombre del tema para que sea válido
            final String cleanInterest = _cleanTopicName(interest);
            await subscribeToTopic('interest_$cleanInterest');
          }
        }
      }
    } catch (e) {
      debugPrint('Error suscribiendo a temas específicos: $e');
    }
  }

  /// Limpia el nombre del tema para que sea válido para FCM
  String _cleanTopicName(String topic) {
    // Los nombres de temas en FCM deben cumplir con: [a-zA-Z0-9-_.~%]+
    // Reemplazar caracteres no válidos con guiones bajos
    return topic.replaceAll(RegExp(r'[^a-zA-Z0-9\-_\.~%]'), '_').toLowerCase();
  }

  /// Suscribe a un tema específico
  Future<void> subscribeToTopic(String topic) async {
    try {
      // Limpiar el nombre del tema antes de suscribirse
      final String cleanTopic = _cleanTopicName(topic);
      await _messaging.subscribeToTopic(cleanTopic);
      debugPrint('Suscrito al tema: $cleanTopic');
    } catch (e) {
      debugPrint('Error suscribiéndose al tema $topic: $e');
    }
  }

  /// Desuscribe de un tema específico
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      // Limpiar el nombre del tema antes de desuscribirse
      final String cleanTopic = _cleanTopicName(topic);
      await _messaging.unsubscribeFromTopic(cleanTopic);
      debugPrint('Desuscrito del tema: $cleanTopic');
    } catch (e) {
      debugPrint('Error desuscribiéndose del tema $topic: $e');
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
        debugPrint('Usuario no encontrado: $userId');
        return false;
      }

      final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;
      final String? userToken = userData?['fcmToken'];

      if (userToken == null) {
        debugPrint('Token FCM no encontrado para usuario: $userId');
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
      debugPrint('Error enviando notificación a usuario $userId: $e');
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
      // En un entorno real, esto se haría desde el backend
      debugPrint('Enviando notificación al tema: $topic');
      debugPrint('Título: $title');
      debugPrint('Cuerpo: $body');
      debugPrint('Data: $data');

      return true;
    } catch (e) {
      debugPrint('Error enviando notificación al tema $topic: $e');
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
      // En un entorno real, esto se haría desde el backend usando Firebase Admin SDK
      debugPrint('Enviando notificación individual');
      debugPrint('Token: $token');
      debugPrint('Título: $title');
      debugPrint('Cuerpo: $body');
      debugPrint('Data: $data');

      return true;
    } catch (e) {
      debugPrint('Error enviando notificación individual: $e');
      return false;
    }
  }

  // Métodos de navegación
  void _navigateToChat(String chatId) {
    try {
      Get.toNamed('/chat', arguments: {'chatId': chatId});
    } catch (e) {
      debugPrint('Error navegando al chat: $e');
      Get.toNamed('/messages');
    }
  }

  void _navigateToSwapDetail(String swapItemId) {
    try {
      Get.toNamed('/swap-detail', arguments: {'swapItemId': swapItemId});
    } catch (e) {
      debugPrint('Error navegando al detalle de swap: $e');
      Get.toNamed('/home');
    }
  }

  void _navigateToHome() {
    try {
      Get.toNamed('/home');
    } catch (e) {
      debugPrint('Error navegando al home: $e');
    }
  }

  /// Limpia el badge cuando la app se abre
  Future<void> clearBadgeOnAppOpen() async {
    try {
      await AppBadgePlus.updateBadge(0);
      debugPrint('Badge limpiado al abrir la app');
    } catch (e) {
      debugPrint(
        'Error limpiando badge (no soportado en este dispositivo): $e',
      );
    }
  }

  /// Actualiza el badge basado en mensajes no leídos actuales
  Future<void> updateBadgeFromDatabase() async {
    await _updateBadgeCount();
  }

  /// Muestra una notificación local
  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
            'chat_messages',
            'Mensajes de Chat',
            channelDescription: 'Notificaciones de nuevos mensajes en chats',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
          );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      const NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      debugPrint('Notificación local mostrada: $title - $body');
    } catch (e) {
      debugPrint('Error mostrando notificación local: $e');
    }
  }
}

/// Muestra una notificación local (función de nivel superior para background handler)
Future<void> _showLocalNotificationStatic({
  required String title,
  required String body,
  String? payload,
}) async {
  try {
    final FlutterLocalNotificationsPlugin localNotifications =
        FlutterLocalNotificationsPlugin();

    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
          'chat_messages',
          'Mensajes de Chat',
          channelDescription: 'Notificaciones de nuevos mensajes en chats',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
        );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

    const NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );

    debugPrint('Notificación local mostrada: $title - $body');
  } catch (e) {
    debugPrint('Error mostrando notificación local: $e');
  }
}

/// Manejador de mensajes en segundo plano (función de nivel superior)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('Mensaje recibido en segundo plano: ${message.messageId}');

  // Inicializar Firebase para el contexto de background
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final String? type = message.data['type'];
  final String? title = message.notification?.title;
  final String? body = message.notification?.body;
  final String? chatId = message.data['chatId'];
  final String? senderId = message.data['senderId'];

  switch (type) {
    case 'new_message':
      if (chatId != null && senderId != null) {
        await _handleNewMessageInBackground(
          chatId: chatId,
          senderId: senderId,
          title: title,
          body: body,
          messageId: message.messageId ?? '',
        );
      }
      break;
    case 'new_chat':
      // Incrementar contador de chats nuevos
      await _updateBadgeCount();
      break;
    case 'swap_proposal':
    case 'swap_response':
      // Manejar propuestas y respuestas de intercambio
      await _updateBadgeCount();
      break;
    case 'system_announcement':
      // Los anuncios del sistema siempre se muestran
      break;
    default:
      break;
  }
}

/// Maneja nuevos mensajes cuando la app está en background
Future<void> _handleNewMessageInBackground({
  required String chatId,
  required String senderId,
  required String? title,
  required String? body,
  required String messageId,
}) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final FirebaseAuth auth = FirebaseAuth.instance;

    final String? currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) return;

    // Verificar si el mensaje ya fue leído
    final QuerySnapshot unreadMessages = await firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isEqualTo: senderId)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (unreadMessages.docs.isNotEmpty) {
      // Hay mensajes no leídos, actualizar contador
      await _incrementUnreadCount(currentUserId, chatId);
      await _updateBadgeCount();

      // Mostrar notificación local
      await _showLocalNotificationStatic(
        title: title ?? 'Nuevo mensaje',
        body: body ?? 'Tienes un mensaje nuevo',
        payload: 'chatId:$chatId,messageId:$messageId',
      );
    }
  } catch (e) {
    debugPrint('Error manejando mensaje en background: $e');
  }
}

/// Incrementa el contador de mensajes no leídos
Future<void> _incrementUnreadCount(String userId, String chatId) async {
  try {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Verificar si el documento del usuario existe
    final DocumentSnapshot userDoc = await firestore
        .collection('users')
        .doc(userId)
        .get();

    if (userDoc.exists) {
      // El documento existe, incrementar contador
      await firestore.collection('users').doc(userId).update({
        'unreadChatsCount': FieldValue.increment(1),
        'lastUnreadUpdate': FieldValue.serverTimestamp(),
      });
    } else {
      // El documento no existe, crearlo con valores iniciales
      await firestore.collection('users').doc(userId).set({
        'unreadChatsCount': 1,
        'lastUnreadUpdate': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    // Mantener registro por chat específico (siempre crear/actualizar)
    await firestore
        .collection('users')
        .doc(userId)
        .collection('unread_chats')
        .doc(chatId)
        .set({
          'hasUnread': true,
          'lastUpdate': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  } catch (e) {
    debugPrint('Error incrementando contador no leídos: $e');
  }
}

/// Actualiza el badge count de la app
Future<void> _updateBadgeCount() async {
  try {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final String? currentUserId = auth.currentUser?.uid;
    if (currentUserId == null) return;

    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Obtener total de chats no leídos
    final QuerySnapshot unreadChats = await firestore
        .collection('users')
        .doc(currentUserId)
        .collection('unread_chats')
        .where('hasUnread', isEqualTo: true)
        .get();

    final int unreadCount = unreadChats.docs.length;

    // Actualizar badge de la app en el ícono
    try {
      if (unreadCount > 0) {
        await AppBadgePlus.updateBadge(unreadCount);
      } else {
        await AppBadgePlus.updateBadge(0);
      }
    } catch (e) {
      debugPrint(
        'Error actualizando badge (no soportado en este dispositivo): $e',
      );
    }

    debugPrint('Badge count actualizado: $unreadCount mensajes no leídos');
  } catch (e) {
    debugPrint('Error actualizando badge count: $e');
  }
}
