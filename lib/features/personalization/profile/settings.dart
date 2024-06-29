
import 'package:book_Verse/common/widgets/appbar/appbar.dart';
import 'package:book_Verse/common/widgets/custom_shapes/primary_header_container.dart';
import 'package:book_Verse/common/widgets/proFile/settings_menu.dart';
import 'package:book_Verse/common/widgets/texts/section_heading.dart';
import 'package:book_Verse/features/personalization/profile/widgets/users_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:iconsax/iconsax.dart';

import '../../../common/widgets/proFile/user_profile_tile.dart';
import '../../../data/authentication/repository/authentication_repo.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../authentication/screens/login/login.dart';

class settingScreen extends StatelessWidget {
  const settingScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///----> Header
            TPrimaryHeaderContainer(child: Column(
              children: [
                ///----> App Bar
            TAppBar(title: Text('Settings', style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white),
            ),),

                ///----> UserProfile
                 TUserProfileTitle(onPressed: () => Get.to(() => const userScreen())),

                const SizedBox(height: TSizes.spaceBtwSections),

              ],
            ),),
            ///----> Body
            Padding(padding: const EdgeInsets.all(TSizes.defaultSpace),
            child: Column(
              children: [
                ///---> Account Settings
                const TSectionHeading(title: 'Account Settings',showActionButton: false,),
                const SizedBox(height: TSizes.spaceBtwItems),

                TSettingMenu(icon: Iconsax.reserve, title: 'Reservation', subTitle: 'List books that the user has reserved', onTap: (){},),
                TSettingMenu(icon: Iconsax.reserve, title: 'Reservation', subTitle: 'List books that the user has reserved', onTap: (){},),
                TSettingMenu(icon: Iconsax.reserve, title: 'Reservation', subTitle: 'List books that the user has reserved', onTap: (){},),
                TSettingMenu(icon: Iconsax.reserve, title: 'Reservation', subTitle: 'List books that the user has reserved', onTap: (){},),
                TSettingMenu(icon: Iconsax.reserve, title: 'Overdue', subTitle: 'Display alerts for overdue books.', onTap: (){},),
                TSettingMenu(icon: Iconsax.reserve, title: 'Overdue', subTitle: 'Display alerts for overdue books.', onTap: (){},),
                TSettingMenu(icon: Iconsax.reserve, title: 'Overdue', subTitle: 'Display alerts for overdue books.', onTap: (){},),
                TSettingMenu(icon: Iconsax.reserve, title: 'Overdue', subTitle: 'Display alerts for overdue books.', onTap: (){},),


                ///---> App Settings
                const SizedBox(height: TSizes.spaceBtwSections,),
                const TSectionHeading(title: 'App Settings', showActionButton: false,),
                const SizedBox(height: TSizes.spaceBtwItems,),

                const TSettingMenu(icon: Iconsax.document_upload, title: 'Load Data', subTitle: 'Upload data to your cloud fireBase',),
                TSettingMenu(icon: Iconsax.security_user, title: 'Safe Mode', subTitle: 'Search Result is for all ages',
                    trailing: Switch(value: false, onChanged:(value){}),),
                TSettingMenu(icon: Iconsax.image, title: 'Hd Image Quality', subTitle: 'Set Image Quality to be Seen',
                    trailing: Switch(value: false, onChanged:(value){}),),
                const SizedBox(height: TSizes.spaceBtwItems),
                // Logout button
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutConfirmationDialog(context);
                      },
                      child: const Text('Logout'),
                     )
                     )
              ],
            ),
            )
          ],
        ),
      ),
    );
  }
}
void _showLogoutConfirmationDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Confirm Logout'),
        content: Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Logout'),
            onPressed: () {
              // Call logout method here
              Get.find<AuthenticationRepository>().logout();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
