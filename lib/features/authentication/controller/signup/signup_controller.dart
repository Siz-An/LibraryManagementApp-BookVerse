
import 'package:book_Verse/data/user/user_repo.dart';
import 'package:book_Verse/features/authentication/screens/signup/verify_email.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../common/network_check/network_manager.dart';
import '../../../../data/authentication/repository/authentication_repo.dart';
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
  final phoneNo = TextEditingController();
  final userName = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  void signup() async {
    try {
      // Start loading
      TFullScreenLoader.openLoadingDialogue(
          'We are processing your information....', TImages.darkAppLogo);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TLoaders.errorSnackBar(
            title: 'No Internet Connection',
            message: 'Please check your internet connection and try again.');
        return;
      }

      // Form Validation
      if (!signupFormKey.currentState!.validate()) return;

      // Privacy policy check
      if (!privacyPolicy.value) {
        TLoaders.warningSnackBar(
            title: 'Accept Privacy Policy',
            message:
            'In order to create an account you have to accept privacy policy and terms of use.');
        return;
      }

      // Register user in the Firebase authentication
      final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(email.text.trim(), password.text.trim());

      // Save Authenticated user data in the Firebase FireStore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        userName: userName.text.trim(),
        email: email.text.trim(),
        phoneNo: phoneNo.text.trim(),
        profilePicture: '',
      );

      final userRepo = Get.put(UserRepo());
      await userRepo.saveUserRecord(newUser);

      //show success Method
      TLoaders.successSnackBar(title: 'Congratulation' ,message: 'Your account has been Created! Please Verify it');

      // Move to verify Screen
      Get.to(() => const VerifyEmailScreen());

      // Save newUser to Firestore (implementation not shown, assuming you have a method for this)

    } catch (e) {
      // Remove Loader
      TFullScreenLoader.stopLoading();

      // Show some generic Error to the user
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }

  }
}
