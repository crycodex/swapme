import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapHistoryStatus { completed, cancelled }

class SwapHistoryModel {
  final String id;
  final String chatId;
  final String swapItemId;
  final String swapItemName;
  final String swapItemImageUrl;
  final String swapItemOwnerId;
  final String swapItemOwnerName;
  final String swapItemOwnerPhotoUrl;
  final String interestedUserId;
  final String interestedUserName;
  final String interestedUserPhotoUrl;
  final DateTime completedAt;
  final SwapHistoryStatus status;
  final String? notes;
  final Map<String, dynamic>? metadata;

  const SwapHistoryModel({
    required this.id,
    required this.chatId,
    required this.swapItemId,
    required this.swapItemName,
    required this.swapItemImageUrl,
    required this.swapItemOwnerId,
    required this.swapItemOwnerName,
    required this.swapItemOwnerPhotoUrl,
    required this.interestedUserId,
    required this.interestedUserName,
    required this.interestedUserPhotoUrl,
    required this.completedAt,
    required this.status,
    this.notes,
    this.metadata,
  });

  factory SwapHistoryModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SwapHistoryModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      swapItemId: data['swapItemId'] ?? '',
      swapItemName: data['swapItemName'] ?? '',
      swapItemImageUrl: data['swapItemImageUrl'] ?? '',
      swapItemOwnerId: data['swapItemOwnerId'] ?? '',
      swapItemOwnerName: data['swapItemOwnerName'] ?? '',
      swapItemOwnerPhotoUrl: data['swapItemOwnerPhotoUrl'] ?? '',
      interestedUserId: data['interestedUserId'] ?? '',
      interestedUserName: data['interestedUserName'] ?? '',
      interestedUserPhotoUrl: data['interestedUserPhotoUrl'] ?? '',
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      status: SwapHistoryStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SwapHistoryStatus.completed,
      ),
      notes: data['notes'],
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'swapItemId': swapItemId,
      'swapItemName': swapItemName,
      'swapItemImageUrl': swapItemImageUrl,
      'swapItemOwnerId': swapItemOwnerId,
      'swapItemOwnerName': swapItemOwnerName,
      'swapItemOwnerPhotoUrl': swapItemOwnerPhotoUrl,
      'interestedUserId': interestedUserId,
      'interestedUserName': interestedUserName,
      'interestedUserPhotoUrl': interestedUserPhotoUrl,
      'completedAt': Timestamp.fromDate(completedAt),
      'status': status.name,
      'notes': notes,
      'metadata': metadata,
      'participants': [swapItemOwnerId, interestedUserId],
    };
  }

  SwapHistoryModel copyWith({
    String? id,
    String? chatId,
    String? swapItemId,
    String? swapItemName,
    String? swapItemImageUrl,
    String? swapItemOwnerId,
    String? swapItemOwnerName,
    String? swapItemOwnerPhotoUrl,
    String? interestedUserId,
    String? interestedUserName,
    String? interestedUserPhotoUrl,
    DateTime? completedAt,
    SwapHistoryStatus? status,
    String? notes,
    Map<String, dynamic>? metadata,
  }) {
    return SwapHistoryModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      swapItemId: swapItemId ?? this.swapItemId,
      swapItemName: swapItemName ?? this.swapItemName,
      swapItemImageUrl: swapItemImageUrl ?? this.swapItemImageUrl,
      swapItemOwnerId: swapItemOwnerId ?? this.swapItemOwnerId,
      swapItemOwnerName: swapItemOwnerName ?? this.swapItemOwnerName,
      swapItemOwnerPhotoUrl:
          swapItemOwnerPhotoUrl ?? this.swapItemOwnerPhotoUrl,
      interestedUserId: interestedUserId ?? this.interestedUserId,
      interestedUserName: interestedUserName ?? this.interestedUserName,
      interestedUserPhotoUrl:
          interestedUserPhotoUrl ?? this.interestedUserPhotoUrl,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      metadata: metadata ?? this.metadata,
    );
  }

  String getOtherUserId(String currentUserId) {
    return currentUserId == swapItemOwnerId
        ? interestedUserId
        : swapItemOwnerId;
  }

  String getOtherUserName(String currentUserId) {
    return currentUserId == swapItemOwnerId
        ? interestedUserName
        : swapItemOwnerName;
  }

  String getOtherUserPhotoUrl(String currentUserId) {
    return currentUserId == swapItemOwnerId
        ? interestedUserPhotoUrl
        : swapItemOwnerPhotoUrl;
  }

  bool isUserTheOwner(String userId) {
    return userId == swapItemOwnerId;
  }
}
