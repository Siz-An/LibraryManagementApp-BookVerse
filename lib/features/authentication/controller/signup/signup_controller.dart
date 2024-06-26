


import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../common/network_check/network_manager.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/fullscreen_loader.dart';
import '../../../../utils/popups/loaders.dart';

class SignupController extends GetxController{
  static SignupController get instance => Get.find();

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
       if(!isConnected){
         TFullScreenLoader.stopLoading();
         return;
       }
        // Form Validation
      if(signupFormKey.currentState!.validate()){
        TFullScreenLoader.stopLoading();
        return;
      }

    } catch(e){
        TLoaders.errorSnackBar(title: 'oh Snap!', message: e.toString());
    } finally{
        TFullScreenLoader.stopLoading();
    }
  }
}
