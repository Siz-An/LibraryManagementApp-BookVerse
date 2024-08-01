
import 'package:book_Verse/common/network_check/network_manager.dart';
import 'package:book_Verse/data/authentication/repository/authentication/authentication_repo.dart';
import 'package:book_Verse/features/personalization/controller/user_Controller.dart';
import 'package:book_Verse/utils/popups/fullscreen_loader.dart';
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import '../../../../utils/constants/image_strings.dart';

class LoginController extends GetxController{

  //Variables
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());
  final selectedRole = 'User'.obs; // Default to User role

  /// -- Email and Password signIn
  Future<void> emailAndPasswordSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialogue('Logging you In....', TImages.checkRegistration);

      // checking internet connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {  // Proceed only if connected to the internet
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      if (!loginFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (rememberMe.value) {
        localStorage.write('Remember_Me_Email', email.text.trim());
        localStorage.write('Remember_Me_Password', password.text.trim());
      }

      final userCredentials = await AuthenticationRepository.instance.loginWithEmailAndPassword(email.text.trim(), password.text.trim());

      TFullScreenLoader.stopLoading();
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// -- Google Sign In Authentication

  Future<void> googleSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialogue('Logging you in......', TImages.checkRegistration);
      // Checking Internet connection
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {  // Proceed only if connected to the internet
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      // Google authentication
      final userCredentials = await AuthenticationRepository.instance.signInWithGoogle();

      // Save user records
      await userController.saveUserRecord(userCredentials);
      TFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
    }
  }

