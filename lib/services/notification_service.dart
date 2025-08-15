import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class NotificationService extends GetxService {
  static NotificationService get instance => Get.put(NotificationService());

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;

  String? get fcmToken => _fcmToken;

  @override
  Future<void> onInit() async {
    super.onInit();
    await _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
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
        debugPrint('Usuario otorgó permisos para notificaciones');

        // Obtener token FCM
        _fcmToken = await _messaging.getToken();
        if (_fcmToken != null) {
          debugPrint('Token FCM: $_fcmToken');
        }

        // Configurar manejadores de mensajes
        _setupMessageHandlers();

        // Escuchar cambios de token
        _messaging.onTokenRefresh.listen((String token) {
          _fcmToken = token;
          debugPrint('Token FCM actualizado: $token');
          // Aquí podrías actualizar el token en Firestore
        });
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        debugPrint('Usuario denegó permisos para notificaciones');
      } else if (settings.authorizationStatus ==
          AuthorizationStatus.provisional) {
        debugPrint('Usuario otorgó permisos provisionales para notificaciones');
      }
    } catch (e) {
      debugPrint('Error inicializando notificaciones: $e');
    }
  }

  void _setupMessageHandlers() {
    // Manejar mensajes cuando la app está en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Mensaje recibido en primer plano: ${message.messageId}');
      _handleMessage(message);
    });

    // Manejar mensajes cuando la app está en segundo plano pero no terminada
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('Mensaje abrió la app desde segundo plano: ${message.messageId}');
      _handleMessageTap(message);
    });

    // Manejar mensajes cuando la app está completamente cerrada
    _handleInitialMessage();
  }

  Future<void> _handleInitialMessage() async {
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint(
        'Mensaje abrió la app desde estado cerrado: ${initialMessage.messageId}',
      );
      _handleMessageTap(initialMessage);
    }
  }

  void _handleMessage(RemoteMessage message) {
    final String? title = message.notification?.title;
    final String? body = message.notification?.body;

    if (title != null && body != null) {
      // Mostrar notificación local usando GetX
      Get.snackbar(
        title,
        body,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
        onTap: (_) => _handleMessageTap(message),
      );
    }
  }

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
        final String? chatId = message.data['chatId'];
        if (chatId != null) {
          _navigateToChat(chatId);
        }
        break;

      case 'swap_response':
        final String? chatId = message.data['chatId'];
        if (chatId != null) {
          _navigateToChat(chatId);
        }
        break;

      default:
        debugPrint('Tipo de notificación no manejado: $type');
    }
  }

  void _navigateToChat(String chatId) {
    // Navegar al chat específico
    // Nota: Esto requiere que el sistema de navegación esté configurado
    try {
      Get.toNamed('/chat', arguments: {'chatId': chatId});
    } catch (e) {
      debugPrint('Error navegando al chat: $e');
      // Fallback: navegar a la lista de mensajes
      Get.toNamed('/messages');
    }
  }

  // Método para suscribirse a temas (opcional)
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _messaging.subscribeToTopic(topic);
      debugPrint('Suscrito al tema: $topic');
    } catch (e) {
      debugPrint('Error suscribiéndose al tema $topic: $e');
    }
  }

  // Método para desuscribirse de temas (opcional)
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Desuscrito del tema: $topic');
    } catch (e) {
      debugPrint('Error desuscribiéndose del tema $topic: $e');
    }
  }

  // Método para obtener el token actual
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      debugPrint('Error obteniendo token FCM: $e');
      return null;
    }
  }
}
