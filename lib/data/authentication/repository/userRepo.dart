import 'dart:io';

import 'package:book_Verse/data/authentication/repository/authentication/authentication_repo.dart';
import 'package:book_Verse/features/personalization/models/userModels.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../utils/exceptions/firebase_auth_exception.dart';
import '../../../utils/exceptions/firebase_exception.dart';
import '../../../utils/exceptions/format_exception.dart';
import '../../../utils/exceptions/platform_exception.dart';

class UserRepository extends GetxController{
  static UserRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save user data in fireStore

    Future<void> saveUserRecord(UserModel user)async{
      try {
        await _db.collection("Users").doc(user.id).set(user.toJson());
      } on FirebaseAuthException catch (e) {
        throw TFirebaseAuthException(e.code).message;
      } on FirebaseException catch (e) {
        throw TFirebaseException(e.code).message;
      } on FormatException catch (_) {
        throw const TFormatException();
      } on PlatformException catch (e) {
        throw TPlatformException(e.code).message;
      } catch (e) {
        throw 'Something went wrong. Please try again.';
      }
    }

    /// Function to fetch user details based on user ID
  Future<UserModel> fetchUserDetails()async{
    try {
      final documentSnapshot =  await _db.collection("Users").doc(AuthenticationRepository.instance.authUser?.uid).get();
      if(documentSnapshot.exists){
        return UserModel.fromSnapshot(documentSnapshot);
      }else {
        return UserModel.empty();
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }


    /// Function to save user data to fireStore
  Future<void> updateUserDetails(UserModel updateUser)async{
    try {
      await _db.collection("Users").doc(updateUser.id).update(updateUser.toJson());
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

    /// update any field in specific User Collection
  Future<void> updateSingleField(Map<String, dynamic> json)async{
    try {
      await _db.collection("Users").doc(AuthenticationRepository.instance.authUser?.uid).update(json);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }
  /// Function to remove user data from FireStore
  Future<void> removeUserRecord(String userId)async{
    try {
      await _db.collection("Users").doc(userId).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const TFormatException();
    } on PlatformException catch (e) {
      throw TPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again.';
    }
  }

      ///Upload any image

      Future<String> uploadImage(String path, XFile image) async{
        try {
          final ref = FirebaseStorage.instance.ref(path).child(image.name);
          await ref.putFile(File(image.path));
          final url = await ref.getDownloadURL();
          return url;

        } on FirebaseException catch (e) {
          throw TFirebaseException(e.code).message;
        } on FormatException catch (_) {
          throw const TFormatException();
        } on PlatformException catch (e) {
          throw TPlatformException(e.code).message;
        } catch (e) {
          throw 'Something went wrong. Please try again.';
        }
      }
      }




