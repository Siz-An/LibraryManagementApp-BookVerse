import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../common/network_check/network_manager.dart';
import '../../../../data/authentication/repository/adminRepo.dart';
import '../../../../data/authentication/repository/authentication/admin_auth_repo.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/fullscreen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/models/adminModels.dart';
import '../../screens/signup/admin_verify_email.dart';

class AdminSignupController extends GetxController {
  static AdminSignupController get instance => Get.find();

  /// ----> Variables
  final hidePassword = true.obs;
  final privacyPolicy = false.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final firstName = TextEditingController();
  final adminId = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  final userName = TextEditingController();
  GlobalKey<FormState> adminsignupFormKey = GlobalKey<FormState>();

  Future<int> getAdminCount() async {
    try {
      // Fetch the number of admin documents in the 'Admins' collection
      final querySnapshot = await AdminRepository.instance.db.collection("Admins").get();
      return querySnapshot.docs.length;
    } on FirebaseException catch (e) {
      throw 'Firebase error: ${e.code}'; // Handle Firebase-specific errors
    } catch (e) {
      throw 'Error fetching admin count: $e'; // General error
    }
  }

  void signup() async {
    // Start loading
    TFullScreenLoader.openLoadingDialogue(
        'We are processing your information....',
        TImages.checkRegistration);

    // Check Internet Connectivity
    final isConnected = await NetworkManager.instance.isConnected();
    if (!isConnected) {
      TLoaders.errorSnackBar(
          title: 'No Internet Connection',
          message: 'Please check your internet connection and try again.');
      TFullScreenLoader.stopLoading();
      return;
    }

    // Form Validation
    if (!adminsignupFormKey.currentState!.validate()) {
      TFullScreenLoader.stopLoading();
      return;
    }

    try {
      // Check if an admin already exists
      final adminCount = await getAdminCount();
      if (adminCount > 0) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(
            title: 'Admin Already Exists',
            message: 'Only one admin account is allowed.');
        return;
      }

      // Register admin in Firebase authentication
      final userCredential = await AdminAuthenticationRepository.instance.registerWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Save Authenticated admin data in Firebase Firestore
      final newAdmin = AdminModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        userName: userName.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: '',
        role: 'Admin',
        permissions: [],
      );

      final adminRepo = Get.put(AdminRepository());
      await adminRepo.saveAdminRecord(newAdmin);

      // Show success message
      TLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your admin account has been created! Please verify it.');

      // Move to verify screen
      Get.to(() => AdminVerifyEmailScreen(email: email.text.trim()));
    } catch (e) {
      TFullScreenLoader.stopLoading();
      // Show error message
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
