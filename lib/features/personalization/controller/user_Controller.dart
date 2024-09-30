import 'package:book_Verse/common/network_check/network_manager.dart';
import 'package:book_Verse/data/authentication/repository/authentication/authentication_repo.dart';
import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:book_Verse/features/personalization/profile/widgets/re_authenticate_user_login_form.dart';
import 'package:book_Verse/utils/constants/sizes.dart';
import 'package:book_Verse/utils/popups/fullscreen_loader.dart';
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/authentication/repository/userRepo.dart';
import '../../../utils/constants/image_strings.dart';
import '../models/userModels.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;

  Rx<UserModel> user = UserModel.empty().obs;

  final imageUploading = false.obs;
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  ///---> Retrieving Record from FireBase
  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save User Record from any Registration Provider
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      // First Update Rx User and then check if the user data is already stored. If not store new data
      await fetchUserRecord();
      // If no record is already stored.
      if(user.value.id.isEmpty) {
        if (userCredentials != null) {
          //convert Name to first and last nam
          final nameParts = UserModel.nameParts(userCredentials.user!.displayName ?? '');
          final userName = UserModel.generateUsername(userCredentials.user!.displayName ?? '');

          // Map Data
          final user = UserModel(
              id: userCredentials.user!.uid,
              firstName: nameParts[0],
              lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ' ',
              userName: userName,
              email: userCredentials.user!.email ?? ' ',
              phoneNumber: userCredentials.user!.phoneNumber ?? ' ',
              profilePicture: userCredentials.user!.photoURL ?? ' ',
              role: 'User'
          );

          // save user data
          await userRepository.saveUserRecord(user);
        }
      }
    } catch (e) {
      TLoaders.warningSnackBar(title: 'Error Saving data',
          message: 'Something went Wrong while saving your credentials'
      );
    }
  }


  /// Delete Account Warning
  void deleteAccountWarningPopup(){
  Get.defaultDialog(
    contentPadding: const EdgeInsets.all(TSizes.md),
    title: 'Delete Account',
    middleText:
      'Are you Sure. After deleting Your Account you will not be able to retrieve your data!!!!!!',
    confirm: ElevatedButton(onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, side: const BorderSide(color: Colors.red) ),
        child: const Padding(padding: EdgeInsets.symmetric(horizontal: TSizes.lg), child: Text('Delete')),
    ),
    cancel: OutlinedButton(onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Cancel')
          )
  );
        }

  ///----> Delete User Account
  void deleteUserAccount() async{
    try{
      TFullScreenLoader.openLoadingDialogue('Processing', TImages.checkRegistration);

      /// First Re-Auth User
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;
      if(provider.isNotEmpty){
        //Re verify Email
        if(provider == 'google.com'){
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          TFullScreenLoader.stopLoading();
          Get.offAll(() => LoginScreen());
        }else if(provider == 'password'){
          TFullScreenLoader.stopLoading();
          Get.to(() => const ReAuthenticateLoginForm());
        }
      }
    }catch(e){
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
        }

  ///----> Re-auth before deleting Account
  Future<void> reAuthenticateEmailAndPasswordUser() async {
          try {
            TFullScreenLoader.openLoadingDialogue('Processing', TImages.checkRegistration);

            // Check Internet Connection
            final isConnected = await NetworkManager.instance.isConnected();
            if(!isConnected){
              TFullScreenLoader.stopLoading();
              return;
            }

            if(!reAuthFormKey.currentState!.validate()){
              TFullScreenLoader.stopLoading();
              return;
            }
            await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(verifyEmail.text.trim(), verifyPassword.text.trim());
            await AuthenticationRepository.instance.deleteAccount();
            TFullScreenLoader.stopLoading();
            Get.offAll(() => const LoginScreen());
          } catch (e) {
            TFullScreenLoader.stopLoading();
            TLoaders.warningSnackBar(title: 'oh Snap', message: e.toString());

          }
        }

  ///----> Upload Profile Image
  uploadUserProfilePicture() async{
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512);
      if (image != null) {
        imageUploading.value = true;
        final imageUrl = await userRepository.uploadImage(
            'user/Images/Profile/', image);

        //update User Image Record
        Map<String, dynamic> json = {'ProfilePicture': imageUrl};
        await userRepository.updateSingleField(json);

        user.value.profilePicture = imageUrl;
        user.refresh();

        TLoaders.successSnackBar(title: 'Congrats', message: 'Your profile Picture has been Uploaded');
      }
    }catch(e){
      TLoaders.errorSnackBar(title: 'oh fuck', message: 'You messed up something: $e');
    }finally{
      imageUploading.value = false;
    }
  }
}