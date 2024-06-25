import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:get_storage/get_storage.dart';

import '../../features/authentication/screens/onboarding.dart';
class AuthenticationRepository extends GetxController{
  static AuthenticationRepository get instance => Get.find();

  /// Variables
   final deviceStorage = GetStorage();


   /// Called from main.dart on app launch
   @override
 void onReady(){
     FlutterNativeSplash.remove();
     screenRedirect();
   }

   ///---> Function to show Relevant Screen
   screenRedirect() async{
     // local Storage
     if(kDebugMode){
       print('============Get Storage===========');
       print(deviceStorage.read('isFirstTime'));
     }
     deviceStorage.writeIfNull('isFirstTime', true);
     deviceStorage.read('isFirstTime') != true ? Get.offAll(() => const LoginScreen()) : Get.offAll(() => const OnBoardingScreen());

   }

   /*-------------------------Email & Password Sign in---------------------------*/
}