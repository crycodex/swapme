import 'package:cloud_firestore/cloud_firestore.dart';

class SwapItemModel {
  final String id;
  final String userId;
  final String name;
  final String description;
  final String size;
  final double estimatedPrice;
  final String condition;
  final String imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isActive;

  const SwapItemModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.description,
    required this.size,
    required this.estimatedPrice,
    required this.condition,
    required this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'description': description,
      'size': size,
      'estimatedPrice': estimatedPrice,
      'condition': condition,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isActive': isActive,
    };
  }

  factory SwapItemModel.fromMap(Map<String, dynamic> map) {
    return SwapItemModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      size: map['size'] ?? '',
      estimatedPrice: (map['estimatedPrice'] ?? 0.0).toDouble(),
      condition: map['condition'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  SwapItemModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? size,
    double? estimatedPrice,
    String? condition,
    String? imageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return SwapItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      size: size ?? this.size,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }
}
