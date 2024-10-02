import 'dart:io';
import 'package:book_Verse/features/personalization/models/adminModels.dart';
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
import 'authentication/admin_auth_repo.dart';

class AdminRepository extends GetxController {
  static AdminRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Function to save admin data in Firestore
  Future<void> saveAdminRecord(AdminModel admin) async {
    try {
      await _db.collection("Admins").doc(admin.id).set(admin.toJson());
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

  /// Function to fetch admin details based on admin ID
  Future<AdminModel> fetchAdminDetails() async {
    try {
      final documentSnapshot = await _db.collection("Admins").doc(AdminAuthenticationRepository.instance.authAdmin?.uid).get();
      if (documentSnapshot.exists) {
        return AdminModel.fromSnapshot(documentSnapshot);
      } else {
        return AdminModel.empty();
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

  /// Function to update admin details
  Future<void> updateAdminDetails(AdminModel updateAdmin) async {
    try {
      await _db.collection("Admins").doc(updateAdmin.id).update(updateAdmin.toJson());
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

  /// Function to update any field in specific Admin Collection
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      await _db.collection("Admins").doc(AdminAuthenticationRepository.instance.authAdmin?.uid).update(json);
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

  /// Function to remove admin data from Firestore
  Future<void> removeAdminRecord(String adminId) async {
    try {
      await _db.collection("Admins").doc(adminId).delete();
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

  /// Function to upload any image
  Future<String> uploadImage(String path, XFile image) async {
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

  /// Function to get the count of Admins in the Firestore collection
  Future<int> getAdminCount() async {
    try {
      // Fetch the number of admin documents in the 'Admins' collection
      final querySnapshot = await _db.collection("Admins").get();
      return querySnapshot.docs.length;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code).message; // Handle Firebase-specific errors
    } catch (e) {
      throw 'Error fetching admin count: $e'; // General error
    }
  }

  updateAdminField(String s, String newPhoneNumber) {}
}
