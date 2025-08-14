import 'dart:io';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/swap_item_model.dart';

class SwapController extends GetxController {
  // Camera
  CameraController? cameraController;
  final RxBool isCameraInitialized = false.obs;
  final RxBool isFlashOn = false.obs;
  final RxBool isLoading = false.obs;

  // Form data
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final RxString selectedSize = 'S'.obs;
  final RxDouble estimatedPrice = 50.0.obs;
  final RxString selectedCondition = 'Nuevo'.obs;
  final RxString selectedCategory = 'Otros'.obs;

  // Captured image
  final Rx<File?> capturedImage = Rx<File?>(null);

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Available options
  final List<String> sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL'];
  final List<String> conditions = [
    'Nuevo',
    'Como nuevo',
    'Muy bueno',
    'Bueno',
    'Regular',
  ];
  final List<String> categories = [
    'Todos',
    'Camisetas',
    'Pantalones',
    'Chaquetas',
    'Calzado',
    'Accesorios',
    'Otros',
  ];

  @override
  void onInit() {
    super.onInit();
    initializeCamera();
  }

  @override
  void onClose() {
    cameraController?.dispose();
    nameController.dispose();
    descriptionController.dispose();
    super.onClose();
  }

  Future<void> initializeCamera() async {
    try {
      final List<CameraDescription> cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras.first,
          ResolutionPreset.high,
          enableAudio: false,
        );

        await cameraController!.initialize();
        isCameraInitialized.value = true;
      }
    } catch (e) {
      debugPrint('Error initializing camera: $e');
      Get.snackbar(
        'Error de Cámara',
        'No se pudo inicializar la cámara',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> capturePhoto() async {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return;
    }

    try {
      isLoading.value = true;
      final XFile photo = await cameraController!.takePicture();
      capturedImage.value = File(photo.path);
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      Get.snackbar(
        'Error',
        'No se pudo tomar la foto',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleFlash() async {
    if (cameraController == null) return;

    try {
      isFlashOn.value = !isFlashOn.value;
      await cameraController!.setFlashMode(
        isFlashOn.value ? FlashMode.torch : FlashMode.off,
      );
    } catch (e) {
      debugPrint('Error toggling flash: $e');
    }
  }

  void retakePhoto() {
    capturedImage.value = null;
  }

  Future<void> pickFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1440,
      );
      if (picked == null) return;
      capturedImage.value = File(picked.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      Get.snackbar('Error', 'No se pudo seleccionar la imagen');
    }
  }

  void updateSize(String size) {
    selectedSize.value = size;
  }

  void updatePrice(double price) {
    estimatedPrice.value = price;
  }

  void updateCondition(String condition) {
    selectedCondition.value = condition;
  }

  void updateCategory(String category) {
    selectedCategory.value = category;
  }

  bool validateForm() {
    if (capturedImage.value == null) {
      Get.snackbar(
        'Imagen requerida',
        'Debes tomar una foto del artículo',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (nameController.text.trim().isEmpty) {
      Get.snackbar(
        'Nombre requerido',
        'Debes ingresar el nombre del artículo',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    if (descriptionController.text.trim().isEmpty) {
      Get.snackbar(
        'Descripción requerida',
        'Debes ingresar una descripción',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }

  Future<void> createSwapItem() async {
    if (!validateForm()) return;

    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      Get.snackbar(
        'Error',
        'Debes estar autenticado para crear un swap',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading.value = true;

      // Upload image to Firebase Storage
      final String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage
          .ref()
          .child('users')
          .child(currentUser.uid)
          .child('swaps')
          .child(fileName);

      final UploadTask uploadTask = ref.putFile(capturedImage.value!);
      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // Create SwapItem document
      final String swapId = _firestore.collection('users').doc().id;
      final DateTime now = DateTime.now();

      final SwapItemModel swapItem = SwapItemModel(
        id: swapId,
        userId: currentUser.uid,
        name: nameController.text.trim(),
        description: descriptionController.text.trim(),
        size: selectedSize.value,
        estimatedPrice: estimatedPrice.value,
        condition: selectedCondition.value,
        imageUrl: downloadUrl,
        category: selectedCategory.value,
        createdAt: now,
        updatedAt: now,
      );

      // Save to Firestore
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('swaps')
          .doc(swapId)
          .set(swapItem.toMap());

      // Reset form and navigate back
      resetForm();
      Get.back();

      Get.snackbar(
        'Éxito',
        'Swap creado exitosamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Error creating swap: $e');
      Get.snackbar(
        'Error',
        'No se pudo crear el swap. Intenta de nuevo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withValues(alpha: 0.8),
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void resetForm() {
    nameController.clear();
    descriptionController.clear();
    selectedSize.value = 'S';
    estimatedPrice.value = 50.0;
    selectedCondition.value = 'Nuevo';
    capturedImage.value = null;
    isFlashOn.value = false;
  }

  // Method to get user's swap items for home page
  Stream<List<SwapItemModel>> getUserSwaps() {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('swaps')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot snapshot) {
          return snapshot.docs.map((QueryDocumentSnapshot doc) {
            final Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;
            return SwapItemModel.fromMap(data);
          }).toList();
        });
  }

  // Catalog: get all active swaps from all users
  Stream<List<SwapItemModel>> getAllSwaps() {
    return _firestore
        .collectionGroup('swaps')
        .where('isActive', isEqualTo: true)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((QuerySnapshot snapshot) {
          return snapshot.docs.map((QueryDocumentSnapshot doc) {
            final Map<String, dynamic> data =
                doc.data() as Map<String, dynamic>;
            return SwapItemModel.fromMap(data);
          }).toList();
        });
  }
}
