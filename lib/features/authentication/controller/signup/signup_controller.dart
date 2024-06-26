
import 'dart:js_interop';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/fullscreen_loader.dart';

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
      // final isConnected = await NetworkManager.instance.isConnected();

    } catch(e){

    } finally{

    }
  }
}
