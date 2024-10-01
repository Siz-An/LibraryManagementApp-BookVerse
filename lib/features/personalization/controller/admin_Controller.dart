import 'package:book_Verse/common/network_check/network_manager.dart';
import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:book_Verse/features/personalization/profile/widgets/re_authenticate_user_login_form.dart';
import 'package:book_Verse/utils/constants/sizes.dart';
import 'package:book_Verse/utils/popups/fullscreen_loader.dart';
import 'package:book_Verse/utils/popups/loaders.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/authentication/repository/adminRepo.dart';
import '../../../data/authentication/repository/authentication/admin_auth_repo.dart';
import '../../../utils/constants/image_strings.dart';
import '../models/adminModels.dart';

class AdminController extends GetxController {
  static AdminController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<AdminModel> admin = AdminModel.empty().obs;

  final imageUploading = false.obs;
  final hidePassword = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final adminRepository = Get.put(AdminRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchAdminRecord();
  }

  ///---> Retrieving Record from FireBase
  Future<void> fetchAdminRecord() async {
    try {
      profileLoading.value = true;
      final fetchedAdmin = await adminRepository.fetchAdminDetails();
      admin(fetchedAdmin);
    } catch (e) {
      admin(AdminModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  /// Save Admin Record from any Registration Provider
  Future<void> saveAdminRecord(UserCredential? userCredentials) async {
    try {
      await fetchAdminRecord();
      if (admin.value.id.isEmpty && userCredentials != null) {
        final nameParts = AdminModel.nameParts(userCredentials.user!.displayName ?? '');
        final userName = AdminModel.generateUsername(userCredentials.user!.displayName ?? '');

        final newAdmin = AdminModel(
          id: userCredentials.user!.uid,
          firstName: nameParts[0],
          lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : ' ',
          userName: userName,
          email: userCredentials.user!.email ?? ' ',
          phoneNumber: userCredentials.user!.phoneNumber ?? ' ',
          profilePicture: userCredentials.user!.photoURL ?? ' ',
          role: 'Admin',
          permissions: ['view', 'edit', 'delete'],
        );

        await adminRepository.saveAdminRecord(newAdmin);
      }
    } catch (e) {
      TLoaders.warningSnackBar(
        title: 'Error Saving data',
        message: 'Something went wrong while saving your credentials',
      );
    }
  }

  /// Update Admin Email
  Future<void> updateAdminEmail(String newEmail) async {
    try {
      if (newEmail.isNotEmpty) {
        await adminRepository.updateAdminDetails;
        admin.update((val) {
          val?.email = newEmail;
        });
        Get.snackbar('Success', 'Email updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update email: $e');
    }
  }

  /// Update Admin Phone Number
  Future<void> updateAdminPhoneNumber(String newPhoneNumber) async {
    try {
      if (newPhoneNumber.isNotEmpty) {
        await adminRepository.updateAdminDetails;
        admin.update((val) {
          val?.phoneNumber = newPhoneNumber;
        });
        Get.snackbar('Success', 'Phone number updated successfully');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update phone number: $e');
    }
  }

  /// Delete Account Warning
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(TSizes.md),
      title: 'Delete Account',
      middleText:
      'Are you sure? After deleting your account, you will not be able to retrieve your data!',
      confirm: ElevatedButton(
        onPressed: () async => deleteAdminAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: TSizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
        child: const Text('Cancel'),
      ),
    );
  }

  /// Delete Admin Account
  Future<void> deleteAdminAccount() async {
    try {
      TFullScreenLoader.openLoadingDialogue('Processing', TImages.checkRegistration);

      final auth = AdminAuthenticationRepository.instance;
      final provider = auth.authAdmin!.providerData.map((e) => e.providerId).first;

      if (provider.isNotEmpty) {
        if (provider == 'google.com') {
          await auth.signInWithGoogle();
          await auth.deleteAccount();
          TFullScreenLoader.stopLoading();
          Get.offAll(() => LoginScreen());
        } else if (provider == 'password') {
          TFullScreenLoader.stopLoading();
          Get.to(() => const ReAuthenticateLoginForm());
        }
      }
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Re-authenticate Email and Password before Deleting Admin Account
  Future<void> reAuthenticateEmailAndPasswordAdmin() async {
    try {
      TFullScreenLoader.openLoadingDialogue('Processing', TImages.checkRegistration);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        TFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        TFullScreenLoader.stopLoading();
        return;
      }

      await AdminAuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(
          verifyEmail.text.trim(), verifyPassword.text.trim());
      await AdminAuthenticationRepository.instance.deleteAccount();
      TFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  /// Upload Profile Image
  Future<void> uploadAdminProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );

      if (image != null) {
        imageUploading.value = true;
        final imageUrl = await adminRepository.uploadImage('admin/Images/Profile/', image);

        await adminRepository.updateSingleField({'profilePicture': imageUrl});
        admin.update((val) {
          val?.profilePicture = imageUrl;
        });
        TLoaders.successSnackBar(title: 'Congrats', message: 'Profile picture uploaded successfully');
      }
    } catch (e) {
      TLoaders.errorSnackBar(title: 'Oh Snap!', message: 'Error uploading profile picture: $e');
    } finally {
      imageUploading.value = false;
    }
  }

}
