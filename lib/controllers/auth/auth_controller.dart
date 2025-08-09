import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../routes/routes.dart';

enum AuthStatus { checking, authenticated, unauthenticated, error }

class AuthController extends GetxController {
  final RxBool showLogin = false.obs;
  final RxBool showRegister = false.obs;
  final RxBool showForgotPassword = false.obs;
  final RxBool isDarkMode = false.obs;
  final RxString userName = 'Usuario'.obs;
  final RxString userEmail = 'usuario@example.com'.obs;
  final Rxn<String> profileImage = Rxn<String>();

  final RxBool isAppLockEnabled = false.obs;
  final RxBool isBiometricEnabled = false.obs;
  final RxString lockTimeout = 'immediately'.obs;
  final RxString pin = ''.obs;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _imagePicker = ImagePicker();

  UserModel? user;

  final RxBool isLoading = false.obs;
  final RxBool isError = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<AuthStatus> authStatus = AuthStatus.checking.obs;

  final RxString uid = ''.obs;
  final RxString name = ''.obs;
  final RxString password = ''.obs;
  final RxString profilePicture = ''.obs;
  final RxString theme = ''.obs;
  final RxString language = ''.obs;
  final RxString userType = ''.obs;
  final RxString email = ''.obs;

  static const int minNameLength = 1;
  static const int maxNameLength = 50;
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 12;
  static const int minEmailLength = 6;
  static const int maxEmailLength = 100;
  static const String specialCharacters = r'[!@#$%^&*(),.?":{}|<>]';

  @override
  void onInit() {
    super.onInit();
    _initializeAuth();
  }

  void _initializeAuth() async {
    try {
      final User? currentUser = _auth.currentUser;
      if (currentUser != null) {
        uid.value = currentUser.uid;
        await _loadUserData();
        await _loadTheme();
        await _loadSecuritySettings();
        authStatus.value = AuthStatus.authenticated;
      } else {
        authStatus.value = AuthStatus.unauthenticated;
      }
    } catch (e) {
      debugPrint('Error al inicializar auth: $e');
      authStatus.value = AuthStatus.error;
    }
  }

  Future<void> _loadUserData() async {
    try {
      if (uid.value.isEmpty) return;
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(uid.value)
          .get();
      if (userDoc.exists) {
        final Map<String, dynamic> userData = userDoc.data()!;
        userName.value = userData['name'] ?? 'Usuario';
        userEmail.value = userData['email'] ?? 'usuario@example.com';
        profileImage.value = userData['photoUrl'];
        if ((userData['language'] as String?) != null) {
          language.value = (userData['language'] as String);
        }
        if ((userData['theme'] as String?) != null) {
          theme.value = (userData['theme'] as String);
          isDarkMode.value = theme.value == 'dark';
          _applyTheme();
        }
      }
    } catch (e) {
      debugPrint('Error al cargar datos del usuario: $e');
    }
  }

  Future<void> _loadTheme() async {
    try {
      if (uid.value.isEmpty) return;
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(uid.value)
          .get();
      if (userDoc.exists) {
        final dynamic darkMode = userDoc.data()?['isDarkMode'];
        isDarkMode.value = darkMode == true || darkMode == 'true';
        _applyTheme();
      }
    } catch (e) {
      debugPrint('Error al cargar el tema: $e');
    }
  }

