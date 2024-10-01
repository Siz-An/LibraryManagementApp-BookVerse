import 'package:book_Verse/data/authentication/repository/authentication/admin_auth_repo.dart';
import 'package:book_Verse/features/home/screens/admin/navigations/requests.dart';
import 'package:book_Verse/features/home/screens/admin/returnedbooks/bookreturnUserScreen.dart';
import 'package:book_Verse/features/home/screens/admin/widgets/adminScreen.dart';
import 'package:book_Verse/features/home/screens/admin/widgets/adminprofile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../common/widgets/appbar/appbar.dart';
import '../../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../DataForAdmin/usersdata.dart';
import '../BookIssue/users.dart';
import 'editScreen.dart';
import '../notification/notificationScreen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min, // Add this to avoid conflicting constraints
          children: [
            ///----> Header
            TPrimaryHeaderContainer(
              child: Column(
                children: [
                  ///----> App Bar
                  TAppBar(
                    title: Text(
                      'Settings',
                      style: Theme.of(context).textTheme.headlineMedium!.apply(color: Colors.white),
                    ),
                  ),

                  ///----> UserProfile
                  TAdminProfileTitle(onPressed: () => Get.to(() => const AdminScreen())),

                  const SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: TSizes.defaultSpace),
              child: Column(
                children: [
                  ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Prevent scrolling inside scrollable
                    children: [
                      TSectionHeading(title: 'Features', showActionButton: false,),
                      _buildSettingItem(
                        context,
                        icon: Iconsax.bookmark,
                        title: 'Notification',
                        subTitle: 'Send Notification to Users',
                        onTap: () => Get.to(() => const NotificationScreen()),
                      ),
                      Divider(),
                      _buildSettingItem(
                        context,
                        icon: Iconsax.archive_tick,
                        title: 'Issued Books',
                        subTitle: 'List books that the Librarian has Issued',
                        onTap: () => Get.to(() => const UsersListScreen()),
                      ),
                      Divider(),
                      _buildSettingItem(
                        context,
                        icon: Iconsax.receipt,
                        title: 'Request List',
                        subTitle: 'Books that to be Issued',
                        onTap: () => Get.to(() =>  AdminUserRequestsScreen()),
                      ),
                      Divider(),
                      _buildSettingItem(
                        context,
                        icon: Iconsax.alarm,
                        title: 'Book Return',
                        subTitle: 'List books that the user has to return',
                        onTap: () => Get.to(() => const AcceptReturnUsersScreen()),
                      ),
                      Divider(),
                      _buildSettingItem(
                        context,
                        icon: Iconsax.export,
                        title: 'DATA',
                        subTitle: 'DATA available here',
                        onTap: () => Get.to(() => const UserListPage()),
                      ),
                      Divider(),
                      _buildSettingItem(
                        context,
                        icon: Iconsax.search_normal,
                        title: 'Search Screen',
                        subTitle: 'Chat with Students',
                        onTap: () => Get.to(() =>  SearchBookScreen()),
                      ),
                      Divider(),
                      SizedBox(height: TSizes.spaceBtwSections),
                      ElevatedButton(
                        onPressed: () {
                          _showLogoutConfirmationDialog(context);
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text('Logout', style: TextStyle(fontSize: 16)),
                      ),
                      SizedBox(height: TSizes.spaceBtwSections),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(BuildContext context, {required IconData icon, required String title, required String subTitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subTitle),
        onTap: onTap,
      ),
    );
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
                Get.find<AdminAuthenticationRepository>().logout();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
