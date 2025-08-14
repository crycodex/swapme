import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/store_model.dart';
import '../../data/models/store_item_model.dart';

class StoreController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Form
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final Rx<File?> bannerImage = Rx<File?>(null);
  final Rx<File?> logoImage = Rx<File?>(null);
  final RxBool isLoading = false.obs;
  final RxnString editingStoreId = RxnString();

  // Store item form
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController itemDescriptionController =
      TextEditingController();
  final TextEditingController itemPriceController = TextEditingController();
  final Rx<File?> selectedItemImage = Rx<File?>(null);
  final RxString selectedItemCondition = 'Nuevo'.obs;
  final RxString selectedItemCategory = 'Otros'.obs;
  final Rxn<StoreItemModel> editingStoreItem = Rxn<StoreItemModel>();

  // Available options for store items
  final List<String> conditions = [
    'Nuevo',
    'Como nuevo',
    'Muy bueno',
    'Bueno',
    'Regular',
  ];
  final List<String> itemCategories = [
    'Camisetas',
    'Pantalones',
    'Chaquetas',
    'Calzado',
    'Accesorios',
    'Otros',
  ];

  // Pickers para banner y logo desde galería
  Future<void> pickBannerFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1440,
      );
      if (file != null) bannerImage.value = File(file.path);
    } catch (_) {
      Get.snackbar('Error', 'No se pudo seleccionar el banner');
    }
  }

  Future<void> pickLogoFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? file = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (file != null) logoImage.value = File(file.path);
    } catch (_) {
      Get.snackbar('Error', 'No se pudo seleccionar el logo');
    }
  }

  // Listeners/Streams
  Stream<List<StoreModel>> getStores() {
    return _firestore
        .collection('stores')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((QuerySnapshot snapshot) async {
          final List<StoreModel> stores = [];

          for (final QueryDocumentSnapshot doc in snapshot.docs) {
            final Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;

            // Obtener el conteo real de items para cada tienda
            final QuerySnapshot itemsSnapshot = await _firestore
                .collection('stores')
                .doc(doc.id)
                .collection('items')
                .where('isActive', isEqualTo: true)
                .get();

            final int actualItemsCount = itemsSnapshot.docs.length;

            // Actualizar el conteo en el documento si es diferente
            final int storedItemsCount = data['itemsCount'] as int? ?? 0;
            if (actualItemsCount != storedItemsCount) {
              _firestore.collection('stores').doc(doc.id).update(
                <String, dynamic>{'itemsCount': actualItemsCount},
              );
            }

            // Crear el modelo con el conteo actualizado
            final Map<String, dynamic> updatedData = <String, dynamic>{
              ...data,
              'itemsCount': actualItemsCount,
            };

            stores.add(StoreModel.fromMap(updatedData, doc.id));
          }

          return stores;
        });
  }

  Stream<StoreModel?> getMyStore() {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return Stream<StoreModel?>.value(null);
    return _firestore
        .collection('stores')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((QuerySnapshot snap) {
          if (snap.docs.isEmpty) return null;
          final QueryDocumentSnapshot doc = snap.docs.first;
          final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return StoreModel.fromMap(data, doc.id);
        });
  }

  Future<StoreModel?> fetchStoreById(String id) async {
    final DocumentSnapshot<Map<String, dynamic>> doc = await _firestore
        .collection('stores')
        .doc(id)
        .get();
    if (!doc.exists) return null;
    return StoreModel.fromMap(doc.data()!, doc.id);
  }

  Future<StoreModel?> getMyStoreOnce() async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final QuerySnapshot<Map<String, dynamic>> snap = await _firestore
        .collection('stores')
        .where('ownerId', isEqualTo: uid)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final QueryDocumentSnapshot<Map<String, dynamic>> doc = snap.docs.first;
    return StoreModel.fromMap(doc.data(), doc.id);
  }

  bool isOwner(StoreModel store) {
    return _auth.currentUser?.uid == store.ownerId;
  }

  Future<void> createOrUpdateStore({String? storeId}) async {
    final String? uid = _auth.currentUser?.uid;
    if (uid == null) {
      Get.snackbar('Error', 'Debes iniciar sesión');
      return;
    }
    if (nameController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {
      Get.snackbar('Datos incompletos', 'Nombre y descripción son requeridos');
      return;
    }

    try {
      isLoading.value = true;

      // Verificar si el usuario ya tiene una tienda (solo para creación)
      if (storeId == null) {
        final StoreModel? existingStore = await getMyStoreOnce();
        if (existingStore != null) {
          Get.snackbar(
            'Error',
            'Ya tienes una tienda creada. Solo puedes tener una tienda por usuario.',
          );
          return;
        }
      }

      String bannerUrl = '';
      String logoUrl = '';
      if (bannerImage.value != null) {
        final String file =
            'stores/$uid/banner_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final UploadTask up = _storage.ref(file).putFile(bannerImage.value!);
        final TaskSnapshot snap = await up;
        bannerUrl = await snap.ref.getDownloadURL();
      }
      if (logoImage.value != null) {
        final String file =
            'stores/$uid/logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final UploadTask up = _storage.ref(file).putFile(logoImage.value!);
        final TaskSnapshot snap = await up;
        logoUrl = await snap.ref.getDownloadURL();
      }

      final DateTime now = DateTime.now();

      if (storeId == null) {
        // Crear nueva tienda
        await _firestore.collection('stores').add(<String, dynamic>{
          'ownerId': uid,
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
          if (bannerUrl.isNotEmpty) 'bannerUrl': bannerUrl,
          if (logoUrl.isNotEmpty) 'logoUrl': logoUrl,
          'rating': 4.5, // Rating inicial
          'itemsCount': 0, // Se actualizará automáticamente
          'isActive': true,
          'createdAt': Timestamp.fromDate(now),
          'updatedAt': Timestamp.fromDate(now),
        });
        Get.back();
        Get.snackbar('Éxito', 'Tienda creada');
      } else {
        // Actualizar tienda existente (no cambiar rating ni itemsCount)
        final Map<String, dynamic> updateData = <String, dynamic>{
          'name': nameController.text.trim(),
          'description': descriptionController.text.trim(),
          if (bannerUrl.isNotEmpty) 'bannerUrl': bannerUrl,
          if (logoUrl.isNotEmpty) 'logoUrl': logoUrl,
          'updatedAt': Timestamp.fromDate(now),
        };
        await _firestore
            .collection('stores')
            .doc(storeId)
            .set(updateData, SetOptions(merge: true));
        Get.back();
        Get.snackbar('Éxito', 'Tienda actualizada');
      }
    } catch (_) {
      Get.snackbar('Error', 'No se pudo guardar la tienda');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStore(String storeId) async {
    try {
      await _firestore.collection('stores').doc(storeId).delete();
      Get.snackbar('Eliminada', 'Tienda eliminada');
    } catch (_) {
      Get.snackbar('Error', 'No se pudo eliminar la tienda');
    }
  }

  // Items propios de la tienda
  Stream<List<StoreItemModel>> getItemsByStore(String storeId) {
    return _firestore
        .collection('stores')
        .doc(storeId)
        .collection('items')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot snap) {
          return snap.docs.map((QueryDocumentSnapshot doc) {
            final Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;
            return StoreItemModel.fromMap(data, doc.id);
          }).toList();
        });
  }

  Future<void> createOrUpdateStoreItem({
    required String storeId,
    StoreItemModel? editing,
    required String name,
    required String description,
    required double price,
    required String condition,
    required String category,
    File? imageFile,
  }) async {
    try {
      isLoading.value = true;
      String imageUrl = editing?.imageUrl ?? '';
      if (imageFile != null) {
        final String path =
            'stores/$storeId/items/${DateTime.now().millisecondsSinceEpoch}.jpg';
        final UploadTask task = _storage.ref(path).putFile(imageFile);
        final TaskSnapshot snap = await task;
        imageUrl = await snap.ref.getDownloadURL();
      }
      final DateTime now = DateTime.now();
      final Map<String, dynamic> data = <String, dynamic>{
        'storeId': storeId,
        'name': name,
        'description': description,
        'price': price,
        'condition': condition,
        'category': category,
        'imageUrl': imageUrl,
        'updatedAt': Timestamp.fromDate(now),
        'isActive': true,
      };
      if (editing == null) {
        await _firestore
            .collection('stores')
            .doc(storeId)
            .collection('items')
            .add(<String, dynamic>{
              ...data,
              'createdAt': Timestamp.fromDate(now),
            });
        // Actualizar contador de items al crear
        await _updateStoreItemCount(storeId);
      } else {
        await _firestore
            .collection('stores')
            .doc(storeId)
            .collection('items')
            .doc(editing.id)
            .set(data, SetOptions(merge: true));
      }
      Get.snackbar('Éxito', 'Artículo guardado');
    } catch (_) {
      Get.snackbar('Error', 'No se pudo guardar el artículo de la tienda');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteStoreItem(String storeId, StoreItemModel item) async {
    try {
      await _firestore
          .collection('stores')
          .doc(storeId)
          .collection('items')
          .doc(item.id)
          .delete();
      if (item.imageUrl.isNotEmpty) {
        try {
          await _storage.refFromURL(item.imageUrl).delete();
        } catch (_) {}
      }
      // Actualizar contador de items al eliminar
      await _updateStoreItemCount(storeId);
      Get.snackbar('Eliminado', 'Artículo eliminado');
    } catch (_) {
      Get.snackbar('Error', 'No se pudo eliminar el artículo');
    }
  }

  // Método privado para actualizar el contador de items de la tienda
  Future<void> _updateStoreItemCount(String storeId) async {
    try {
      final QuerySnapshot itemsSnapshot = await _firestore
          .collection('stores')
          .doc(storeId)
          .collection('items')
          .where('isActive', isEqualTo: true)
          .get();

      final int itemsCount = itemsSnapshot.docs.length;

      await _firestore.collection('stores').doc(storeId).update(
        <String, dynamic>{'itemsCount': itemsCount},
      );
    } catch (e) {
      debugPrint('Error updating items count: $e');
    }
  }

  // Store item methods for new layout
  void updateItemCondition(String condition) {
    selectedItemCondition.value = condition;
  }

  void updateItemCategory(String category) {
    selectedItemCategory.value = category;
  }

  void retakeItemPhoto() {
    selectedItemImage.value = null;
  }

  void startEditingStoreItem(StoreItemModel item) {
    editingStoreItem.value = item;
    itemNameController.text = item.name;
    itemDescriptionController.text = item.description;
    itemPriceController.text = item.price.toStringAsFixed(0);
    selectedItemCondition.value = item.condition;
    selectedItemCategory.value = item.category;
    selectedItemImage.value = null; // Reset image, will show existing from URL
  }

  bool validateStoreItemForm() {
    if (selectedItemImage.value == null && editingStoreItem.value == null) {
      Get.snackbar(
        'Imagen requerida',
        'Debes seleccionar una imagen del artículo',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (itemNameController.text.trim().isEmpty) {
      Get.snackbar(
        'Nombre requerido',
        'Debes ingresar el nombre del artículo',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (itemDescriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Descripción requerida',
        'Debes ingresar una descripción',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    final double? price = double.tryParse(itemPriceController.text.trim());
    if (price == null || price <= 0) {
      Get.snackbar(
        'Precio inválido',
        'Debes ingresar un precio válido',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  Future<void> createStoreItem() async {
    if (!validateStoreItemForm()) return;

    final Map args = Get.arguments as Map? ?? <String, dynamic>{};
    final StoreModel store = args['store'] as StoreModel;

    final double price =
        double.tryParse(itemPriceController.text.trim()) ?? 0.0;

    await createOrUpdateStoreItem(
      storeId: store.id,
      editing: null,
      name: itemNameController.text.trim(),
      description: itemDescriptionController.text.trim(),
      price: price,
      condition: selectedItemCondition.value,
      category: selectedItemCategory.value,
      imageFile: selectedItemImage.value,
    );

    resetStoreItemForm();
    Get.back();
  }

  Future<void> saveEditedStoreItem() async {
    if (!validateStoreItemForm()) return;

    final Map args = Get.arguments as Map? ?? <String, dynamic>{};
    final StoreModel store = args['store'] as StoreModel;
    final StoreItemModel? editing = editingStoreItem.value;

    if (editing == null) return;

    final double price =
        double.tryParse(itemPriceController.text.trim()) ?? 0.0;

    await createOrUpdateStoreItem(
      storeId: store.id,
      editing: editing,
      name: itemNameController.text.trim(),
      description: itemDescriptionController.text.trim(),
      price: price,
      condition: selectedItemCondition.value,
      category: selectedItemCategory.value,
      imageFile: selectedItemImage.value,
    );

    resetStoreItemForm();
    Get.back();
  }

  void resetStoreItemForm() {
    itemNameController.clear();
    itemDescriptionController.clear();
    itemPriceController.clear();
    selectedItemCondition.value = 'Nuevo';
    selectedItemCategory.value = 'Otros';
    selectedItemImage.value = null;
    editingStoreItem.value = null;
  }

  @override
  void onClose() {
    nameController.dispose();
    descriptionController.dispose();
    itemNameController.dispose();
    itemDescriptionController.dispose();
    itemPriceController.dispose();
    super.onClose();
  }
}
