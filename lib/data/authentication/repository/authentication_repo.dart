import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:book_Verse/navigation_menu/navigation_menu.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';
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

  @override
  void onReady() {
    // Remove splash screen on app launch
    FlutterNativeSplash.remove();
    // Redirect to appropriate screen based on authentication status
    screenRedirect();
    super.onReady();
  }

  Future<void> screenRedirect() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // User is logged in
        await user.reload(); // Refresh user data
        if (user.emailVerified) {
          // Navigate to main app screen if email is verified
          Get.offAll(() => const NavigationMenu());
        } else {
          // Navigate to verify email screen if email is not verified
          Get.to(() => VerifyEmailScreen(email: user.email));
        }
      } else {
        // No user is logged in
        if (deviceStorage.read('isFirstTime') != true) {
          // Not the first time user, navigate to login screen
          Get.offAll(() => const LoginScreen());
        } else {
          // First-time user, navigate to onboarding screen
          Get.offAll(() => const OnBoardingScreen());
        }
      }
    } catch (e) {
      // Handle any exceptions that occur during redirection
      print('Error during screen redirection: $e');
      // Fallback to a default screen or handle the error gracefully
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

  Future<void> logout() async {
    try {
      await _auth.signOut();
      Get.offAll(() => const LoginScreen());
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
}
