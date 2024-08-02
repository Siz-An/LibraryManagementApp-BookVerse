
import 'package:book_Verse/data/authentication/repository/authentication/admin_auth_repo.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/proFile/settings_menu.dart';
import '../../../../utils/constants/sizes.dart';
import 'ChatScreen.dart';
import 'dashboard.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ///----> Body
            SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(height: TSizes.spaceBtwSections),
            SizedBox(height: TSizes.spaceBtwSections),

            Padding(padding: const EdgeInsets.all(TSizes.defaultSpace),
              child: Column(
                children: [

                  // Settings
                  TSettingMenu(icon: Iconsax.bookmark, title: 'BookMark', subTitle: 'List books that the user has BookMarked', onTap: () => Get.to(() => DashboardScreen())),
                  TSettingMenu(icon: Iconsax.archive_tick, title: 'Issue', subTitle: 'List books that the Librarian has Issued', onTap: (){},),
                  TSettingMenu(icon: Iconsax.receipt, title: 'Return History', subTitle: 'Books that the user has returned', onTap: (){},),
                  TSettingMenu(icon: Iconsax.alarm, title: 'Book Return Notice', subTitle: 'List books that the user have to return', onTap: (){},),
                  TSettingMenu(icon: Iconsax.export, title: 'Exchange', subTitle: 'User can exchange books among themselves.', onTap: (){},),
                  TSettingMenu(icon: Iconsax.search_normal, title: 'Search Screen', subTitle: 'Chat with Students', onTap: ()=> Get.to(() => NotificationScreen())),
                  // Logout button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _showLogoutConfirmationDialog(context);
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color of the button
                        padding: EdgeInsets.symmetric(vertical: 16.0), // Add some padding
                      ),
                      child: const Text('Logout'),
                    ),
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
              Get.find<AdminAuthenticationRepository>().logout();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
