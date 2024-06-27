
import 'package:get/get.dart';

class VerifyEmailController extends GetxController{
  static VerifyEmailController get instance => Get.find();

  /// --> Send Email Whenever verify Screen Appears & set timer for auto redirect
  @override
  void onInit(){
    super.onInit();
  }
  /// --> Send Email Verification Link
  /// --> Timer Automatically redirect on email verification screen
  /// --> Manually Check if email is Verified
}