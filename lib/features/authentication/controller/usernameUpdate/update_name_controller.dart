

import 'package:book_Verse/common/network_check/network_manager.dart';
import 'package:book_Verse/data/authentication/repository/userRepo.dart';
import 'package:book_Verse/features/personalization/controller/user_Controller.dart';
import 'package:book_Verse/features/personalization/profile/widgets/users_Screen.dart';
import 'package:book_Verse/utils/constants/image_strings.dart';
import 'package:book_Verse/utils/popups/fullscreen_loader.dart';
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class UpdateNameController extends GetxController{
  static UpdateNameController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  ///---> Fetch User Record
  Future<void> initializeNames() async{
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
  }
  Future<void> updateUserName() async{
    try{
      TFullScreenLoader.openLoadingDialogue('We are updating your information', TImages.checkRegistration);

      final isConnected = await NetworkManager.instance.isConnected();
      if(!isConnected){
        TFullScreenLoader.stopLoading();
        return;
      }
      //form Validation
      if(!updateUserNameFormKey.currentState!.validate()){
        TFullScreenLoader.stopLoading();
        return;
      }

      // Update User's First and last name in the firebase fireStore
      Map<String, dynamic> name = {'FirstName': firstName.text.trim(),'LastName': lastName.text.trim()};
      await userRepository.updateSingleField(name);

      //update the Rx user value
      userController.user.value.firstName = firstName.text.trim();
      userController.user.value.lastName = lastName.text.trim();

      //remove loader
      TFullScreenLoader.stopLoading();

      //Show Success Screen
      TLoaders.successSnackBar(title: 'Congrats', message: 'Your Name has been updated');

      //Move to previous Screen
      Get.off(() => const userScreen() );
    }catch(e){
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Oh Snap!!', message: e.toString());
    }
  }
}