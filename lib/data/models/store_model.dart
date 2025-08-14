import 'package:cloud_firestore/cloud_firestore.dart';

class StoreModel {
  final String id;
  final String ownerId;
  final String name;
  final String description;
  final String bannerUrl;
  final String logoUrl;
  final double rating;
  final int itemsCount;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const StoreModel({
    required this.id,
    required this.ownerId,
    required this.name,
    required this.description,
    required this.bannerUrl,
    required this.logoUrl,
    required this.rating,
    required this.itemsCount,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory StoreModel.fromMap(Map<String, dynamic> map, String id) {
    return StoreModel(
      id: id,
      ownerId: map['ownerId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      bannerUrl: map['bannerUrl'] as String? ?? '',
      logoUrl: map['logoUrl'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      itemsCount: (map['itemsCount'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'ownerId': ownerId,
      'name': name,
      'description': description,
      'bannerUrl': bannerUrl,
      'logoUrl': logoUrl,
      'rating': rating,
      'itemsCount': itemsCount,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
