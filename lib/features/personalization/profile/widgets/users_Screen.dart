import 'package:book_Verse/common/widgets/images/t_circular_image.dart';
import 'package:book_Verse/common/widgets/texts/section_heading.dart';
import 'package:book_Verse/features/personalization/profile/widgets/changeName.dart';
import 'package:book_Verse/features/personalization/profile/widgets/profile_menu.dart';
import 'package:book_Verse/utils/constants/shimmer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../controller/user_Controller.dart';

class UserScreen extends StatelessWidget {
  const UserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
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
              padding: const EdgeInsets.symmetric(horizontal: 22.0, vertical: 18),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.person, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'User Profile',
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        children: [
          // Profile Picture & Change Button
          Center(
            child: Column(
              children: [
                Obx(() {
                  final networkImage = controller.user.value.profilePicture;
                  final image = networkImage.isNotEmpty ? networkImage : TImages.user;
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
                            border: Border.all(color: Color(0xFF9A8C98), width: 2),
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
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E69),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () => controller.uploadUserProfilePicture(),
                  icon: const Icon(Iconsax.camera, color: Colors.white, size: 20),
                  label: const Text(
                    'Change Photo',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          // Profile Information Section
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TSectionHeading(
                    title: 'Profile Information',
                    showActionButton: false,
                  ),
                  const SizedBox(height: 18),
                  TProfileMenu(
                    onPressed: () => Get.to(() => const ChangeName()),
                    title: 'Full Name',
                    value: controller.user.value.fullName,
                  ),
                  TProfileMenu(
                    onPressed: () {},
                    title: 'Username',
                    value: controller.user.value.userName,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          // Personal Info Section
          Card(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const TSectionHeading(
                    title: 'Personal Info',
                    showActionButton: false,
                  ),
                  const SizedBox(height: 18),
                  TProfileMenu(
                    onPressed: () {},
                    title: 'User ID',
                    value: controller.user.value.id,
                    icon: Iconsax.copy,
                  ),
                  TProfileMenu(
                    onPressed: () {},
                    title: 'Email',
                    value: controller.user.value.email,
                  ),
                  TProfileMenu(
                    onPressed: () {},
                    title: 'Phone',
                    value: controller.user.value.phoneNumber,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 36),
          // Delete Account Button
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
        ],
      ),
    );
  }
}