  void _applyTheme() {
    Get.changeThemeMode(isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }

  void toggleTheme() async {
    try {
      isDarkMode.value = !isDarkMode.value;
      _applyTheme();
      if (uid.value.isNotEmpty) {
        final String currentTheme = isDarkMode.value ? 'dark' : 'light';
        await _firestore.collection('users').doc(uid.value).set({
          'isDarkMode': isDarkMode.value,
          'theme': currentTheme,
          'interests': FieldValue.arrayUnion(<String>['theme:$currentTheme']),
        }, SetOptions(merge: true));
      }
      Get.snackbar(
        'Tema cambiado',
        isDarkMode.value ? 'Modo oscuro activado' : 'Modo claro activado',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      debugPrint('Error al cambiar el tema: $e');
      Get.snackbar('Error', 'No se pudo cambiar el tema');
    }
  }

  void toggleLogin() {
    showLogin.value = !showLogin.value;
    if (showLogin.value) {
      showRegister.value = false;
      showForgotPassword.value = false;
    }
  }

  void toggleRegister() {
    showRegister.value = !showRegister.value;
    if (showRegister.value) {
      showLogin.value = false;
      showForgotPassword.value = false;
    }
  }

  void toggleForgotPassword() {
    showForgotPassword.value = !showForgotPassword.value;
    if (showForgotPassword.value) {
      showLogin.value = false;
      showRegister.value = false;
    }
  }

  void closeAll() {
    showLogin.value = false;
    showRegister.value = false;
    showForgotPassword.value = false;
  }

  void _handleAuthErrors(FirebaseAuthException e, Function(String) onError) {
    String message;
    switch (e.code) {
      case 'email-already-in-use':
        message = 'Este correo ya está en uso.';
        break;
      case 'invalid-email':
        message = 'Formato de correo inválido.';
        break;
      case 'weak-password':
        message = 'La contraseña es muy débil.';
        break;
      case 'user-not-found':
        message = 'No se encontró usuario con este correo.';
        break;
      case 'wrong-password':
        message = 'Contraseña incorrecta.';
        break;
      case 'user-disabled':
        message = 'Este usuario ha sido deshabilitado.';
        break;
      case 'too-many-requests':
        message = 'Demasiados intentos fallidos. Intente más tarde.';
        break;
      case 'operation-not-allowed':
        message = 'Operación no permitida.';
        break;
      case 'network-request-failed':
        message = 'Error de conexión. Verifique su internet.';
        break;
      default:
        message = 'Ocurrió un error inesperado.';
    }
    onError(message);
  }

  AuthStatus _handleAuthStatus(String email, String password) {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Por favor, ingrese un email y contraseña válidos');
    }
    if (!RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    ).hasMatch(email)) {
      throw Exception('Por favor, ingrese un email válido');
    }
    if (email.length < minEmailLength) {
      throw Exception(
        'El email debe tener al menos $minEmailLength caracteres',
      );
    }
    if (email.length > maxEmailLength) {
      throw Exception(
        'El email no puede tener más de $maxEmailLength caracteres',
      );
    }
    if (password.length < minPasswordLength) {
      throw Exception(
        'La contraseña debe tener al menos $minPasswordLength caracteres',
      );
    }
    if (password.length > maxPasswordLength) {
      throw Exception(
        'La contraseña no puede tener más de $maxPasswordLength caracteres',
      );
    }
    return AuthStatus.checking;
  }

