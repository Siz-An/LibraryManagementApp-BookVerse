import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:book_Verse/features/authentication/screens/onboarding.dart';
import 'package:book_Verse/navigation_menu/navigation_menu.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../utils/exceptions/firebase_auth_exception.dart';
import '../../../../utils/exceptions/firebase_exception.dart';
import '../../../../utils/exceptions/format_exception.dart';
import '../../../../utils/exceptions/platform_exception.dart';
import '../userRepo.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance

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
      final Role = await getUserRole(user.uid);
      if (Role == 'User') {
        Get.offAll(() => NavigationMenu());
      } else {
        Get.offAll(() => LoginScreen());
      }
    } else {
      final isFirstTime = deviceStorage.read('IsFirstTime') ?? true;
      deviceStorage.writeIfNull('IsFirstTime', true);
      Get.offAll(() => isFirstTime ? const OnBoardingScreen() : const LoginScreen());
    }
  }

  Future<String?> getUserRole(String userId) async {
    try {
      final snapshot = await _firestore.collection('Users').doc(userId).get();
      if (snapshot.exists) {
        return snapshot.data()?['Role']; // Ensure the field matches your Firestore schema
      }
      return null;
    } catch (e) {
      print('Error fetching user role: $e');
      return null;
    }
  }


  Future<UserCredential> loginWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      final Role = await getUserRole(credential.user!.uid);

      // Check if user is activated (only for User role, not Admin)
      if (Role == 'User') {
        final isActivated = await _isUserActivated(credential.user!.uid);
        if (!isActivated) {
          // Sign out the user since they're not activated
          await _auth.signOut();
          throw Exception('Your account is not activated yet. Please contact the administrator.');
        }
      }

      if (Role != 'User') {
        throw Exception('You are not authorized to log in as a User.');
      }
      return credential;
    } catch (e) {
      rethrow;
    }
  }
  
  /// Check if user is activated
  Future<bool> _isUserActivated(String userId) async {
    try {
      final snapshot = await _firestore.collection('Users').doc(userId).get();
      if (snapshot.exists) {
        final userData = snapshot.data() as Map<String, dynamic>;
        final canLogin = userData['can_login'] ?? 'no';
        return canLogin == 'yes';
      }
      return false;
    } catch (e) {
      print('Error checking user activation status: $e');
      return false;
    }
  }

  Future<UserCredential> registerWithEmailAndPassword(String email, String password) async {
    return _handleFirebaseAuthOperation(() async {
      return await _auth.createUserWithEmailAndPassword(email: email, password: password);
    });
  }

  Future<void> sendEmailVerification() async {
    return _handleFirebaseAuthOperation(() async {
      await _auth.currentUser?.sendEmailVerification();
    });
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? userAccount = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication? googleAuth = await userAccount?.authentication;
      final credentials = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );
      return await _auth.signInWithCredential(credentials);
    } on Exception catch (e) {
      _handleException(e);
      return null; // Return null on error
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    return _handleFirebaseAuthOperation(() async {
      await _auth.sendPasswordResetEmail(email: email);
    });
  }

  Future<void> logout() async {
    try {
      // Delete searchedBooks for the current user
      await _deleteSearchedBooks();

      // Sign out from Google and Firebase
      await GoogleSignIn().signOut();
      await _auth.signOut();

      Get.offAll(() => const LoginScreen());
    } on Exception catch (e) {
      _handleException(e);
    }
  }

  Future<void> _deleteSearchedBooks() async {
    // Reference to the searchedBooks collection
    CollectionReference searchedBooksRef = _firestore.collection('searchedBooks');

    // Get the current user's ID
    User? user = _auth.currentUser;
    if (user != null) {
      // Get all documents associated with the user's ID
      QuerySnapshot snapshot = await searchedBooksRef.where('userId', isEqualTo: user.uid).get();

      // Delete each document for this user
      for (QueryDocumentSnapshot doc in snapshot.docs) {
        await searchedBooksRef.doc(doc.id).delete();
      }
    }
  }

  Future<void> reAuthenticateWithEmailAndPassword(String email, String password) async {
    return _handleFirebaseAuthOperation(() async {
      AuthCredential credential = EmailAuthProvider.credential(email: email, password: password);
      await _auth.currentUser!.reauthenticateWithCredential(credential);
    });
  }

  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
      Get.offAll(() => const LoginScreen());
    } on Exception catch (e) {
      _handleException(e);
    }
  }

  Future<T> _handleFirebaseAuthOperation<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e) {
      _handleException(e);
      rethrow; // Propagate the exception after logging it
    }
  }

  void _handleException(dynamic e) {
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
