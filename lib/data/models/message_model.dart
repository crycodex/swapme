import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text,
  image,
  swapProposal,
  swapAccepted,
  swapRejected,
  agreement,
  system,
}

class MessageModel {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String? senderPhotoUrl;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, dynamic>? metadata;

  const MessageModel({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    this.senderPhotoUrl,
    required this.content,
    this.type = MessageType.text,
    required this.createdAt,
    this.isRead = false,
    this.metadata,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      senderPhotoUrl: data['senderPhotoUrl'],
      content: data['content'] ?? '',
      type: MessageType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => MessageType.text,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isRead: data['isRead'] ?? false,
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'senderPhotoUrl': senderPhotoUrl,
      'content': content,
      'type': type.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'metadata': metadata,
    };
  }

  MessageModel copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? senderPhotoUrl,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    bool? isRead,
    Map<String, dynamic>? metadata,
  }) {
    return MessageModel(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderPhotoUrl: senderPhotoUrl ?? this.senderPhotoUrl,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      metadata: metadata ?? this.metadata,
    );
  }

  bool get isSwapRelated => [
    MessageType.swapProposal,
    MessageType.swapAccepted,
    MessageType.swapRejected,
    MessageType.agreement,
  ].contains(type);
}
