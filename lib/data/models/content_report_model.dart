import 'package:cloud_firestore/cloud_firestore.dart';

enum ReportType {
  inappropriateContent,
  spam,
  harassment,
  fakeProduct,
  inappropriateImage,
  other,
}

enum ReportStatus { pending, underReview, resolved, dismissed }

class ContentReportModel {
  final String id;
  final String reporterId;
  final String reportedUserId;
  final String? reportedContentId;
  final ReportType type;
  final String reason;
  final String description;
  final ReportStatus status;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? moderatorNotes;
  final String? moderatorId;
  final Map<String, dynamic>? metadata;

  const ContentReportModel({
    required this.id,
    required this.reporterId,
    required this.reportedUserId,
    this.reportedContentId,
    required this.type,
    required this.reason,
    required this.description,
    this.status = ReportStatus.pending,
    required this.createdAt,
    this.resolvedAt,
    this.moderatorNotes,
    this.moderatorId,
    this.metadata,
  });

  factory ContentReportModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ContentReportModel(
      id: doc.id,
      reporterId: data['reporterId'] ?? '',
      reportedUserId: data['reportedUserId'] ?? '',
      reportedContentId: data['reportedContentId'],
      type: ReportType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => ReportType.other,
      ),
      reason: data['reason'] ?? '',
      description: data['description'] ?? '',
      status: ReportStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ReportStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      resolvedAt: (data['resolvedAt'] as Timestamp?)?.toDate(),
      moderatorNotes: data['moderatorNotes'],
      moderatorId: data['moderatorId'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'reporterId': reporterId,
      'reportedUserId': reportedUserId,
      'reportedContentId': reportedContentId,
      'type': type.name,
      'reason': reason,
      'description': description,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'resolvedAt': resolvedAt != null ? Timestamp.fromDate(resolvedAt!) : null,
      'moderatorNotes': moderatorNotes,
      'moderatorId': moderatorId,
      'metadata': metadata,
    };
  }

  ContentReportModel copyWith({
    String? id,
    String? reporterId,
    String? reportedUserId,
    String? reportedContentId,
    ReportType? type,
    String? reason,
    String? description,
    ReportStatus? status,
    DateTime? createdAt,
    DateTime? resolvedAt,
    String? moderatorNotes,
    String? moderatorId,
    Map<String, dynamic>? metadata,
  }) {
    return ContentReportModel(
      id: id ?? this.id,
      reporterId: reporterId ?? this.reporterId,
      reportedUserId: reportedUserId ?? this.reportedUserId,
      reportedContentId: reportedContentId ?? this.reportedContentId,
      type: type ?? this.type,
      reason: reason ?? this.reason,
      description: description ?? this.description,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      moderatorNotes: moderatorNotes ?? this.moderatorNotes,
      moderatorId: moderatorId ?? this.moderatorId,
      metadata: metadata ?? this.metadata,
    );
  }
}
