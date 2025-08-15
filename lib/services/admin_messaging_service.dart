import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'cloud_messaging_service.dart';

/// Servicio para administradores que permite envío masivo de notificaciones
/// y gestión avanzada de mensajería desde Firebase
class AdminMessagingService extends GetxService {
  static AdminMessagingService get instance => Get.put(AdminMessagingService());

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CloudMessagingService _cloudMessagingService =
      CloudMessagingService.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Envía notificación a todos los usuarios registrados
  Future<bool> sendNotificationToAllUsers({
    required String title,
    required String body,
    Map<String, dynamic>? data,
    String? imageUrl,
  }) async {
    try {
      // Verificar permisos de administrador
      if (!await _isAdmin()) {
        print('Error: Usuario no tiene permisos de administrador');
        return false;
      }

      // Enviar a tema de todos los usuarios
      return await _cloudMessagingService.sendNotificationToTopic(
        topic: CloudMessagingService.allUsersTopicName,
        title: title,
        body: body,
        data: {
          'type': 'admin_announcement',
          'timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          ...?data,
        },
        imageUrl: imageUrl,
      );
    } catch (e) {
      print('Error enviando notificación masiva: $e');
      return false;
    }
  }

  /// Envía notificación sobre nuevos swaps disponibles
  Future<bool> sendNewSwapNotification({
    required String swapItemId,
    required String swapItemName,
    required String category,
    String? city,
  }) async {
    try {
      if (!await _isAdmin()) {
        print('Error: Usuario no tiene permisos de administrador');
        return false;
      }

      // Enviar a tema de nuevos swaps
      bool generalNotification = await _cloudMessagingService
          .sendNotificationToTopic(
            topic: CloudMessagingService.newSwapsTopicName,
            title: '¡Nuevo artículo disponible!',
            body: '$swapItemName está disponible para intercambio',
            data: {
              'type': 'new_swap_item',
              'swapItemId': swapItemId,
              'category': category,
              'city': city ?? '',
            },
          );

      // Enviar a tema específico de categoría si existe
      bool categoryNotification = await _cloudMessagingService
          .sendNotificationToTopic(
            topic: 'category_$category',
            title: '¡Nuevo artículo en $category!',
            body: '$swapItemName está disponible para intercambio',
            data: {
              'type': 'new_swap_item',
              'swapItemId': swapItemId,
              'category': category,
              'city': city ?? '',
            },
          );

      // Enviar a tema específico de ciudad si existe
      bool cityNotification = true;
      if (city != null && city.isNotEmpty) {
        cityNotification = await _cloudMessagingService.sendNotificationToTopic(
          topic: 'city_$city',
          title: '¡Nuevo artículo en tu ciudad!',
          body: '$swapItemName está disponible para intercambio en $city',
          data: {
            'type': 'new_swap_item',
            'swapItemId': swapItemId,
            'category': category,
            'city': city,
          },
        );
      }

      return generalNotification && categoryNotification && cityNotification;
    } catch (e) {
      print('Error enviando notificación de nuevo swap: $e');
      return false;
    }
  }

