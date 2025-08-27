import 'package:cloud_firestore/cloud_firestore.dart';

class RatingModel {
  final String id;
  final String swapHistoryId;
  final String raterId;
  final String raterName;
  final String raterPhotoUrl;
  final String ratedUserId;
  final String ratedUserName;
  final int rating; // 1-5 estrellas
  final String? comment;
  final DateTime createdAt;
  final Map<String, dynamic>? metadata;

  const RatingModel({
    required this.id,
    required this.swapHistoryId,
    required this.raterId,
    required this.raterName,
    required this.raterPhotoUrl,
    required this.ratedUserId,
    required this.ratedUserName,
    required this.rating,
    this.comment,
    required this.createdAt,
    this.metadata,
  });

  factory RatingModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return RatingModel(
      id: doc.id,
      swapHistoryId: data['swapHistoryId'] ?? '',
      raterId: data['raterId'] ?? '',
      raterName: data['raterName'] ?? '',
      raterPhotoUrl: data['raterPhotoUrl'] ?? '',
      ratedUserId: data['ratedUserId'] ?? '',
      ratedUserName: data['ratedUserName'] ?? '',
      rating: (data['rating'] ?? 0) as int,
      comment: data['comment'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'swapHistoryId': swapHistoryId,
      'raterId': raterId,
      'raterName': raterName,
      'raterPhotoUrl': raterPhotoUrl,
      'ratedUserId': ratedUserId,
      'ratedUserName': ratedUserName,
      'rating': rating,
      'comment': comment,
      'createdAt': Timestamp.fromDate(createdAt),
      'metadata': metadata,
    };
  }

  RatingModel copyWith({
    String? id,
    String? swapHistoryId,
    String? raterId,
    String? raterName,
    String? raterPhotoUrl,
    String? ratedUserId,
    String? ratedUserName,
    int? rating,
    String? comment,
    DateTime? createdAt,
    Map<String, dynamic>? metadata,
  }) {
    return RatingModel(
      id: id ?? this.id,
      swapHistoryId: swapHistoryId ?? this.swapHistoryId,
      raterId: raterId ?? this.raterId,
      raterName: raterName ?? this.raterName,
      raterPhotoUrl: raterPhotoUrl ?? this.raterPhotoUrl,
      ratedUserId: ratedUserId ?? this.ratedUserId,
      ratedUserName: ratedUserName ?? this.ratedUserName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      metadata: metadata ?? this.metadata,
    );
  }
}
