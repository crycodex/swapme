import 'package:cloud_firestore/cloud_firestore.dart';

enum ChatStatus { active, expired, completed, cancelled }

enum SwapDecision { pending, accepted, rejected, agreement }

class ChatModel {
  final String id;
  final String swapItemId;
  final String swapItemOwnerId;
  final String interestedUserId;
  final String swapItemName;
  final String swapItemImageUrl;
  final DateTime createdAt;
  final DateTime expiresAt;
  final ChatStatus status;
  final SwapDecision swapDecision;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final Map<String, bool> readBy;
  final bool hasUnreadMessages;

  const ChatModel({
    required this.id,
    required this.swapItemId,
    required this.swapItemOwnerId,
    required this.interestedUserId,
    required this.swapItemName,
    required this.swapItemImageUrl,
    required this.createdAt,
    required this.expiresAt,
    required this.status,
    this.swapDecision = SwapDecision.pending,
    this.lastMessage,
    this.lastMessageAt,
    this.readBy = const {},
    this.hasUnreadMessages = false,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      swapItemId: data['swapItemId'] ?? '',
      swapItemOwnerId: data['swapItemOwnerId'] ?? '',
      interestedUserId: data['interestedUserId'] ?? '',
      swapItemName: data['swapItemName'] ?? '',
      swapItemImageUrl: data['swapItemImageUrl'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiresAt:
          (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 7)),
      status: ChatStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => ChatStatus.active,
      ),
      swapDecision: SwapDecision.values.firstWhere(
        (e) => e.name == data['swapDecision'],
        orElse: () => SwapDecision.pending,
      ),
      lastMessage: data['lastMessage'],
      lastMessageAt: (data['lastMessageAt'] as Timestamp?)?.toDate(),
      readBy: Map<String, bool>.from(data['readBy'] ?? {}),
      hasUnreadMessages: data['hasUnreadMessages'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'swapItemId': swapItemId,
      'swapItemOwnerId': swapItemOwnerId,
      'interestedUserId': interestedUserId,
      'swapItemName': swapItemName,
      'swapItemImageUrl': swapItemImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'expiresAt': Timestamp.fromDate(expiresAt),
      'status': status.name,
      'swapDecision': swapDecision.name,
      'lastMessage': lastMessage,
      'lastMessageAt': lastMessageAt != null
          ? Timestamp.fromDate(lastMessageAt!)
          : null,
      'readBy': readBy,
      'hasUnreadMessages': hasUnreadMessages,
    };
  }

  ChatModel copyWith({
    String? id,
    String? swapItemId,
    String? swapItemOwnerId,
    String? interestedUserId,
    String? swapItemName,
    String? swapItemImageUrl,
    DateTime? createdAt,
    DateTime? expiresAt,
    ChatStatus? status,
    SwapDecision? swapDecision,
    String? lastMessage,
    DateTime? lastMessageAt,
    Map<String, bool>? readBy,
    bool? hasUnreadMessages,
  }) {
    return ChatModel(
      id: id ?? this.id,
      swapItemId: swapItemId ?? this.swapItemId,
      swapItemOwnerId: swapItemOwnerId ?? this.swapItemOwnerId,
      interestedUserId: interestedUserId ?? this.interestedUserId,
      swapItemName: swapItemName ?? this.swapItemName,
      swapItemImageUrl: swapItemImageUrl ?? this.swapItemImageUrl,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
      status: status ?? this.status,
      swapDecision: swapDecision ?? this.swapDecision,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      readBy: readBy ?? this.readBy,
      hasUnreadMessages: hasUnreadMessages ?? this.hasUnreadMessages,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  String getOtherUserId(String currentUserId) {
    return currentUserId == swapItemOwnerId
        ? interestedUserId
        : swapItemOwnerId;
  }
}
