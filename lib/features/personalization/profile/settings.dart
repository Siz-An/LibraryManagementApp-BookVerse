import 'package:book_Verse/common/widgets/proFile/settings_menu.dart';
import 'package:book_Verse/common/widgets/texts/section_heading.dart';
import 'package:book_Verse/features/personalization/profile/widgets/users_Screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../common/widgets/proFile/user_profile_tile.dart';
import '../../../data/authentication/repository/authentication/authentication_repo.dart';
import '../../home/screens/dataforuser/returnhistory.dart';
import '../../home/screens/user/bookreturnsss.dart';
import '../../home/screens/user/mark/markApp.dart';
import '../../home/screens/user/mark/requestssss.dart';
import '../../home/screens/user/notification.dart';
import '../../home/screens/user/pdfView/pdflist.dart';

class SettingScreen extends StatelessWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = AuthenticationRepository.instance.authUser?.uid ?? '';

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
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: Icon(Iconsax.user, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Settings',
                      style: const TextStyle(
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
                  IconButton(
                    icon: const Icon(Iconsax.edit, color: Colors.white, size: 28),
                    onPressed: () => Get.to(() => const UserScreen()),
                    tooltip: 'Edit Profile',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12),
        child: ListView(
          children: [
            const SizedBox(height: 8),
            // User Profile Tile
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              margin: const EdgeInsets.only(bottom: 18),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 12),
                child: TUserProfileTitle(
                  onPressed: () => Get.to(() => const UserScreen()),
                ),
              ),
            ),
            // Section Heading
            const TSectionHeading(
              title: 'Account Settings',
              showActionButton: false,
            ),
            const SizedBox(height: 16),
            // Settings List
            _ModernSettingMenu(
              icon: Iconsax.notification,
              title: 'Notification',
              subTitle: 'Please check Notification Daily',
              onTap: () => Get.to(() => notificationScreen()),
            ),
            _ModernSettingMenu(
              icon: Iconsax.bookmark,
              title: 'BookMark',
              subTitle: 'List books that the user has BookMarked',
              onTap: () => Get.to(() => MarkApp()),
            ),
            _ModernSettingMenu(
              icon: Iconsax.archive_tick,
              title: 'Request',
              subTitle: 'List books that the User Requested',
              onTap: () => Get.to(() => RequestedListScreen()),
            ),
            _ModernSettingMenu(
              icon: Iconsax.receipt,
              title: 'Return History',
              subTitle: 'Books that the user has returned',
              onTap: () => Get.to(() => ReturnHistory()),
            ),
            _ModernSettingMenu(
              icon: Iconsax.alarm,
              title: 'Book Return Notice',
              subTitle: 'List books that the user have to return',
              onTap: () => Get.to(() => ToBeReturnedBooksScreen(userId: userId)),
            ),
            _ModernSettingMenu(
              icon: Iconsax.omega_circle,
              title: 'PDF FILES',
              subTitle: 'List of Pdf Files',
              onTap: () => Get.to(() => AllPDFsScreen()),
            ),
            const SizedBox(height: 32),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showLogoutConfirmationDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A4E69),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Iconsax.logout, size: 22),
                label: const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _ModernSettingMenu extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final VoidCallback onTap;

  const _ModernSettingMenu({
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 7),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF9A8C98).withOpacity(0.13),
          child: Icon(icon, color: const Color(0xFF4A4E69), size: 26),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 17,
            color: Color(0xFF22223B),
          ),
        ),
        subtitle: Text(
          subTitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF4A4E69),
          ),
        ),
        trailing: const Icon(Iconsax.arrow_right_3, color: Color(0xFF4A4E69)),
        onTap: onTap,
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
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
              Get.find<AuthenticationRepository>().logout();
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
