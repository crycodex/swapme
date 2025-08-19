import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../../data/models/swap_history_model.dart';
import '../../data/models/rating_model.dart';
import '../../data/models/user_stats_model.dart';
import '../../data/models/chat_model.dart';
import '../../data/models/user_model.dart';

class SwapHistoryController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxList<SwapHistoryModel> swapHistory = <SwapHistoryModel>[].obs;
  final RxList<RatingModel> userRatings = <RatingModel>[].obs;
  final Rx<UserStatsModel?> userStats = Rx<UserStatsModel?>(null);
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  String? get currentUserId => _auth.currentUser?.uid;

  @override
  void onInit() {
    super.onInit();
    if (currentUserId != null) {
      loadUserSwapHistory();
      loadUserStats();
    }
  }

  Future<void> loadUserSwapHistory() async {
    if (currentUserId == null) return;

    isLoading.value = true;
    error.value = '';

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('swap_history')
          .where('participants', arrayContains: currentUserId)
          .orderBy('completedAt', descending: true)
          .get();

      final List<SwapHistoryModel> history = snapshot.docs
          .map((doc) => SwapHistoryModel.fromFirestore(doc))
          .toList();

      swapHistory.value = history;
    } catch (e) {
      error.value = 'Error cargando historial: $e';
      debugPrint('Error cargando historial de intercambios: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadUserStats() async {
    if (currentUserId == null) return;

    try {
      final DocumentSnapshot doc = await _firestore
          .collection('user_stats')
          .doc(currentUserId)
          .get();

      if (doc.exists) {
        userStats.value = UserStatsModel.fromFirestore(doc);
      } else {
        // Crear estadísticas iniciales si no existen
        await _createInitialStats();
      }
    } catch (e) {
      debugPrint('Error cargando estadísticas del usuario: $e');
    }
  }

  Future<void> _createInitialStats() async {
    if (currentUserId == null) return;

    try {
      final UserStatsModel initialStats = UserStatsModel(
        userId: currentUserId!,
        totalSwaps: 0,
        averageRating: 0.0,
        totalRatings: 0,
        lastUpdated: DateTime.now(),
      );

      await _firestore
          .collection('user_stats')
          .doc(currentUserId)
          .set(initialStats.toFirestore());

      userStats.value = initialStats;
    } catch (e) {
      debugPrint('Error creando estadísticas iniciales: $e');
    }
  }

  Future<DocumentSnapshot> _getOrCreateUserDocument(String userId) async {
    try {
      final DocumentSnapshot userDoc = await _firestore
          .collection('users')
          .doc(userId)
          .get();

      if (userDoc.exists) {
        // Verificar que el documento tenga los campos necesarios
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
        bool needsUpdate = false;

        // Verificar y agregar campos faltantes
        if (!userData.containsKey('totalSwaps')) {
          userData['totalSwaps'] = 0;
          needsUpdate = true;
        }
        if (!userData.containsKey('averageRating')) {
          userData['averageRating'] = 0.0;
          needsUpdate = true;
        }
        if (!userData.containsKey('totalRatings')) {
          userData['totalRatings'] = 0;
          needsUpdate = true;
        }
        if (!userData.containsKey('name')) {
          userData['name'] = 'Usuario';
          needsUpdate = true;
        }
        if (!userData.containsKey('photoUrl')) {
          userData['photoUrl'] = '';
          needsUpdate = true;
        }

        // Actualizar el documento si es necesario
        if (needsUpdate) {
          await _firestore.collection('users').doc(userId).update(userData);
          // Obtener el documento actualizado
          return await _firestore.collection('users').doc(userId).get();
        }

        return userDoc;
      } else {
        // Crear un documento de usuario básico si no existe
        final Map<String, dynamic> basicUserData = {
          'UID': userId,
          'name': 'Usuario',
          'email': '$userId@example.com',
          'photoUrl': '',
          'userType': 'free',
          'theme': '',
          'language': 'es',
          'interests': [],
          'totalSwaps': 0,
          'averageRating': 0.0,
          'totalRatings': 0,
          'createdAt': FieldValue.serverTimestamp(),
        };

        await _firestore.collection('users').doc(userId).set(basicUserData);

        return await _firestore.collection('users').doc(userId).get();
      }
    } catch (e) {
      debugPrint('Error obteniendo/creando documento de usuario $userId: $e');
      throw Exception('No se pudo obtener información del usuario');
    }
  }

  Future<void> _ensureRequiredDocumentsExist(ChatModel chat) async {
    try {
      // Asegurar que los usuarios existan
      await _getOrCreateUserDocument(chat.swapItemOwnerId);
      await _getOrCreateUserDocument(chat.interestedUserId);

      // Asegurar que las estadísticas de usuarios existan
      await _ensureUserStatsExist(chat.swapItemOwnerId);
      await _ensureUserStatsExist(chat.interestedUserId);

      debugPrint('Documentos requeridos validados correctamente');
    } catch (e) {
      debugPrint('Error asegurando documentos requeridos: $e');
      throw Exception('Error preparando documentos para el intercambio');
    }
  }

  Future<void> _ensureUserStatsExist(String userId) async {
    try {
      final DocumentSnapshot statsDoc = await _firestore
          .collection('user_stats')
          .doc(userId)
          .get();

      if (!statsDoc.exists) {
        final UserStatsModel initialStats = UserStatsModel(
          userId: userId,
          totalSwaps: 0,
          averageRating: 0.0,
          totalRatings: 0,
          lastUpdated: DateTime.now(),
        );

        await _firestore
            .collection('user_stats')
            .doc(userId)
            .set(initialStats.toFirestore());

        debugPrint('Estadísticas iniciales creadas para usuario: $userId');
      }
    } catch (e) {
      debugPrint('Error creando estadísticas para usuario $userId: $e');
    }
  }

  Future<bool> confirmSwap({
    required String chatId,
    required ChatModel chat,
    String? notes,
  }) async {
    if (currentUserId == null) return false;

    // Limpiar errores previos
    error.value = '';

    try {
      // Pre-validar y crear documentos necesarios
      await _ensureRequiredDocumentsExist(chat);

      // Obtener información de los usuarios con creación automática si no existen
      final DocumentSnapshot ownerDoc = await _getOrCreateUserDocument(
        chat.swapItemOwnerId,
      );
      final DocumentSnapshot interestedDoc = await _getOrCreateUserDocument(
        chat.interestedUserId,
      );

      final UserModel owner = UserModel.fromJson(
        ownerDoc.data() as Map<String, dynamic>,
      );
      final UserModel interested = UserModel.fromJson(
        interestedDoc.data() as Map<String, dynamic>,
      );

      // Crear el registro del historial
      final SwapHistoryModel swapHistory = SwapHistoryModel(
        id: '',
        chatId: chatId,
        swapItemId: chat.swapItemId,
        swapItemName: chat.swapItemName,
        swapItemImageUrl: chat.swapItemImageUrl,
        swapItemOwnerId: chat.swapItemOwnerId,
        swapItemOwnerName: owner.name,
        swapItemOwnerPhotoUrl: owner.photoUrl,
        interestedUserId: chat.interestedUserId,
        interestedUserName: interested.name,
        interestedUserPhotoUrl: interested.photoUrl,
        completedAt: DateTime.now(),
        status: SwapHistoryStatus.completed,
        notes: notes,
      );

      // Usar transacción para asegurar consistencia
      await _firestore.runTransaction((transaction) async {
        // FASE 1: TODAS LAS LECTURAS PRIMERO
        final DocumentReference swapItemRef = _firestore
            .collection('swap_items')
            .doc(chat.swapItemId);

        final DocumentReference ownerStatsRef = _firestore
            .collection('user_stats')
            .doc(chat.swapItemOwnerId);

        final DocumentReference interestedStatsRef = _firestore
            .collection('user_stats')
            .doc(chat.interestedUserId);

        final DocumentReference ownerUserRef = _firestore
            .collection('users')
            .doc(chat.swapItemOwnerId);

        final DocumentReference interestedUserRef = _firestore
            .collection('users')
            .doc(chat.interestedUserId);

        // Realizar todas las lecturas
        final List<Future<DocumentSnapshot>> reads = [
          transaction.get(swapItemRef),
          transaction.get(ownerStatsRef),
          transaction.get(interestedStatsRef),
          transaction.get(ownerUserRef),
          transaction.get(interestedUserRef),
        ];

        final List<DocumentSnapshot> docs = await Future.wait(reads);
        final DocumentSnapshot swapItemDoc = docs[0];
        final DocumentSnapshot ownerStatsDoc = docs[1];
        final DocumentSnapshot interestedStatsDoc = docs[2];
        final DocumentSnapshot ownerUserDoc = docs[3];
        final DocumentSnapshot interestedUserDoc = docs[4];

        // FASE 2: TODAS LAS ESCRITURAS DESPUÉS

        // Crear el historial
        final DocumentReference historyRef = _firestore
            .collection('swap_history')
            .doc();
        transaction.set(historyRef, swapHistory.toFirestore());

        // Actualizar el chat como completado
        final DocumentReference chatRef = _firestore
            .collection('chats')
            .doc(chatId);
        transaction.update(chatRef, {
          'status': ChatStatus.completed.name,
          'completedAt': Timestamp.fromDate(DateTime.now()),
        });

        // Marcar el artículo de intercambio como no disponible (si existe)
        if (swapItemDoc.exists) {
          transaction.update(swapItemRef, {
            'isAvailable': false,
            'completedAt': Timestamp.fromDate(DateTime.now()),
          });
        } else {
          debugPrint(
            'Advertencia: El artículo de intercambio ${chat.swapItemId} no existe',
          );
        }

        // Actualizar estadísticas de usuarios
        _updateUserStatsWithReadData(
          transaction,
          chat.swapItemOwnerId,
          ownerStatsDoc,
          ownerUserDoc,
          ownerStatsRef,
          ownerUserRef,
        );

        _updateUserStatsWithReadData(
          transaction,
          chat.interestedUserId,
          interestedStatsDoc,
          interestedUserDoc,
          interestedStatsRef,
          interestedUserRef,
        );
      });

      // Recargar el historial después de la confirmación
      await loadUserSwapHistory();
      await loadUserStats();

      return true;
    } catch (e) {
      String errorMessage = 'Error confirmando intercambio';

      if (e.toString().contains('not-found')) {
        errorMessage =
            'Algunos documentos no fueron encontrados. Se han creado automáticamente. Intenta de nuevo.';
      } else if (e.toString().contains('permission-denied')) {
        errorMessage = 'No tienes permisos para realizar esta acción';
      } else if (e.toString().contains('network-request-failed')) {
        errorMessage = 'Error de conexión. Verifica tu internet';
      } else {
        errorMessage = 'Error inesperado: ${e.toString()}';
      }

      error.value = errorMessage;
      debugPrint('Error confirmando intercambio: $e');
      return false;
    }
  }

  void _updateUserStatsWithReadData(
    Transaction transaction,
    String userId,
    DocumentSnapshot statsDoc,
    DocumentSnapshot userDoc,
    DocumentReference userStatsRef,
    DocumentReference userRef,
  ) {
    try {
      // Actualizar estadísticas
      if (statsDoc.exists) {
        // Actualizar estadísticas existentes
        final UserStatsModel currentStats = UserStatsModel.fromFirestore(
          statsDoc,
        );
        final UserStatsModel updatedStats = currentStats.copyWith(
          totalSwaps: currentStats.totalSwaps + 1,
          lastUpdated: DateTime.now(),
        );
        transaction.update(userStatsRef, updatedStats.toFirestore());
      } else {
        // Crear estadísticas iniciales
        final UserStatsModel initialStats = UserStatsModel(
          userId: userId,
          totalSwaps: 1,
          averageRating: 0.0,
          totalRatings: 0,
          lastUpdated: DateTime.now(),
        );
        transaction.set(userStatsRef, initialStats.toFirestore());
      }

      // Actualizar documento del usuario
      if (userDoc.exists) {
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;

        // Asegurar que el documento tenga los campos necesarios
        final int currentSwaps = userData['totalSwaps'] ?? 0;
        userData['totalSwaps'] = currentSwaps + 1;

        // Asegurar que otros campos existan
        userData['averageRating'] = userData['averageRating'] ?? 0.0;
        userData['totalRatings'] = userData['totalRatings'] ?? 0;

        transaction.update(userRef, userData);
      } else {
        // Crear documento de usuario básico si no existe
        final Map<String, dynamic> basicUserData = {
          'UID': userId,
          'name': 'Usuario',
          'email': '$userId@example.com',
          'photoUrl': '',
          'userType': 'free',
          'theme': '',
          'language': 'es',
          'interests': [],
          'totalSwaps': 1,
          'averageRating': 0.0,
          'totalRatings': 0,
          'createdAt': FieldValue.serverTimestamp(),
        };
        transaction.set(userRef, basicUserData);
      }
    } catch (e) {
      debugPrint('Error actualizando estadísticas del usuario $userId: $e');
    }
  }

  Future<bool> rateUser({
    required String swapHistoryId,
    required String ratedUserId,
    required int rating,
    String? comment,
  }) async {
    if (currentUserId == null || rating < 1 || rating > 5) return false;

    // Limpiar errores previos
    error.value = '';

    try {
      // Verificar que no se haya calificado ya a este usuario para este intercambio
      final QuerySnapshot existingRating = await _firestore
          .collection('ratings')
          .where('swapHistoryId', isEqualTo: swapHistoryId)
          .where('raterId', isEqualTo: currentUserId)
          .where('ratedUserId', isEqualTo: ratedUserId)
          .limit(1)
          .get();

      if (existingRating.docs.isNotEmpty) {
        error.value = 'Ya has calificado a este usuario para este intercambio';
        return false;
      }

      // Obtener información de los usuarios con creación automática si no existen
      final DocumentSnapshot raterDoc = await _getOrCreateUserDocument(
        currentUserId!,
      );
      final DocumentSnapshot ratedDoc = await _getOrCreateUserDocument(
        ratedUserId,
      );

      final UserModel rater = UserModel.fromJson(
        raterDoc.data() as Map<String, dynamic>,
      );
      final UserModel rated = UserModel.fromJson(
        ratedDoc.data() as Map<String, dynamic>,
      );

      // Crear la calificación
      final RatingModel newRating = RatingModel(
        id: '',
        swapHistoryId: swapHistoryId,
        raterId: currentUserId!,
        raterName: rater.name,
        raterPhotoUrl: rater.photoUrl,
        ratedUserId: ratedUserId,
        ratedUserName: rated.name,
        rating: rating,
        comment: comment,
        createdAt: DateTime.now(),
      );

      // Obtener las calificaciones del usuario ANTES de la transacción
      final QuerySnapshot ratingsSnapshot = await _firestore
          .collection('ratings')
          .where('ratedUserId', isEqualTo: ratedUserId)
          .get();

      await _firestore.runTransaction((transaction) async {
        // FASE 1: TODAS LAS LECTURAS PRIMERO
        final DocumentReference userStatsRef = _firestore
            .collection('user_stats')
            .doc(ratedUserId);

        final DocumentReference userRef = _firestore
            .collection('users')
            .doc(ratedUserId);

        final List<Future<DocumentSnapshot>> reads = [
          transaction.get(userStatsRef),
          transaction.get(userRef),
        ];

        final List<DocumentSnapshot> docs = await Future.wait(reads);
        final DocumentSnapshot statsDoc = docs[0];
        final DocumentSnapshot userDoc = docs[1];

        // FASE 2: TODAS LAS ESCRITURAS DESPUÉS

        // Crear la calificación
        final DocumentReference ratingRef = _firestore
            .collection('ratings')
            .doc();
        transaction.set(ratingRef, newRating.toFirestore());

        // Actualizar las estadísticas del usuario calificado
        _updateUserRatingStatsWithReadData(
          transaction,
          ratedUserId,
          rating,
          ratingsSnapshot,
          statsDoc,
          userDoc,
          userStatsRef,
          userRef,
        );
      });

      return true;
    } catch (e) {
      error.value = 'Error guardando calificación: $e';
      debugPrint('Error guardando calificación: $e');
      return false;
    }
  }

  void _updateUserRatingStatsWithReadData(
    Transaction transaction,
    String userId,
    int newRating,
    QuerySnapshot ratingsSnapshot,
    DocumentSnapshot statsDoc,
    DocumentSnapshot userDoc,
    DocumentReference userStatsRef,
    DocumentReference userRef,
  ) {
    try {
      // Calcular el nuevo promedio con los datos leídos
      final int totalRatings =
          ratingsSnapshot.docs.length + 1; // +1 por la nueva calificación
      double totalRatingSum = newRating.toDouble();

      for (final QueryDocumentSnapshot doc in ratingsSnapshot.docs) {
        final RatingModel rating = RatingModel.fromFirestore(doc);
        totalRatingSum += rating.rating;
      }

      final double averageRating = totalRatingSum / totalRatings;

      // Actualizar estadísticas del usuario
      if (statsDoc.exists) {
        final UserStatsModel currentStats = UserStatsModel.fromFirestore(
          statsDoc,
        );
        final UserStatsModel updatedStats = currentStats.copyWith(
          averageRating: averageRating,
          totalRatings: totalRatings,
          lastUpdated: DateTime.now(),
        );
        transaction.update(userStatsRef, updatedStats.toFirestore());
      } else {
        // Crear estadísticas si no existen
        final UserStatsModel newStats = UserStatsModel(
          userId: userId,
          totalSwaps: 0,
          averageRating: averageRating,
          totalRatings: totalRatings,
          lastUpdated: DateTime.now(),
        );
        transaction.set(userStatsRef, newStats.toFirestore());
      }

      // También actualizar el documento del usuario
      if (userDoc.exists) {
        final Map<String, dynamic> userData =
            userDoc.data() as Map<String, dynamic>;
        userData['averageRating'] = averageRating;
        userData['totalRatings'] = totalRatings;

        // Asegurar que otros campos existan
        userData['totalSwaps'] = userData['totalSwaps'] ?? 0;
        userData['name'] = userData['name'] ?? 'Usuario';
        userData['photoUrl'] = userData['photoUrl'] ?? '';

        transaction.update(userRef, userData);
      } else {
        // Crear documento de usuario básico si no existe
        final Map<String, dynamic> basicUserData = {
          'UID': userId,
          'name': 'Usuario',
          'email': '$userId@example.com',
          'photoUrl': '',
          'userType': 'free',
          'theme': '',
          'language': 'es',
          'interests': [],
          'totalSwaps': 0,
          'averageRating': averageRating,
          'totalRatings': totalRatings,
          'createdAt': FieldValue.serverTimestamp(),
        };
        transaction.set(userRef, basicUserData);
      }
    } catch (e) {
      debugPrint('Error actualizando estadísticas de calificación: $e');
    }
  }

  Future<bool> hasUserRated(String swapHistoryId, String ratedUserId) async {
    if (currentUserId == null) return false;

    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('ratings')
          .where('swapHistoryId', isEqualTo: swapHistoryId)
          .where('raterId', isEqualTo: currentUserId)
          .where('ratedUserId', isEqualTo: ratedUserId)
          .limit(1)
          .get();

      return snapshot.docs.isNotEmpty;
    } catch (e) {
      debugPrint('Error verificando si el usuario ya calificó: $e');
      return false;
    }
  }

  Future<List<RatingModel>> getUserRatings(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('ratings')
          .where('ratedUserId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => RatingModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      debugPrint('Error obteniendo calificaciones del usuario: $e');
      return [];
    }
  }

  int get totalSwapsCount => swapHistory.length;

  List<SwapHistoryModel> get completedSwaps => swapHistory
      .where((swap) => swap.status == SwapHistoryStatus.completed)
      .toList();

  List<SwapHistoryModel> get cancelledSwaps => swapHistory
      .where((swap) => swap.status == SwapHistoryStatus.cancelled)
      .toList();
}
