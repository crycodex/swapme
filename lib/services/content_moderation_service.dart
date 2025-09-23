import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../data/models/content_report_model.dart';
import '../data/models/blocked_user_model.dart';

class ContentModerationService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lista de palabras prohibidas (básica)
  static const List<String> _prohibitedWords = [
    'spam',
    'scam',
    'fraud',
    'fake',
    'estafa',
    'engaño',
    'hate',
    'odio',
    'racist',
    'racista',
    'sexist',
    'machista',
    'harassment',
    'acoso',
    'bullying',
    'intimidación',
    'inappropriate',
    'inapropiado',
    'sexual',
    'pornographic',
    'violent',
    'violento',
    'threat',
    'amenaza',
    'kill',
    'matar',
    'drug',
    'droga',
    'weapon',
    'arma',
    'illegal',
    'ilegal',
  ];

  // Patrones de spam
  static const List<String> _spamPatterns = [
    r'http[s]?://(?:[a-zA-Z]|[0-9]|[$-_@.&+]|[!*\\(\\),]|(?:%[0-9a-fA-F][0-9a-fA-F]))+',
    r'www\.\w+\.\w+',
    r'\b\d{10,}\b', // Números largos (posibles teléfonos)
    r'\b[A-Z]{8,}\b', // Texto en mayúsculas excesivo (palabras completas de 8+ caracteres)
  ];

  @override
  void onInit() {
    super.onInit();
    _initializeService();
  }

  Future<void> _initializeService() async {
    debugPrint('ContentModerationService inicializado');
  }

  /// Valida el contenido de texto antes de enviarlo
  Future<ModerationResult> validateContent(String content) async {
    try {
      debugPrint('Validando contenido: "$content"');
      final String lowerContent = content.toLowerCase();

      // Verificar palabras prohibidas
      for (final String word in _prohibitedWords) {
        if (lowerContent.contains(word.toLowerCase())) {
          debugPrint('Contenido rechazado por palabra prohibida: $word');
          return ModerationResult(
            isValid: false,
            reason: 'El contenido contiene palabras inapropiadas',
            flaggedWords: [word],
          );
        }
      }

      // Verificar patrones de spam
      for (final String pattern in _spamPatterns) {
        final RegExp regex = RegExp(pattern, caseSensitive: false);
        if (regex.hasMatch(content)) {
          final Match? match = regex.firstMatch(content);
          debugPrint('Contenido rechazado por patrón de spam: $pattern');
          debugPrint('Texto que coincidió: "${match?.group(0)}"');
          debugPrint('Contenido original: "$content"');
          return ModerationResult(
            isValid: false,
            reason: 'El contenido contiene patrones de spam',
            flaggedWords: [pattern],
          );
        }
      }

      // Verificar longitud excesiva (posible spam)
      if (content.length > 1000) {
        debugPrint(
          'Contenido rechazado por longitud excesiva: ${content.length}',
        );
        return ModerationResult(
          isValid: false,
          reason: 'El contenido es demasiado largo',
        );
      }

      // Verificar repetición excesiva de caracteres
      if (_hasExcessiveRepetition(content)) {
        debugPrint('Contenido rechazado por repetición excesiva');
        return ModerationResult(
          isValid: false,
          reason: 'El contenido contiene repeticiones excesivas',
        );
      }

      debugPrint('Contenido validado exitosamente');
      return ModerationResult(isValid: true);
    } catch (e) {
      debugPrint('Error validando contenido: $e');
      return ModerationResult(
        isValid: false,
        reason: 'Error al validar el contenido',
      );
    }
  }

  /// Verifica si hay repetición excesiva de caracteres
  bool _hasExcessiveRepetition(String content) {
    final List<String> chars = content.split('');
    final Map<String, int> charCount = {};

    for (final String char in chars) {
      charCount[char] = (charCount[char] ?? 0) + 1;
    }

    // Si algún carácter se repite más del 30% del contenido
    final double threshold = content.length * 0.3;
    return charCount.values.any((charCount) => charCount > threshold);
  }

  /// Reporta contenido inapropiado
  Future<bool> reportContent({
    required String reportedUserId,
    required ReportType type,
    required String reason,
    required String description,
    String? contentId,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final ContentReportModel report = ContentReportModel(
        id: '',
        reporterId: currentUser.uid,
        reportedUserId: reportedUserId,
        reportedContentId: contentId,
        type: type,
        reason: reason,
        description: description,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('content_reports').add(report.toFirestore());

      // Notificar a los administradores
      await _notifyAdmins(report);

      return true;
    } catch (e) {
      debugPrint('Error reportando contenido: $e');
      return false;
    }
  }

  /// Bloquea a un usuario
  Future<bool> blockUser(String blockedUserId, {String? reason}) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      if (currentUser.uid == blockedUserId) {
        debugPrint('No puedes bloquearte a ti mismo');
        return false;
      }

      // Verificar si ya está bloqueado
      final DocumentSnapshot existingBlock = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('blocked_users')
          .doc(blockedUserId)
          .get();

      if (existingBlock.exists) {
        final Map<String, dynamic>? data =
            existingBlock.data() as Map<String, dynamic>?;
        if (data?['isActive'] == true) {
          debugPrint('Usuario ya está bloqueado');
          return true; // Ya está bloqueado
        }
      }

      final BlockedUserModel block = BlockedUserModel(
        id: blockedUserId,
        blockerId: currentUser.uid,
        blockedUserId: blockedUserId,
        reason: reason,
        createdAt: DateTime.now(),
        isActive: true,
      );

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('blocked_users')
          .doc(blockedUserId)
          .set(block.toFirestore());

      // Actualizar estadísticas del usuario bloqueado
      await _updateUserBlockStats(blockedUserId);

      debugPrint('Usuario $blockedUserId bloqueado exitosamente');
      return true;
    } catch (e) {
      debugPrint('Error bloqueando usuario: $e');
      return false;
    }
  }

  /// Desbloquea a un usuario
  Future<bool> unblockUser(String blockedUserId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final DocumentSnapshot blockDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('blocked_users')
          .doc(blockedUserId)
          .get();

      if (!blockDoc.exists) {
        debugPrint('Usuario no estaba bloqueado');
        return true; // No estaba bloqueado, consideramos éxito
      }

      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('blocked_users')
          .doc(blockedUserId)
          .update({'isActive': false});

      debugPrint('Usuario $blockedUserId desbloqueado exitosamente');
      return true;
    } catch (e) {
      debugPrint('Error desbloqueando usuario: $e');
      return false;
    }
  }

  /// Verifica si un usuario está bloqueado por el usuario actual
  Future<bool> isUserBlocked(String userId) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final DocumentSnapshot block = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('blocked_users')
          .doc(userId)
          .get();

      if (!block.exists) return false;

      final Map<String, dynamic>? data = block.data() as Map<String, dynamic>?;
      return data?['isActive'] == true;
    } catch (e) {
      debugPrint('Error verificando si usuario está bloqueado: $e');
      return false;
    }
  }

  /// Obtiene la lista de usuarios bloqueados por el usuario actual
  Stream<List<BlockedUserModel>> getBlockedUsers() {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return Stream.value([]);

      return _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('blocked_users')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => BlockedUserModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      debugPrint('Error obteniendo usuarios bloqueados: $e');
      return Stream.value([]);
    }
  }

  /// Notifica a los administradores sobre un nuevo reporte
  Future<void> _notifyAdmins(ContentReportModel report) async {
    try {
      // Crear documento en la colección de reportes para administradores
      await _firestore.collection('admin_reports').add({
        'reportId': report.id,
        'reporterId': report.reporterId,
        'reportedUserId': report.reportedUserId,
        'reportedContentId': report.reportedContentId,
        'type': report.type.name,
        'reason': report.reason,
        'description': report.description,
        'status': report.status.name,
        'createdAt': Timestamp.fromDate(report.createdAt),
        'priority': _getReportPriority(report.type),
        'requiresAction': true,
        'actionDeadline': Timestamp.fromDate(
          DateTime.now().add(const Duration(hours: 24)),
        ),
      });

      // Aquí puedes implementar notificaciones push a administradores
      debugPrint('Reporte creado para administradores: ${report.id}');

      // También puedes enviar un email o crear una tarea en un sistema externo
      // para que los administradores actúen dentro de las 24 horas requeridas
    } catch (e) {
      debugPrint('Error notificando a administradores: $e');
    }
  }

  /// Determina la prioridad del reporte basado en el tipo
  String _getReportPriority(ReportType type) {
    switch (type) {
      case ReportType.harassment:
      case ReportType.inappropriateContent:
        return 'high';
      case ReportType.fakeProduct:
      case ReportType.spam:
        return 'medium';
      case ReportType.inappropriateImage:
      case ReportType.other:
        return 'low';
    }
  }

  /// Actualiza las estadísticas de bloqueo de un usuario
  Future<void> _updateUserBlockStats(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'blockCount': FieldValue.increment(1),
        'lastBlockedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      debugPrint('Error actualizando estadísticas de bloqueo: $e');
    }
  }

  /// Obtiene reportes de contenido (solo para administradores)
  Stream<List<ContentReportModel>> getContentReports({
    ReportStatus? status,
    int? limit,
  }) {
    try {
      Query query = _firestore
          .collection('content_reports')
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      return query.snapshots().map(
        (snapshot) => snapshot.docs
            .map((doc) => ContentReportModel.fromFirestore(doc))
            .toList(),
      );
    } catch (e) {
      debugPrint('Error obteniendo reportes: $e');
      return Stream.value([]);
    }
  }

  /// Resuelve un reporte (solo para administradores)
  Future<bool> resolveReport(
    String reportId, {
    required String moderatorNotes,
    bool removeContent = false,
    bool banUser = false,
  }) async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser == null) return false;

      final Map<String, dynamic> updateData = {
        'status': ReportStatus.resolved.name,
        'resolvedAt': Timestamp.fromDate(DateTime.now()),
        'moderatorId': currentUser.uid,
        'moderatorNotes': moderatorNotes,
      };

      await _firestore
          .collection('content_reports')
          .doc(reportId)
          .update(updateData);

      // Si se requiere remover contenido o banear usuario
      if (removeContent || banUser) {
        final DocumentSnapshot reportDoc = await _firestore
            .collection('content_reports')
            .doc(reportId)
            .get();

        if (reportDoc.exists) {
          final ContentReportModel report = ContentReportModel.fromFirestore(
            reportDoc,
          );

          if (removeContent && report.reportedContentId != null) {
            await _removeReportedContent(report);
          }

          if (banUser) {
            await _banUser(report.reportedUserId);
          }
        }
      }

      return true;
    } catch (e) {
      debugPrint('Error resolviendo reporte: $e');
      return false;
    }
  }

  /// Remueve el contenido reportado
  Future<void> _removeReportedContent(ContentReportModel report) async {
    try {
      // Implementar lógica para remover diferentes tipos de contenido
      // (mensajes, productos, etc.) basado en el tipo de reporte
      debugPrint('Removiendo contenido reportado: ${report.reportedContentId}');
    } catch (e) {
      debugPrint('Error removiendo contenido: $e');
    }
  }

  /// Banea a un usuario
  Future<void> _banUser(String userId) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'isBanned': true,
        'bannedAt': Timestamp.fromDate(DateTime.now()),
        'banReason': 'Contenido inapropiado reportado',
      });
    } catch (e) {
      debugPrint('Error baneando usuario: $e');
    }
  }
}

class ModerationResult {
  final bool isValid;
  final String? reason;
  final List<String>? flaggedWords;

  const ModerationResult({
    required this.isValid,
    this.reason,
    this.flaggedWords,
  });
}
