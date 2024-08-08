import 'package:book_Verse/data/authentication/repository/authentication/admin_auth_repo.dart';
import 'package:book_Verse/features/home/screens/admin/userRequest/requests.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/proFile/settings_menu.dart';
import '../../../../utils/constants/sizes.dart';
import 'BookIssue/Issuing.dart';
import 'editScreen.dart';
import 'notification/notificationScreen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
        child: Column(
          children: [
            SizedBox(height: TSizes.spaceBtwSections),
            Text(
              'Manage Your Settings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: TSizes.spaceBtwSections),
            Expanded(
              child: ListView(
                children: [
                  TSettingMenu(
                    icon: Iconsax.bookmark,
                    title: 'Notification',
                    subTitle: 'Send Notification to Users',
                    onTap: () => Get.to(() => NotificationScreen()),
                  ),
                  TSettingMenu(
                    icon: Iconsax.archive_tick,
                    title: 'Issue',
                    subTitle: 'List books that the Librarian has Issued',
                    onTap: ()=> Get.to(() => bookIssuing()),
                  ),
                  TSettingMenu(
                    icon: Iconsax.receipt,
                    title: 'Return History',
                    subTitle: 'Books that the user has returned',
                    onTap: () => Get.to(() => Requests()),
                  ),
                  TSettingMenu(
                    icon: Iconsax.alarm,
                    title: 'Book Return Notice',
                    subTitle: 'List books that the user has to return',
                    onTap: () {},
                  ),
                  TSettingMenu(
                    icon: Iconsax.export,
                    title: 'Exchange',
                    subTitle: 'User can exchange books among themselves.',
                    onTap: () {},
                  ),
                  TSettingMenu(
                    icon: Iconsax.search_normal,
                    title: 'Search Screen',
                    subTitle: 'Chat with Students',
                    onTap: () => Get.to(() => SearchBookScreen()),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),
                  ElevatedButton(
                    onPressed: () {
                      _showLogoutConfirmationDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                      padding: EdgeInsets.symmetric(vertical: 16.0), // Add some padding
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0), // Rounded corners
                      ),
                    ),
                    child: const Text('Logout', style: TextStyle(fontSize: 16)),
                  ),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
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
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Confirm'),
            onPressed: () {
              // Call logout method here
              Get.find<AdminAuthenticationRepository>().logout();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
