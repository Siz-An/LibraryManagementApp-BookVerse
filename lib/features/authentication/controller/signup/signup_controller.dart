import 'package:book_Verse/data/user/user_repo.dart';
import 'package:book_Verse/features/authentication/screens/signup/verify_email.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import '../../../../common/network_check/network_manager.dart';
import '../../../../data/authentication/repository/authentication_repo.dart';
import '../../../../data/authentication/repository/userRepo.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/fullscreen_loader.dart';
import '../../../../utils/popups/loaders.dart';
import '../../../personalization/models/userModels.dart';

class SignupController extends GetxController {
  static SignupController get instance => Get.find();

  final hidePassword = true.obs;
  final privacyPolicy = false.obs;
  final email = TextEditingController();
  final lastName = TextEditingController();
  final firstName = TextEditingController();
  final password = TextEditingController();
  final phoneNumber = TextEditingController();
  final userName = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  // Add a variable to hold the selected role
  final selectedRole = 'User'.obs;
  final roles = ['User', 'Admin'].obs;

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
      // Check if an admin already exists
      final userRepo = Get.put(UserRepository());
      final isAdminExists = await userRepo.checkIfAdminExists();

      // If an admin already exists and the user selected 'Admin', show a dialog box and return
      if (isAdminExists && selectedRole.value == 'Admin') {
        TFullScreenLoader.stopLoading();
        Get.defaultDialog(
          title: 'Admin Already Exists',
          content: Text('You cannot sign up as an admin. An admin already exists! Please sign up as a user.'),
          textConfirm: 'OK',
          onConfirm: () {
            Get.back();
          },
        );
        return;
      }

      // Register user in the Firebase authentication
      final userCredential = await AuthenticationRepository.instance.registerWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Set the role based on whether an admin exists
      final isAdmin = !isAdminExists && selectedRole.value == 'Admin';

      // Save Authenticated user data in the Firebase FireStore
      final newUser = UserModel(
        id: userCredential.user!.uid,
        firstName: firstName.text.trim(),
        lastName: lastName.text.trim(),
        userName: userName.text.trim(),
        email: email.text.trim(),
        phoneNumber: phoneNumber.text.trim(),
        profilePicture: '',
        isAdmin: isAdmin, // Set as admin if no admin exists and selected role is Admin
      );

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
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }
}
