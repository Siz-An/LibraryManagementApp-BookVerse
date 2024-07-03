import 'package:book_Verse/common/widgets/appbar/appbar.dart';
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

class userScreen extends StatelessWidget {
  const userScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    return Scaffold(
      ///--->Appbar
      appBar: const TAppBar(
        showBackArrow: true, title: Text('User Profile'),
      ),
      body: SingleChildScrollView(
        child: Padding(
            padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              ///-----> Profile Screen
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image = networkImage.isNotEmpty ? networkImage :TImages.user;
                      return controller.imageUploading.value
                        ? const TShimmerEffect(width: 80, height: 80, radius: 80,)
                        : TCircularImage(image: image, width: 80, height: 80, isNetworkImage: networkImage.isNotEmpty,);
                    } ),
                    TextButton(onPressed: () => controller.uploadUserProfilePicture(), child: const Text('Change Profile Screen')),
                  ],
                ),
              ),
              ///-----> Details
              const SizedBox(height: TSizes.spaceBtwItems / 2,),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems ,),
              const TSectionHeading(title: 'Profile Information', showActionButton: false,),
              const SizedBox(height: TSizes.spaceBtwItems ),

              TProfileMenu(onPressed: () => Get.to(() => const ChangeName()), title: 'Full Name', value: controller.user.value.fullName),
              TProfileMenu(onPressed: () {  }, title: 'UserName', value: controller.user.value.userName),

              const SizedBox(height: TSizes.spaceBtwItems / 2,),
              const Divider(),
              const SizedBox(height: TSizes.spaceBtwItems ,),

              ///-----> Personal Info
              TProfileMenu(onPressed: () {  }, title: 'UserId ', value:controller.user.value.id, icon: Iconsax.copy,),
              TProfileMenu(onPressed: () {  }, title: 'Email Id', value: controller.user.value.email),
              TProfileMenu(onPressed: () {  }, title: 'Phone number', value: controller.user.value.phoneNumber),
              TProfileMenu(onPressed: () {  }, title: 'Gender', value: 'Male'),
              TProfileMenu(onPressed: () {  }, title: 'Birth Date', value: '9 Dec, 2002'),


              ///----> Delete Account Section
              const SizedBox(height: TSizes.spaceBtwItems * 2),
              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: const Text('Delete Account', style: TextStyle(color: Colors.redAccent),),
                ),
              )

            ],
          ),
        ),
      ),
    );
  }
}
