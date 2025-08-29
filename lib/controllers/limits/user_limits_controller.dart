import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/models/user_limits_model.dart';

class UserLimitsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final Rx<UserLimitsModel?> userLimits = Rx<UserLimitsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserLimits();
  }

  Future<void> loadUserLimits() async {
    try {
      isLoading.value = true;
      error.value = '';

      final User? currentUser = _auth.currentUser;
      if (currentUser == null) {
        error.value = 'Usuario no autenticado';
        return;
      }

      // Buscar en la colección userLimits
      final QuerySnapshot limitsSnapshot = await _firestore
          .collection('userLimits')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      if (limitsSnapshot.docs.isNotEmpty) {
        // Si existe un documento de límites, usarlo
        final doc = limitsSnapshot.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        data['userId'] = currentUser.uid;

        userLimits.value = UserLimitsModel.fromJson(data);
      } else {
        // Si no existe, crear uno por defecto (free)
        await _createDefaultUserLimits(currentUser.uid);
      }
    } catch (e) {
      error.value = 'Error al cargar límites: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _createDefaultUserLimits(String userId) async {
    try {

      final docRef = await _firestore.collection('userLimits').add({
        'userId': userId,
        'totalSwaps': 0,
        'isPremium': false,
        'canCreateStore': false,
        'hasAds': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Actualizar el modelo con el ID generado
      userLimits.value = UserLimitsModel(
        id: docRef.id,
        userId: userId,
        totalSwaps: 0,
        maxSwaps: 3,
        isPremium: false,
        canCreateStore: false,
        hasAds: true,
      );
    } catch (e) {
      error.value = 'Error al crear límites por defecto: $e';
    }
  }

  // Verificar si el usuario puede hacer swap
  bool canUserSwap() {
    return userLimits.value?.canSwap ?? false;
  }

  // Verificar si el usuario puede crear tienda
  bool canUserCreateStore() {
    return userLimits.value?.canCreateStore ?? false;
  }

  // Verificar si el usuario tiene anuncios
  bool userHasAds() {
    return userLimits.value?.hasAds ?? true;
  }

  // Incrementar el contador de swaps
  Future<bool> incrementSwaps() async {
    try {
      if (!canUserSwap()) {
        error.value = 'Has alcanzado el límite de swaps';
        return false;
      }

      final currentLimits = userLimits.value;
      if (currentLimits == null) return false;

      final newTotalSwaps = currentLimits.totalSwaps + 1;

      await _firestore.collection('userLimits').doc(currentLimits.id).update({
        'totalSwaps': newTotalSwaps,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Actualizar el modelo local
      userLimits.value = UserLimitsModel(
        id: currentLimits.id,
        userId: currentLimits.userId,
        totalSwaps: newTotalSwaps,
        maxSwaps: currentLimits.maxSwaps,
        isPremium: currentLimits.isPremium,
        canCreateStore: currentLimits.canCreateStore,
        hasAds: currentLimits.hasAds,
      );

      return true;
    } catch (e) {
      error.value = 'Error al incrementar swaps: $e';
      return false;
    }
  }

  // Actualizar estado premium del usuario
  Future<bool> updatePremiumStatus(bool isPremium) async {
    try {
      final currentLimits = userLimits.value;
      if (currentLimits == null) return false;

      await _firestore.collection('userLimits').doc(currentLimits.id).update({
        'isPremium': isPremium,
        'canCreateStore': isPremium,
        'hasAds': !isPremium,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Actualizar el modelo local
      userLimits.value = UserLimitsModel(
        id: currentLimits.id,
        userId: currentLimits.userId,
        totalSwaps: currentLimits.totalSwaps,
        maxSwaps: isPremium ? -1 : 3,
        isPremium: isPremium,
        canCreateStore: isPremium,
        hasAds: !isPremium,
      );

      return true;
    } catch (e) {
      error.value = 'Error al actualizar estado premium: $e';
      return false;
    }
  }

  // Obtener swaps restantes
  int getRemainingSwaps() {
    return userLimits.value?.remainingSwaps ?? 0;
  }

  // Verificar si ha alcanzado el límite
  bool hasReachedLimit() {
    return userLimits.value?.hasReachedSwapLimit ?? false;
  }

  // Limpiar error
  void clearError() {
    error.value = '';
  }
}
