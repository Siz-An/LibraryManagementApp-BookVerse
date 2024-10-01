import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:book_Verse/common/widgets/appbar/appbar.dart';
import 'package:book_Verse/common/widgets/images/t_circular_image.dart';
import 'package:book_Verse/common/widgets/texts/section_heading.dart';
import 'package:book_Verse/features/personalization/controller/admin_Controller.dart';
import 'package:book_Verse/features/personalization/profile/widgets/changeName.dart';
import 'package:book_Verse/features/personalization/profile/widgets/profile_menu.dart';
import 'package:book_Verse/utils/constants/shimmer.dart';
import 'package:book_Verse/utils/constants/image_strings.dart';
import 'package:book_Verse/utils/constants/sizes.dart';

import 'adminSett/email.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminController>();
    return Scaffold(
      appBar: const TAppBar(
        showBackArrow: true,
        title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Profile Screen
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.admin.value.profilePicture;
                      final image = networkImage.isNotEmpty
                          ? networkImage
                          : TImages.user;
                      return controller.imageUploading.value
                          ? const TShimmerEffect(width: 80, height: 80, radius: 80)
                          : TCircularImage(image: image, width: 80, height: 80, isNetworkImage: networkImage.isNotEmpty);
                    }),
                    TextButton(
                      onPressed: () => controller.uploadAdminProfilePicture(),
                      child: const Text('Change Profile Screen'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),
              const TSectionHeading(title: 'Profile Information', showActionButton: false),
              const SizedBox(height: TSizes.spaceBtwItems),

              TProfileMenu(onPressed: () => Get.to(() => const ChangeName()), title: 'Full Name', value: controller.admin.value.fullName),
              TProfileMenu(onPressed: () {}, title: 'UserName', value: controller.admin.value.userName),

              const SizedBox(height: TSizes.spaceBtwItems / 2),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems),

              /// Personal Info
              TProfileMenu(onPressed: () {}, title: 'Admin Id', value: controller.admin.value.id, icon: Iconsax.copy),

              TProfileMenu(
                onPressed: () => Get.to(() => const ChangeEmailPassword(changeType: 'Email')),
                title: 'Email Id',
                value: controller.admin.value.email,
              ),

              TProfileMenu(
                onPressed: () => Get.to(() => const ChangeEmailPassword(changeType: 'Phone')),
                title: 'Phone number',
                value: controller.admin.value.phoneNumber,
              ),

              const SizedBox(height: TSizes.spaceBtwItems * 2),
              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: const Text('Delete Account', style: TextStyle(color: Colors.redAccent)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
