import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(110),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 18),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.admin_panel_settings_rounded, color: Colors.white, size: 34),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Admin Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        letterSpacing: 1.1,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 12),
        child: ListView(
          children: [
            const SizedBox(height: 18),
            Center(
              child: Column(
                children: [
                  Obx(() {
                    final networkImage = controller.admin.value.profilePicture;
                    final image = networkImage.isNotEmpty
                        ? networkImage
                        : TImages.user;
                    return controller.imageUploading.value
                        ? const TShimmerEffect(width: 90, height: 90, radius: 90)
                        : Container(
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 16,
                                  offset: Offset(0, 6),
                                ),
                              ],
                              border: Border.all(
                                color: const Color(0xFF4A4E69),
                                width: 2.5,
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: TCircularImage(
                              image: image,
                              width: 90,
                              height: 90,
                              isNetworkImage: networkImage.isNotEmpty,
                            ),
                          );
                  }),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    ),
                    onPressed: () => controller.uploadAdminProfilePicture(),
                    icon: const Icon(Iconsax.camera, color: Colors.white, size: 20),
                    label: const Text(
                      'Change Profile Picture',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const TSectionHeading(
                      title: 'Profile Information',
                      showActionButton: false,
                      textColor: Color(0xFF4A4E69),
                    ),
                    const SizedBox(height: 18),
                    TProfileMenu(
                      onPressed: () => Get.to(() => const ChangeName()),
                      title: 'Full Name',
                      value: controller.admin.value.fullName,
                      icon: Iconsax.user,
                    ),
                    TProfileMenu(
                      onPressed: () {},
                      title: 'UserName',
                      value: controller.admin.value.userName,
                      icon: Iconsax.profile_circle,
                    ),
                    const Divider(height: 32, thickness: 1.2),
                    TProfileMenu(
                      onPressed: () {},
                      title: 'Admin Id',
                      value: controller.admin.value.id,
                      icon: Iconsax.copy,
                    ),
                    TProfileMenu(
                      onPressed: () => Get.to(() => const ChangeEmailPassword(changeType: 'Email')),
                      title: 'Email Id',
                      value: controller.admin.value.email,
                      icon: Iconsax.sms,
                    ),
                    TProfileMenu(
                      onPressed: () => Get.to(() => const ChangeEmailPassword(changeType: 'Phone')),
                      title: 'Phone number',
                      value: controller.admin.value.phoneNumber,
                      icon: Iconsax.call,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 36),
            Center(
              child: TextButton.icon(
                onPressed: () => controller.deleteAccountWarningPopup(),
                icon: const Icon(Iconsax.trash, color: Colors.redAccent),
                label: const Text(
                  'Delete Account',
                  style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