  Future<void> _createUserDocument(User firebaseUser) async {
    final String defaultLanguage = language.value.isNotEmpty
        ? language.value
        : (firebaseUser.email != null ? 'es' : 'es');
    final String defaultTheme = isDarkMode.value ? 'dark' : 'light';
    final List<String> defaultInterests = <String>[
      'language:$defaultLanguage',
      'theme:$defaultTheme',
    ];
    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'UID': firebaseUser.uid,
      'createdAt': Timestamp.now(),
      'name': firebaseUser.displayName ?? '',
      'email': firebaseUser.email?.toLowerCase(),
      'photoUrl': firebaseUser.photoURL ?? '',
      'userType': 'free',
      'isDarkMode': false,
      'language': defaultLanguage,
      'theme': defaultTheme,
      'interests': defaultInterests,
    }, SetOptions(merge: true));
  }

  Future<void> login({
    required String email,
    required String password,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      isLoading.value = true;
      authStatus.value = _handleAuthStatus(email, password);
      final String userEmail = email.toLowerCase().trim();
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: userEmail,
        password: password,
      );
      final User? signedUser = cred.user;
      if (signedUser == null) {
        throw Exception('No se pudo iniciar sesión');
      }
      if (!signedUser.emailVerified) {
        await signedUser.sendEmailVerification();
        throw Exception(
          'Verifica tu correo electrónico. Enviamos un nuevo correo.',
        );
      }
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(signedUser.uid)
          .get();
      if (!userDoc.exists) {
        await _createUserDocument(signedUser);
      }
      final DocumentSnapshot<Map<String, dynamic>> updated = await _firestore
          .collection('users')
          .doc(signedUser.uid)
          .get();
      user = UserModel.fromJson(updated.data()!);

      uid.value = signedUser.uid;
      this.email.value = signedUser.email ?? '';
      name.value = user?.name ?? '';
      profilePicture.value = user?.photoUrl ?? '';
      theme.value = user?.theme ?? '';
      language.value = user?.language ?? '';
      userType.value = user?.userType ?? '';
      final String currentTheme = theme.value.isNotEmpty
          ? theme.value
          : (isDarkMode.value ? 'dark' : 'light');
      final String currentLanguage = language.value.isNotEmpty
          ? language.value
          : 'es';
      await _ensureInterestsConsistency(
        userId: uid.value,
        currentLanguage: currentLanguage,
        currentTheme: currentTheme,
      );
      authStatus.value = AuthStatus.authenticated;
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _handleAuthErrors(e, onError);
    } catch (e) {
      onError(e.toString());
    } finally {
      isLoading.value = false;
      if (authStatus.value != AuthStatus.authenticated) {
        authStatus.value = AuthStatus.unauthenticated;
      }
    }
  }

  Future<void> register({
    required String email,
    required String password,
    String? name,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      isLoading.value = true;
      authStatus.value = _handleAuthStatus(email, password);
      final String userEmail = email.toLowerCase().trim();
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: password,
      );
      final User? newUser = cred.user;
      if (newUser == null) {
        throw Exception('Error al crear la cuenta');
      }
      await newUser.sendEmailVerification();
      await _createUserDocument(newUser);
      if ((name ?? '').trim().isNotEmpty) {
        await _firestore.collection('users').doc(newUser.uid).set({
          'name': name!.trim(),
        }, SetOptions(merge: true));
      }
      Get.snackbar(
        'Registro exitoso',
        'Verifica tu correo para activar la cuenta.',
      );
      await _auth.signOut();
      _clearUserState();
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _handleAuthErrors(e, onError);
    } catch (e) {
      onError(e.toString());
    } finally {
      isLoading.value = false;
      if (authStatus.value != AuthStatus.authenticated) {
        authStatus.value = AuthStatus.unauthenticated;
      }
    }
  }

  Future<void> updateLanguage(String newLanguage) async {
    try {
      language.value = newLanguage;
      if (uid.value.isEmpty) return;
      await _firestore.collection('users').doc(uid.value).set({
        'language': newLanguage,
        'interests': FieldValue.arrayUnion(<String>['language:$newLanguage']),
      }, SetOptions(merge: true));
      Get.snackbar('Éxito', 'Idioma actualizado');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el idioma');
    }
  }

  Future<void> _ensureInterestsConsistency({
    required String userId,
    required String currentLanguage,
    required String currentTheme,
  }) async {
    await _firestore.collection('users').doc(userId).set({
      'language': currentLanguage,
      'theme': currentTheme,
      'interests': FieldValue.arrayUnion(<String>[
        'language:$currentLanguage',
        'theme:$currentTheme',
      ]),
    }, SetOptions(merge: true));
  }

  Future<void> recoverPassword({
    required String email,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final QuerySnapshot<Map<String, dynamic>> userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      if (userQuery.docs.isEmpty) {
        throw Exception('No se encontró usuario con este correo');
      }
      await _auth.sendPasswordResetEmail(email: email);
      Get.snackbar(
        'Correo de recuperación enviado',
        'Revisa tu bandeja de entrada.',
      );
      onSuccess();
    } on FirebaseAuthException catch (e) {
      _handleAuthErrors(e, onError);
    } catch (e) {
      onError(e.toString());
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    Get.offAllNamed(Routes.welcome);
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final GoogleAuthProvider provider = GoogleAuthProvider();
      provider.addScope('email');
      provider.setCustomParameters(<String, String>{
        'prompt': 'select_account',
      });
      final UserCredential userCredential = await _auth.signInWithProvider(
        provider,
      );
      final User? u = userCredential.user;
      if (u == null) {
        throw Exception('Error al iniciar sesión con Google');
      }
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(u.uid)
          .get();
      if (!userDoc.exists) {
        await _createUserDocument(u);
      }
      uid.value = u.uid;
      email.value = u.email ?? '';
      name.value = u.displayName ?? '';
      profilePicture.value = u.photoURL ?? '';
      final String currentTheme = isDarkMode.value ? 'dark' : 'light';
      final String currentLanguage = language.value.isNotEmpty
          ? language.value
          : 'es';
      await _firestore.collection('users').doc(u.uid).set({
        'lastLogin': Timestamp.now(),
        'name': u.displayName ?? name.value,
        'email': u.email?.toLowerCase() ?? email.value,
        'photoUrl': u.photoURL ?? profilePicture.value,
        'language': currentLanguage,
        'theme': currentTheme,
        'interests': FieldValue.arrayUnion(<String>[
          'language:$currentLanguage',
          'theme:$currentTheme',
        ]),
      }, SetOptions(merge: true));
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo completar el inicio de sesión con Google',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;
      final bool isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign In no disponible en este dispositivo');
      }
      final AuthorizationCredentialAppleID credential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );
      if (credential.identityToken == null) {
        throw Exception('No se pudo obtener el token de Apple');
      }
      final OAuthProvider provider = OAuthProvider('apple.com');
      final AuthCredential authCredential = provider.credential(
        idToken: credential.identityToken,
        accessToken: credential.authorizationCode,
      );
      final UserCredential userCredential = await _auth.signInWithCredential(
        authCredential,
      );
      final User? u = userCredential.user;
      if (u == null) {
        throw Exception('Error al iniciar sesión con Apple');
      }
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(u.uid)
          .get();
      if (!userDoc.exists) {
        await _createUserDocument(u);
      }
      uid.value = u.uid;
      email.value = u.email ?? '';
      name.value = u.displayName ?? credential.givenName ?? '';
      profilePicture.value = u.photoURL ?? '';
      final String currentTheme = isDarkMode.value ? 'dark' : 'light';
      final String currentLanguage = language.value.isNotEmpty
          ? language.value
          : 'es';
      await _firestore.collection('users').doc(u.uid).set({
        'lastLogin': Timestamp.now(),
        'name': u.displayName ?? credential.givenName ?? name.value,
        'email': u.email?.toLowerCase() ?? email.value,
        'photoUrl': u.photoURL ?? profilePicture.value,
        'language': currentLanguage,
        'theme': currentTheme,
        'interests': FieldValue.arrayUnion(<String>[
          'language:$currentLanguage',
          'theme:$currentTheme',
        ]),
      }, SetOptions(merge: true));
      Get.offAllNamed(Routes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo completar el inicio de sesión con Apple',
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfileImage(String imagePath) async {
    try {
      if (uid.value.isEmpty) return;
      final String fileName = 'profile.jpg';
      final Reference ref = _storage.ref().child(
        'users/${uid.value}/$fileName',
      );
      final UploadTask task = ref.putFile(
        Uri.parse(imagePath).isAbsolute ? File(imagePath) : File(imagePath),
      );
      final TaskSnapshot snap = await task;
      final String downloadUrl = await snap.ref.getDownloadURL();
      await _firestore.collection('users').doc(uid.value).set({
        'photoUrl': downloadUrl,
      }, SetOptions(merge: true));
      profileImage.value = downloadUrl;
      profilePicture.value = downloadUrl;
      Get.snackbar('Éxito', 'Imagen de perfil actualizada');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar la imagen de perfil');
    }
  }

  Future<void> pickAndUploadProfileImage() async {
    try {
      final XFile? picked = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
      );
      if (picked == null) return;
      await updateProfileImage(picked.path);
    } catch (_) {}
  }

  Future<void> updateUserName(String newName) async {
    try {
      if (uid.value.isEmpty) return;
      await _firestore.collection('users').doc(uid.value).update({
        'name': newName,
      });
      userName.value = newName;
      Get.snackbar('Éxito', 'Nombre actualizado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el nombre');
    }
  }

  Future<void> deleteAccount() async {
    try {
      if (uid.value.isEmpty) {
        throw Exception('No hay usuario autenticado para eliminar');
      }
      final User? u = _auth.currentUser;
      if (u == null) {
        throw Exception('No hay usuario autenticado');
      }
      await _deleteUserData(uid.value);
      await u.delete();
      _clearUserState();
      Get.snackbar(
        'Cuenta eliminada',
        'Tu cuenta ha sido eliminada permanentemente',
      );
      Get.offAllNamed(Routes.welcome);
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'requires-recent-login':
          errorMessage =
              'Debes iniciar sesión nuevamente para eliminar tu cuenta.';
          await logout();
          break;
        case 'user-not-found':
          errorMessage = 'No se encontró la cuenta del usuario.';
          break;
        default:
          errorMessage = 'Error al eliminar la cuenta: ${e.message}';
      }
      Get.snackbar('Error', errorMessage);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar la cuenta. Inténtalo de nuevo.',
      );
    }
  }

  Future<void> _deleteUserData(String userId) async {
    final WriteBatch batch = _firestore.batch();
    batch.delete(_firestore.collection('users').doc(userId));
    final QuerySnapshot<Map<String, dynamic>> transactionsQuery =
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in transactionsQuery.docs) {
      batch.delete(doc.reference);
    }
    final QuerySnapshot<Map<String, dynamic>> movementsQuery = await _firestore
        .collection('users')
        .doc(userId)
        .collection('movements')
        .get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in movementsQuery.docs) {
      batch.delete(doc.reference);
    }
    final QuerySnapshot<Map<String, dynamic>> goalsQuery = await _firestore
        .collection('users')
        .doc(userId)
        .collection('goals')
        .get();
    for (final QueryDocumentSnapshot<Map<String, dynamic>> doc
        in goalsQuery.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  void _clearUserState() {
    uid.value = '';
    userName.value = 'Usuario';
    userEmail.value = 'usuario@example.com';
    profileImage.value = null;
    name.value = '';
    email.value = '';
    profilePicture.value = '';
    theme.value = '';
    language.value = '';
    userType.value = '';
    isAppLockEnabled.value = false;
    isBiometricEnabled.value = false;
    lockTimeout.value = 'immediately';
    pin.value = '';
    isDarkMode.value = false;
    authStatus.value = AuthStatus.unauthenticated;
  }

  Future<void> _loadSecuritySettings() async {
    try {
      if (uid.value.isEmpty) return;
      final DocumentSnapshot<Map<String, dynamic>> userDoc = await _firestore
          .collection('users')
          .doc(uid.value)
          .get();
      if (userDoc.exists) {
        final Map<String, dynamic> data = userDoc.data()!;
        isAppLockEnabled.value = data['isAppLockEnabled'] ?? false;
        isBiometricEnabled.value = data['isBiometricEnabled'] ?? false;
        pin.value = data['pin'] ?? '';
        lockTimeout.value = data['lockTimeout'] ?? 'immediately';
        if (isAppLockEnabled.value && pin.value.isNotEmpty) {
          Get.offAllNamed('/app-lock');
        }
      }
    } catch (e) {
      debugPrint('Error al cargar configuración de seguridad: $e');
    }
  }

  Future<void> toggleAppLock(bool value) async {
    try {
      isBiometricEnabled.value = value;
      await _saveSecuritySettings();
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cambiar el estado del bloqueo');
    }
  }

  Future<void> _saveSecuritySettings() async {
    if (uid.value.isEmpty) return;
    await _firestore.collection('users').doc(uid.value).set({
      'isAppLockEnabled': isAppLockEnabled.value,
      'isBiometricEnabled': isBiometricEnabled.value,
      'pin': pin.value,
      'lockTimeout': lockTimeout.value,
    }, SetOptions(merge: true));
  }

  Future<void> toggleBiometric(bool value) async {
    try {
      isBiometricEnabled.value = value;
      await _saveSecuritySettings();
      Get.snackbar(
        'Éxito',
        value ? 'Biometría activada' : 'Biometría desactivada',
      );
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cambiar el estado de la biometría');
    }
  }

  Future<void> updatePin(String newPin) async {
    try {
      pin.value = newPin;
      Get.snackbar('Éxito', 'PIN actualizado correctamente');
    } catch (e) {
      Get.snackbar('Error', 'No se pudo actualizar el PIN');
    }
  }

  Future<void> setLockTimeout(String timeout) async {
    try {
      lockTimeout.value = timeout;
    } catch (e) {
      Get.snackbar('Error', 'No se pudo cambiar el tiempo de bloqueo');
    }
  }
}
