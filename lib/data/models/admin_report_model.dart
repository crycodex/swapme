import 'package:cloud_firestore/cloud_firestore.dart';

class AdminReportModel {
  final String id;
  final String reportId;
  final String reporterId;
  final String reportedUserId;
  final String? reportedContentId;
  final String type;
  final String reason;
  final String description;
  final String status;
  final String priority;
  final bool requiresAction;
  final DateTime createdAt;
  final DateTime actionDeadline;
  final DateTime? resolvedAt;
  final String? moderatorNotes;
  final String? moderatorId;
  final Map<String, dynamic>? metadata;

  const AdminReportModel({
    required this.id,
    required this.reportId,
    required this.reporterId,
    required this.reportedUserId,
    this.reportedContentId,
    required this.type,
    required this.reason,
    required this.description,
    required this.status,
    required this.priority,
    required this.requiresAction,
    required this.createdAt,
    required this.actionDeadline,
    this.resolvedAt,
    this.moderatorNotes,
    this.moderatorId,
    this.metadata,
  });

  factory AdminReportModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return AdminReportModel(
      id: doc.id,
      reportId: data['reportId'] ?? '',
      reporterId: data['reporterId'] ?? '',
      reportedUserId: data['reportedUserId'] ?? '',
      reportedContentId: data['reportedContentId'],
      type: data['type'] ?? '',
      reason: data['reason'] ?? '',
      description: data['description'] ?? '',
      status: data['status'] ?? 'pending',
      priority: data['priority'] ?? 'medium',
      requiresAction: data['requiresAction'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      actionDeadline:
          (data['actionDeadline'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      moderatorNotes: data['moderatorNotes'],
      moderatorId: data['moderatorId'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reportId': reportId,
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reportedContentId': reportedContentId,
      'type': type,
      'reason': reason,
      'description': description,
      'status': status,
      'priority': priority,
      'requiresAction': requiresAction,
      'createdAt': Timestamp.fromDate(createdAt),
      'actionDeadline': Timestamp.fromDate(actionDeadline),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'moderatorNotes': moderatorNotes,
      'moderatorId': moderatorId,
      'metadata': metadata,
    };
  }

  AdminReportModel copyWith({
    String? id,
    String? reportId,
    String? reporterId,
    String? reportedUserId,
    String? reportedContentId,
    String? type,
    String? reason,
    String? description,
    String? status,
    String? priority,
    bool? requiresAction,
    DateTime? createdAt,
    DateTime? actionDeadline,
    DateTime? resolvedAt,
    String? moderatorNotes,
    String? moderatorId,
    Map<String, dynamic>? metadata,
  }) {
    return AdminReportModel(
      id: id ?? this.id,
      reportId: reportId ?? this.reportId,
      reporterId: reporterId ?? this.reporterId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedContentId: reportedContentId ?? this.reportedContentId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      requiresAction: requiresAction ?? this.requiresAction,
      createdAt: createdAt ?? this.createdAt,
      actionDeadline: actionDeadline ?? this.actionDeadline,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      moderatorId: moderatorId ?? this.moderatorId,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Verifica si el reporte está vencido (más de 24 horas)
  bool get isOverdue {
    return DateTime.now().isAfter(actionDeadline) && requiresAction;
  }

  /// Verifica si el reporte es urgente (menos de 6 horas restantes)
  bool get isUrgent {
    final Duration timeLeft = actionDeadline.difference(DateTime.now());
    return timeLeft.inHours <= 6 && requiresAction;
  }

  /// Obtiene el tiempo restante para actuar
  String get timeRemaining {
    final Duration timeLeft = actionDeadline.difference(DateTime.now());

    if (timeLeft.isNegative) {
      return 'Vencido';
    }

    if (timeLeft.inDays > 0) {
      return '${timeLeft.inDays}d ${timeLeft.inHours % 24}h';
    } else if (timeLeft.inHours > 0) {
      return '${timeLeft.inHours}h ${timeLeft.inMinutes % 60}m';
    } else {
      return '${timeLeft.inMinutes}m';
    }
  }

  /// Obtiene el color de prioridad
  String get priorityColor {
    switch (priority) {
      case 'high':
        return 'red';
      case 'medium':
        return 'orange';
      case 'low':
        return 'green';
      default:
        return 'grey';
    }
  }
}
