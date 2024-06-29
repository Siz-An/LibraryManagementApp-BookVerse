

import 'package:book_Verse/data/user/user_repo.dart';
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../models/userModels.dart';

class UserController extends GetxController{
  static UserController get instance => Get.find();

  final userRepository = Get.put(UserRepo());

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