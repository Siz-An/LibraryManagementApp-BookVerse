import 'package:book_Verse/data/authentication/repository/authentication_repo.dart';
import 'package:book_Verse/data/authentication/repository/userRepo.dart';
import 'package:book_Verse/features/home/screens/admin/adminDashbord/admin_dashbord.dart';
import 'package:book_Verse/features/home/screens/users/home/home.dart';
import 'package:book_Verse/utils/constants/image_strings.dart';
import 'package:book_Verse/utils/popups/fullscreen_loader.dart';
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:book_Verse/common/network_check/network_manager.dart';

import '../../../../navigation_menu/admin_navigation_menu.dart';
import '../../../../navigation_menu/navigation_menu.dart';
import '../../../personalization/controller/user_Controller.dart';

class LoginController extends GetxController {
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.find<UserController>();

  Future<void> emailAndPasswordSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialogue('Logging you In....', TImages.checkRegistration);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
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
      final userRepo = Get.find<UserRepository>();
      final user = await userRepo.fetchUserDetails();

      TFullScreenLoader.stopLoading();
      if (user.isAdmin) {
        Get.offAll(() => AdminNavigationMenu());
      } else {
        Get.offAll(() => NavigationMenu());
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  Future<void> googleSignIn() async {
    try {
      TFullScreenLoader.openLoadingDialogue('Logging you in......', TImages.checkRegistration);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        TLoaders.errorSnackBar(title: 'No Internet', message: 'Please check your internet connection.');
        return;
      }

      final userCredentials = await AuthenticationRepository.instance.signInWithGoogle();
      await userController.saveUserRecord(userCredentials, 'user');
      final userRepo = Get.find<UserRepository>();
      final user = await userRepo.fetchUserDetails();

      TFullScreenLoader.stopLoading();
      if (user.isAdmin) {
        Get.offAll(() => AdminNavigationMenu());
      } else {
        Get.offAll(() => NavigationMenu());
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
