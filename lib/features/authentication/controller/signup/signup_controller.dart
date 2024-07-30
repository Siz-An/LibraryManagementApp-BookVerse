
import 'package:book_Verse/data/user/user_repo.dart';
import 'package:book_Verse/features/authentication/screens/signup/verify_email.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../common/network_check/network_manager.dart';
import '../../../../data/authentication/repository/authentication/authentication_repo.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/fullscreen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/models/userModels.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  ///----> Variables
  final hidePassword = true.obs;
  final privacyPolicy = false.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final firstName = TextEditingController();
  final userId = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  final userName = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

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
    if (!signupFormKey.currentState!.validate()) {
      TFullScreenLoader.stopLoading();
      return;
    }

    // Privacy policy check
    if (!privacyPolicy.value) {
      TLoaders.warningSnackBar(
          title: 'Accept Privacy Policy',
          message: 'In order to create an account you have to accept privacy policy and terms of use.');
      TFullScreenLoader.stopLoading();
      return;
    }

    try {
      // Register user in the Firebase authentication
      final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Save Authenticated user data in the Firebase FireStore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        userName: userName.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: '',
      );

      final userRepo = Get.put(UserRepo());
      await userRepo.saveUserRecord(newUser);

      // Show success Method
      TLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your account has been created! Please verify it');

      // Move to verify Screen
      Get.to(() => VerifyEmailScreen(email: email.text.trim(),));
    } catch (e) {
      TFullScreenLoader.stopLoading();
      // Show some generic Error to the user
      // Remove Loader
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}