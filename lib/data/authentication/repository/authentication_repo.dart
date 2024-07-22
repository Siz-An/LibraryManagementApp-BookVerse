import 'package:book_Verse/data/authentication/repository/userRepo.dart';
import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:book_Verse/navigation_menu/navigation_menu.dart';
import 'package:book_Verse/navigation_menu/admin_navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../features/authentication/screens/onboarding.dart';
import '../../../features/authentication/screens/signup/verify_email.dart';
import '../../../utils/exceptions/firebase_auth_exception.dart';
import '../../../utils/exceptions/firebase_exception.dart';
import '../../../utils/exceptions/format_exception.dart';
import '../../../utils/exceptions/platform_exception.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get authUser => _auth.currentUser;

  @override
  void onReady() {
    super.onReady();
    FlutterNativeSplash.remove();
    screenRedirect();
  }

  Future<void> screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        final userRole = deviceStorage.read('userRole') ?? 'user'; // Check user role from storage
        if (userRole == 'admin') {
          Get.offAll(() => const AdminNavigationMenu()); // Redirect to Admin Menu
        } else {
          Get.offAll(() => const NavigationMenu()); // Redirect to User Menu
        }
      } else {
        Get.offAll(() => VerifyEmailScreen(email: user.email ?? ''));
      }
    } else {
      final isFirstTime = deviceStorage.read('IsFirstTime') ?? true;
      if (isFirstTime) {
        deviceStorage.write('IsFirstTime', false);
        Get.offAll(() => const OnBoardingScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    }
  }

  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);

      // Retrieve user role from the database or storage
      final userRole = await fetchUserRole(userCredential.user!.uid); // Custom method to fetch user role
      deviceStorage.write('userRole', userRole); // Store the user role

      return userCredential;
    } catch (e) {
      handleExceptions(e);
      rethrow; // Ensure that the method returns a value even if an exception is thrown
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);

      // Default role for new users
      deviceStorage.write('userRole', 'user');

      return userCredential;
    } catch (e) {
      handleExceptions(e);
      rethrow; // Ensure that the method returns a value even if an exception is thrown
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      handleExceptions(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await userAccount?.authentication;
      final credentials = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);
      return await _auth.signInWithCredential(credentials);
    } catch (e) {
      if (kDebugMode) print('Error during Google sign-in: $e');
      handleExceptions(e);
      return null;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      handleExceptions(e);
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      handleExceptions(e);
    }
  }

  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } catch (e) {
      handleExceptions(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      handleExceptions(e);
    }
  }

  Future<String> fetchUserRole(String uid) async {
    // Replace this with your actual implementation to fetch user role from database
    // Here, we're just using a mock implementation
    return 'user'; // Default to 'user' or 'admin' based on your actual logic
  }

  void handleExceptions(dynamic e) {
    if (e is FirebaseAuthException) {
      throw TFirebaseAuthException(e.code).message;
    } else if (e is FirebaseException) {
      throw TFirebaseException(e.code).message;
    } else if (e is FormatException) {
      throw const TFormatException();
    } else if (e is PlatformException) {
      throw TPlatformException(e.code).message;
    } else {
      throw 'Something went wrong. Please try again.';
    }
  }
}
