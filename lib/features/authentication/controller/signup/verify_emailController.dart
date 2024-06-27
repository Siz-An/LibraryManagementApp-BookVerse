
import 'dart:async';

import 'package:book_Verse/common/widgets/sucess_screen/success_screen.dart';
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../../data/authentication/repository/authentication_repo.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/text_strings.dart';

class VerifyEmailController extends GetxController{
  static VerifyEmailController get instance => Get.find();

  /// --> Send Email Whenever verify Screen Appears & set timer for auto redirect
  @override
  void onInit(){
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }
  /// --> Send Email Verification Link

  sendEmailVerification() async {
    try{
      await AuthenticationRepository.instance.sendEmailVerification();
      TLoaders.successSnackBar(title: 'Email Sent' ,message: 'Please Check your Email address' );
    }catch(e){
      TLoaders.errorSnackBar(title: 'oh Snap', message: e.toString());
    }
  }

  /// --> Timer Automatically redirect on email verification screen

    setTimerForAutoRedirect(){
    Timer.periodic(const Duration(seconds: 1), (timer) async {
    await  FirebaseAuth.instance.currentUser?.reload();
    final user = FirebaseAuth.instance.currentUser;
    if(user?.emailVerified ?? false){
      timer.cancel();
      Get.off(() => SuccessScreen(
          image: TImages.successfullyRegisterAnimation,
          title: TTexts.yourAccountCreatedTitle,
          subTitle: TTexts.yourAccountCreatedSubTitle,
          onPressed: () => AuthenticationRepository.instance.screenRedirect(),
      ));
    }
    })
    ;
    }

  /// --> Manually Check if email is Verified
      checkEmailVerificationStatus() async{
    final currentUser = FirebaseAuth.instance.currentUser;
    if(currentUser != null && currentUser.emailVerified){
      Get.off(() => SuccessScreen(
          image: TImages.successfullyRegisterAnimation,
          title: TTexts.yourAccountCreatedTitle,
          subTitle: TTexts.yourAccountCreatedSubTitle,
          onPressed: () => AuthenticationRepository.instance.screenRedirect(),
      ));
    }
    }
      }

