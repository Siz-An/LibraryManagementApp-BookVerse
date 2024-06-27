

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../features/personalization/models/userModels.dart';

class UserRepo extends GetxController{
  static UserRepo get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUserRecord(UserModel user) async{
    try{
      return await _db.collection("Users").doc(user.id).set(user.toJson());
    }on FirebaseException catch(e){
      throw TFirebaseException(e.code).message;
    }on FormatException catch(_){
      throw const TFormatException();
    }on PlatformException catch(e){
      throw TPlatformException(e.code).message;
    } catch(e){
      throw 'SomeThing Went Wrong Please Try Again';
    }
  }
}