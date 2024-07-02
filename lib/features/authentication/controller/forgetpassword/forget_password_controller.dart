import 'package:book_Verse/common/network_check/network_manager.dart';
import 'package:book_Verse/data/authentication/repository/authentication_repo.dart';
import 'package:book_Verse/features/authentication/screens/password_configuration/reset_password.dart';
import 'package:book_Verse/utils/popups/fullscreen_loader.dart';
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/image_strings.dart';

class ForgetPasswordController extends GetxController{
  static ForgetPasswordController get instance => Get.find();

  // variables
    final email = TextEditingController();
    GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  /// Send Reset Password Email
      sendPasswordResetEmail()async{
        try{
          //Start Loading
          TFullScreenLoader.openLoadingDialogue('Processing your request', TImages.checkRegistration);

          //check Internet Connection
          final isConnected = await NetworkManager.instance.isConnected();
          if(!isConnected){TFullScreenLoader.stopLoading(); return;}

          // Form Validation
          if(!forgetPasswordFormKey.currentState!.validate()){
            TFullScreenLoader.stopLoading();
            return;
          }
          await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

          //remove the loader
          TFullScreenLoader.stopLoading();

          //Show Success Screen
          TLoaders.successSnackBar(title: 'Email Sent', message: 'Email Link sent to Reset your password');

          //Redirect
          Get.to(() => ResetPasswordScreen(email: email.text.trim()));
        } catch (e){
          TFullScreenLoader.stopLoading();
          TLoaders.errorSnackBar(title: 'oh Snap', message: e.toString());
        }
      }

      resendPasswordResetEmail(String email) async{
        try{
          //Start Loading
          TFullScreenLoader.openLoadingDialogue('Processing your request', TImages.checkRegistration);

          //check Internet Connection
          final isConnected = await NetworkManager.instance.isConnected();
          if(!isConnected){TFullScreenLoader.stopLoading(); return;}

          await AuthenticationRepository.instance.sendPasswordResetEmail(email);

          //remove the loader
          TFullScreenLoader.stopLoading();

          //Show Success Screen
          TLoaders.successSnackBar(title: 'Email Sent', message: 'Email Link sent to Reset your password');

        } catch (e){
          TFullScreenLoader.stopLoading();
          TLoaders.errorSnackBar(title: 'oh Snap', message: e.toString());
        }

      }
}