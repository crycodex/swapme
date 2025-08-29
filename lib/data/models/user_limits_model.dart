class UserLimitsModel {
  final String id;
  final String userId;
  final int totalSwaps;
  final int maxSwaps;
  final bool isPremium;
  final bool canCreateStore;
  final bool hasAds;

  UserLimitsModel({
    required this.id,
    required this.userId,
    required this.totalSwaps,
    required this.maxSwaps,
    required this.isPremium,
    required this.canCreateStore,
    required this.hasAds,
  });

  factory UserLimitsModel.fromJson(Map<String, dynamic> json) {
    final bool isPremium = json['isPremium'] ?? false;
    final int maxSwaps = isPremium ? -1 : 3; // -1 significa ilimitado

    return UserLimitsModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      totalSwaps: json['totalSwaps'] ?? 0,
      maxSwaps: maxSwaps,
      isPremium: isPremium,
      canCreateStore: isPremium, // Solo premium pueden crear tienda
      hasAds: !isPremium, // Solo free tienen anuncios
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'totalSwaps': totalSwaps,
      'isPremium': isPremium,
      'canCreateStore': canCreateStore,
      'hasAds': hasAds,
    };
  }

  // Métodos para verificar límites
  bool get canSwap => isPremium || totalSwaps < maxSwaps;
  bool get hasReachedSwapLimit => !isPremium && totalSwaps >= maxSwaps;
  int get remainingSwaps => isPremium ? -1 : (maxSwaps - totalSwaps);
}
