import 'package:book_Verse/common/widgets/custom_shapes/primary_header_container.dart';
import 'package:book_Verse/common/widgets/proFile/settings_menu.dart';
import 'package:book_Verse/common/widgets/texts/section_heading.dart';
import 'package:book_Verse/features/personalization/profile/widgets/users_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/proFile/user_profile_tile.dart';
import '../../../data/authentication/repository/authentication/authentication_repo.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../home/screens/dataforuser/returnhistory.dart';
import '../../home/screens/user/bookreturnsss.dart';
import '../../home/screens/user/mark/markApp.dart';
import '../../home/screens/user/mark/requestssss.dart';
import '../../home/screens/user/notification.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthenticationRepository.instance.authUser?.uid ?? '';

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///----> Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  ///----> App Bar
                  AppBar(
                    title: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white),
                    ),
                  ),

                  ///----> UserProfile
                  TUserProfileTitle(onPressed: () => Get.to(() => const userScreen())),

                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
            ///----> Body
            Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [
                  ///---> Account Settings
                  const TSectionHeading(title: 'Account Settings', showActionButton: false,),
                  const SizedBox(height: TSizes.spaceBtwItems),

                  // Settings
                  TSettingMenu(
                    icon: Iconsax.notification,
                    title: 'Notification',
                    subTitle: 'Please check Notification Daily',
                    onTap: () => Get.to(() => notificationScreen()),
                  ),
                  Divider(),
                  TSettingMenu(
                    icon: Iconsax.bookmark,
                    title: 'BookMark',
                    subTitle: 'List books that the user has BookMarked',
                    onTap: () => Get.to(() => MarkApp()),
                  ),
                  Divider(),
                  TSettingMenu(
                    icon: Iconsax.archive_tick,
                    title: 'Request',
                    subTitle: 'List books that the User Requested',
                    onTap: () => Get.to(() => RequestedListScreen()),
                  ),
                  Divider(),
                  TSettingMenu(
                    icon: Iconsax.receipt,
                    title: 'Return History',
                    subTitle: 'Books that the user has returned',
                    onTap: () => Get.to(() => ReturnHistory()),
                  ),
                  Divider(),
                  TSettingMenu(
                    icon: Iconsax.alarm,
                    title: 'Book Return Notice',
                    subTitle: 'List books that the user have to return',
                    onTap: () => Get.to(() => ToBeReturnedBooksScreen(userId: userId)),
                  ),

                  Divider(),
                  const SizedBox(height: TSizes.spaceBtwItems,),

                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.green, // Text color of the button
                        padding: EdgeInsets.symmetric(vertical: 12.0), // Add some padding
                      ),
                      child: const Text('Logout'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

///---> Confirmation Logout Button
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
            child: Text('Confirm'),
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
