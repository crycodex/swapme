import 'package:cloud_firestore/cloud_firestore.dart';

class StoreItemModel {
  final String id;
  final String storeId;
  final String name;
  final String description;
  final double price;
  final String condition; // e.g., Nuevo, Bueno, etc.
  final String category; // e.g., Camisetas, Pantalones
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const StoreItemModel({
    required this.id,
    required this.storeId,
    required this.name,
    required this.description,
    required this.price,
    required this.condition,
    required this.category,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  factory StoreItemModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseDate(dynamic v) {
      if (v is Timestamp) return v.toDate();
      if (v is int) return DateTime.fromMillisecondsSinceEpoch(v);
      if (v is String) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return DateTime.now();
        }
      }
      return DateTime.now();
    }

    return StoreItemModel(
      id: id,
      storeId: map['storeId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      condition: map['condition'] as String? ?? 'Bueno',
      category: map['category'] as String? ?? 'Otros',
      imageUrl: map['imageUrl'] as String? ?? '',
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
      isActive: map['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'storeId': storeId,
      'name': name,
      'description': description,
      'price': price,
      'condition': condition,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }
}
