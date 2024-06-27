


import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/network_check/network_manager.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/fullscreen_loader.dart';
import '../../../../utils/popups/loaders.dart';

class SignupController extends GetxController{
  static SignupController get instance => Get.find();

  ///----> Variables
  final hidePassword = true.obs;
  final privacyPolicy = false.obs;
  final  email = TextEditingController();
  final  lastName = TextEditingController();
  final  firstName = TextEditingController();
  final  userId = TextEditingController();
  final  password = TextEditingController();
  final  phoneNo = TextEditingController();
  final  userName = TextEditingController();
  GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();

  Future<void> signup() async{
    try{

      // Start loading
      TFullScreenLoader.openLoadingDialogue('We are processing your information....', TImages.darkAppLogo);

      // Check Internet Connectivity
       final isConnected = await NetworkManager.instance.isConnected();
       if(!isConnected) return;

        // Form Validation
      if(signupFormKey.currentState!.validate()) return;

      //Privacy policy check
      if(!privacyPolicy.value) {
        TLoaders.warningSnackBar(
            title: 'Accept Privacy Policy',
            message: 'In order to create an account you have to accept privacy policy and terms of use.'
        );
        return;
      }
      // Register user in the fireBase authentication


    } catch(e){
        TLoaders.errorSnackBar(title: 'oh Snap!', message: e.toString());
    } finally{
        TFullScreenLoader.stopLoading();
    }
  }
}
