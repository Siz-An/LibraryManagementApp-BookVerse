// lib/data/authentication/repository/authentication/admin_auth_repo.dart

import 'package:book_Verse/data/authentication/repository/adminRepo.dart';
import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:book_Verse/features/authentication/screens/signup/verify_email.dart';
import 'package:book_Verse/features/authentication/screens/onboarding.dart';
import 'package:book_Verse/navigation_menu/admin_nav.dart';
import 'package:book_Verse/utils/exceptions/firebase_auth_exception.dart';
import 'package:book_Verse/utils/exceptions/firebase_exception.dart';
import 'package:book_Verse/utils/exceptions/format_exception.dart';
import 'package:book_Verse/utils/exceptions/platform_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Added for Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../utils/popups/loaders.dart';

class AdminAuthenticationRepository extends GetxController {
  static AdminAuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

  User? get authAdmin => _auth.currentUser;

  @override
  void onReady() {
    super.onReady();
    // Remove splash screen on app launch
    FlutterNativeSplash.remove();
    // Redirect to appropriate screen based on authentication status
    screenRedirect();
  }

  Future<void> screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        // Verify if the user has 'Admin' role
        final isAdmin = await _checkIfAdmin(user.uid);
        if (isAdmin) {
          Get.offAll(() => const AdminNavigationMenu());
        } else {
          // User is not an admin, show error and logout
          Get.offAll(() => const LoginScreen());
          TLoaders.errorSnackBar(title: 'Access Denied', message: 'You do not have admin privileges.');
          await logout();
        }
      } else {
        Get.offAll(() => VerifyEmailScreen(email: user.email));
      }
    } else {
      // Check if first time or not and redirect accordingly
      final isFirstTime = deviceStorage.read('IsFirstTime') ?? true;
      deviceStorage.writeIfNull('IsFirstTime', true);
      Get.offAll(() => isFirstTime ? const OnBoardingScreen() : const LoginScreen());
    }
  }

  // Method to check if the user is an admin
  Future<bool> _checkIfAdmin(String uid) async {
    try {
      DocumentSnapshot adminDoc = await _firestore.collection('Admins').doc(uid).get();
      if (adminDoc.exists) {
        final role = adminDoc.get('Role') as String?;
        return role == 'Admin';
      }
      return false;
    } catch (e) {
      throw handleException(e);
    }
  }

  // Centralize exception handling
  Object handleException(Object e) {
    if (e is FirebaseAuthException) {
      return TFirebaseAuthException(e.code).message;
    } else if (e is FirebaseException) {
      return TFirebaseException(e.code).message;
    } else if (e is FormatException) {
      return TFormatException();
    } else if (e is PlatformException) {
      return TPlatformException(e.code).message;
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      if (userAccount == null) {
        // User canceled the sign-in
        return null;
      }
      final GoogleSignInAuthentication? googleAuth = await userAccount.authentication;
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await _auth.signInWithCredential(credentials);
    } catch (e) {
      if (kDebugMode) print(handleException(e));
      throw handleException(e);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> logout() async {
    try {
      await GoogleSignIn().signOut();
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    } catch (e) {
      throw handleException(e);
    }
  }

  Future<void> deleteAccount() async {
    try {
      await AdminRepository.instance.removeAdminRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      throw handleException(e);
    }
  }
}
