
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../../data/authentication/repository/userRepo.dart';
import '../models/userModels.dart';

class UserController extends GetxController{
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;
  final userRepository = Get.put(UserRepository());


  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async{
    try{
      profileLoading.value = true;
      final user = await userRepository.fetchUserDetails();
      this.user(user);
    } catch (e) {
      user(UserModel.empty());
    }finally{
      profileLoading.value = false;
    }
  }

  /// Save User Record from any Registration Provider

    Future<void> saveUserRecord(UserCredential? userCredentials) async{

      try{
        if(userCredentials !=null){
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
              phoneNo: userCredentials.user!.phoneNumber ?? ' ',
              profilePicture: userCredentials.user!.photoURL ?? ' '
          );

          // save user data
          await userRepository.saveUserRecord(user);
        }
      }catch(e){
        TLoaders.warningSnackBar(title: 'Data not Saved',
        message: 'Something went Wrong while saving your credentials'
        );
      }

    }
}