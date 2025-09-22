import 'package:cloud_firestore/cloud_firestore.dart';

class BlockedUserModel {
  final String id;
  final String blockerId;
  final String blockedUserId;
  final String? reason;
  final DateTime createdAt;
  final bool isActive;

  const BlockedUserModel({
    required this.id,
    required this.blockerId,
    required this.blockedUserId,
    this.reason,
    required this.createdAt,
    this.isActive = true,
  });

  factory BlockedUserModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return BlockedUserModel(
      id: doc.id,
      blockerId: data['blockerId'] ?? '',
      blockedUserId: data['blockedUserId'] ?? '',
      reason: data['reason'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'blockerId': blockerId,
      'blockedUserId': blockedUserId,
      'reason': reason,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }

  BlockedUserModel copyWith({
    String? id,
    String? blockerId,
    String? blockedUserId,
    String? reason,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return BlockedUserModel(
      id: id ?? this.id,
      blockerId: blockerId ?? this.blockerId,
      blockedUserId: blockedUserId ?? this.blockedUserId,
      reason: reason ?? this.reason,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