  /// Envía notificación a usuarios en una ciudad específica
  Future<bool> sendNotificationToCity({
    required String city,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!await _isAdmin()) {
        print('Error: Usuario no tiene permisos de administrador');
        return false;
      }

      return await _cloudMessagingService.sendNotificationToTopic(
        topic: 'city_$city',
        title: title,
        body: body,
        data: {'type': 'city_announcement', 'city': city, ...?data},
      );
    } catch (e) {
      print('Error enviando notificación a ciudad: $e');
      return false;
    }
  }

  /// Envía notificación a usuarios interesados en una categoría
  Future<bool> sendNotificationToCategory({
    required String category,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!await _isAdmin()) {
        print('Error: Usuario no tiene permisos de administrador');
        return false;
      }

      return await _cloudMessagingService.sendNotificationToTopic(
        topic: 'category_$category',
        title: title,
        body: body,
        data: {'type': 'category_announcement', 'category': category, ...?data},
      );
    } catch (e) {
      print('Error enviando notificación a categoría: $e');
      return false;
    }
  }

  /// Envía notificación personalizada a usuarios específicos
  Future<bool> sendNotificationToSpecificUsers({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!await _isAdmin()) {
        print('Error: Usuario no tiene permisos de administrador');
        return false;
      }

      int successCount = 0;
      for (String userId in userIds) {
        bool success = await _cloudMessagingService.sendNotificationToUser(
          userId: userId,
          title: title,
          body: body,
          data: {'type': 'targeted_message', ...?data},
        );
        if (success) successCount++;
      }

      print('Notificaciones enviadas: $successCount/${userIds.length}');
      return successCount == userIds.length;
    } catch (e) {
      print('Error enviando notificaciones específicas: $e');
      return false;
    }
  }

  /// Programa una notificación para enviar más tarde
  Future<bool> scheduleNotification({
    required DateTime scheduledTime,
    required String title,
    required String body,
    String? topic,
    List<String>? userIds,
    Map<String, dynamic>? data,
  }) async {
    try {
      if (!await _isAdmin()) {
        print('Error: Usuario no tiene permisos de administrador');
        return false;
      }

      // Guardar notificación programada en Firestore
      await _firestore.collection('scheduled_notifications').add({
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'title': title,
        'body': body,
        'topic': topic,
        'userIds': userIds ?? [],
        'data': data ?? {},
        'status': 'pending',
        'createdBy': currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Notificación programada para: $scheduledTime');
      return true;
    } catch (e) {
      print('Error programando notificación: $e');
      return false;
    }
  }

  /// Obtiene estadísticas de notificaciones enviadas
  Future<Map<String, dynamic>> getNotificationStats({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      if (!await _isAdmin()) {
        return {};
      }

      Query query = _firestore.collection('notification_logs');

      if (startDate != null) {
        query = query.where(
          'sentAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }
      if (endDate != null) {
        query = query.where(
          'sentAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final QuerySnapshot snapshot = await query.get();

      int totalSent = snapshot.docs.length;
      int topicNotifications = 0;
      int individualNotifications = 0;
      Map<String, int> typeCount = {};

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final String type = data['type'] ?? 'unknown';

        if (type == 'topic') {
          topicNotifications++;
        } else if (type == 'individual') {
          individualNotifications++;
        }

        final String notificationType = data['data']?['type'] ?? 'unknown';
        typeCount[notificationType] = (typeCount[notificationType] ?? 0) + 1;
      }

      return {
        'totalSent': totalSent,
        'topicNotifications': topicNotifications,
        'individualNotifications': individualNotifications,
        'typeBreakdown': typeCount,
        'period': {
          'start': startDate?.toIso8601String(),
          'end': endDate?.toIso8601String(),
        },
      };
    } catch (e) {
      print('Error obteniendo estadísticas: $e');
      return {};
    }
  }

  /// Obtiene lista de usuarios activos para envío dirigido
  Future<List<Map<String, dynamic>>> getActiveUsers({int? limit}) async {
    try {
      if (!await _isAdmin()) {
        return [];
      }

      Query query = _firestore
          .collection('users')
          .where('fcmToken', isNull: false)
          .orderBy('lastSeen', descending: true);

      if (limit != null) {
        query = query.limit(limit);
      }

      final QuerySnapshot snapshot = await query.get();

      return snapshot.docs.map((doc) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'name': data['name'] ?? 'Usuario',
          'email': data['email'] ?? '',
          'city': data['city'] ?? '',
          'lastSeen': data['lastSeen'],
          'fcmToken': data['fcmToken'] != null ? 'disponible' : 'no disponible',
        };
      }).toList();
    } catch (e) {
      print('Error obteniendo usuarios activos: $e');
      return [];
    }
  }

  /// Verifica si el usuario actual es administrador
  Future<bool> _isAdmin() async {
    if (currentUserId == null) return false;

    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .get();

      if (!userDoc.exists) return false;

      final Map<String, dynamic>? userData =
          userDoc.data() as Map<String, dynamic>?;

      return userData?['isAdmin'] == true ||
          userData?['role'] == 'admin' ||
          userData?['permissions']?['canSendNotifications'] == true;
    } catch (e) {
      print('Error verificando permisos de administrador: $e');
      return false;
    }
  }

  /// Procesa notificaciones programadas (llamar desde Cloud Function)
  Future<void> processScheduledNotifications() async {
    try {
      final DateTime now = DateTime.now();

      final QuerySnapshot snapshot = await _firestore
          .collection('scheduled_notifications')
          .where('status', isEqualTo: 'pending')
          .where('scheduledTime', isLessThanOrEqualTo: Timestamp.fromDate(now))
          .get();

      for (QueryDocumentSnapshot doc in snapshot.docs) {
        final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        bool success = false;
        if (data['topic'] != null) {
          success = await _cloudMessagingService.sendNotificationToTopic(
            topic: data['topic'],
            title: data['title'],
            body: data['body'],
            data: Map<String, dynamic>.from(data['data'] ?? {}),
          );
        } else if (data['userIds'] != null &&
            (data['userIds'] as List).isNotEmpty) {
          success = await sendNotificationToSpecificUsers(
            userIds: (data['userIds'] as List).cast<String>(),
            title: data['title'],
            body: data['body'],
            data: Map<String, dynamic>.from(data['data'] ?? {}),
          );
        }

        // Actualizar estado de la notificación
        await doc.reference.update({
          'status': success ? 'sent' : 'failed',
          'processedAt': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error procesando notificaciones programadas: $e');
    }
  }
}
