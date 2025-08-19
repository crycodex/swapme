import 'package:cloud_firestore/cloud_firestore.dart';

class UserStatsModel {
  final String userId;
  final int totalSwaps;
  final double averageRating;
  final int totalRatings;
  final DateTime lastUpdated;
  final Map<String, dynamic>? metadata;

  const UserStatsModel({
    required this.userId,
    required this.totalSwaps,
    required this.averageRating,
    required this.totalRatings,
    required this.lastUpdated,
    this.metadata,
  });

  factory UserStatsModel.fromFirestore(DocumentSnapshot doc) {
    final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserStatsModel(
      userId: doc.id,
      totalSwaps: (data['totalSwaps'] ?? 0) as int,
      averageRating: (data['averageRating'] ?? 0.0) as double,
      totalRatings: (data['totalRatings'] ?? 0) as int,
      lastUpdated:
          (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      metadata: data['metadata'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'totalSwaps': totalSwaps,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'metadata': metadata,
    };
  }

  UserStatsModel copyWith({
    String? userId,
    int? totalSwaps,
    double? averageRating,
    int? totalRatings,
    DateTime? lastUpdated,
    Map<String, dynamic>? metadata,
  }) {
    return UserStatsModel(
      userId: userId ?? this.userId,
      totalSwaps: totalSwaps ?? this.totalSwaps,
      averageRating: averageRating ?? this.averageRating,
      totalRatings: totalRatings ?? this.totalRatings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      metadata: metadata ?? this.metadata,
    );
  }

  String get ratingStars {
    if (totalRatings == 0) return 'Sin calificaciones';
    return '${averageRating.toStringAsFixed(1)} ⭐ ($totalRatings)';
  }

  bool get hasGoodRating => averageRating >= 4.0 && totalRatings >= 3;
  bool get hasExcellentRating => averageRating >= 4.5 && totalRatings >= 5;
}
