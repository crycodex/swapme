import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String photoUrl;
  final String userType;
  final String theme;
  final String language;
  final List<String> interests;
  final Timestamp? createdAt;
  final int totalSwaps;
  final double averageRating;
  final int totalRatings;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.userType,
    required this.theme,
    required this.language,
    required this.interests,
    this.createdAt,
    this.totalSwaps = 0,
    this.averageRating = 0.0,
    this.totalRatings = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: (json['UID'] ?? json['uid'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      photoUrl: (json['photoUrl'] ?? '').toString(),
      userType: (json['userType'] ?? 'free').toString(),
      theme: (json['theme'] ?? '').toString(),
      language: (json['language'] ?? '').toString(),
      interests: (json['interests'] ?? []).cast<String>(),
      createdAt: json['createdAt'] is Timestamp
          ? json['createdAt'] as Timestamp
          : null,
      totalSwaps: (json['totalSwaps'] ?? 0) as int,
      averageRating: (json['averageRating'] ?? 0.0) as double,
      totalRatings: (json['totalRatings'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'UID': uid,
      'name': name,
      'email': email.toLowerCase(),
      'photoUrl': photoUrl,
      'userType': userType,
      'theme': theme,
      'language': language,
      'interests': interests,
      'createdAt': createdAt,
      'totalSwaps': totalSwaps,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
    };
  }

  String get ratingStars {
    if (totalRatings == 0) return 'Sin calificaciones';
    return '${averageRating.toStringAsFixed(1)} ⭐ ($totalRatings)';
  }

  bool get hasGoodRating => averageRating >= 4.0 && totalRatings >= 3;
  bool get hasExcellentRating => averageRating >= 4.5 && totalRatings >= 5;
}
