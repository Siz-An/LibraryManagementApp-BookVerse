import 'package:book_Verse/data/authentication/repository/authentication/admin_auth_repo.dart';
import 'package:book_Verse/features/home/screens/admin/navigations/requests.dart';
import 'package:book_Verse/features/home/screens/admin/navigations/editScreen.dart';
import 'package:book_Verse/features/home/screens/admin/returnedbooks/bookreturnUserScreen.dart';
import 'package:book_Verse/features/home/screens/admin/widgets/adminScreen.dart';
import 'package:book_Verse/features/home/screens/admin/widgets/adminprofile.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../DataForAdmin/usersdata.dart';
import '../BookIssue/users.dart';
// import '../../../..editScreen.dart';
import '../notification/notificationScreen.dart';
import 'package:book_Verse/features/home/screens/admin/damagedbooks/damaged_books_admin_screen.dart';
import 'package:book_Verse/features/home/screens/admin/damagedbooks/user_wise_damage_reports_screen.dart';
// import '../../search/searchBookScreen.dart';

class AdminSettingsScreen extends StatelessWidget {
  const AdminSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withOpacity(0.15),
                    child: Icon(Iconsax.setting, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Admin Settings',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        letterSpacing: 1.2,
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
                    icon: const Icon(Iconsax.profile_circle, color: Colors.white, size: 30),
                    onPressed: () => Get.to(() => const AdminScreen()),
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
            _ModernProfileCard(),
            const SizedBox(height: 18),
            Text(
              'Features',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            _ModernSettingCard(
              icon: Iconsax.bookmark,
              title: 'Notification',
              subtitle: 'Send Notification to Users',
              onTap: () => Get.to(() => const NotificationScreen()),
            ),
            _ModernSettingCard(
              icon: Iconsax.archive_tick,
              title: 'Issued Books',
              subtitle: 'List books that the Librarian has Issued',
              onTap: () => Get.to(() => const UsersListScreen()),
            ),
            _ModernSettingCard(
              icon: Iconsax.receipt,
              title: 'Request List',
              subtitle: 'Books that to be Issued',
              onTap: () => Get.to(() => AdminUserRequestsScreen()),
            ),
            _ModernSettingCard(
              icon: Iconsax.alarm,
              title: 'Book Return',
              subtitle: 'List books that the user has to return',
              onTap: () => Get.to(() => const AcceptReturnUsersScreen()),
            ),
            _ModernSettingCard(
              icon: Iconsax.export,
              title: 'DATA',
              subtitle: 'DATA available here',
              onTap: () => Get.to(() => const UserListPage()),
            ),
            _ModernSettingCard(
              icon: Iconsax.search_normal,
              title: 'Search Screen',
              subtitle: 'Search Books',
              onTap: () => Get.to(() => SearchBookScreen()),
            ),
            _ModernSettingCard(
              icon: Icons.report_problem,
              title: 'Damage Reports',
              subtitle: 'View and process book damage reports',
              onTap: () => Get.to(() => const UserWiseDamageReportsScreen()),
            ),
            _ModernSettingCard(
              icon: Icons.report,
              title: 'All Damage Reports',
              subtitle: 'View all damage reports in chronological order',
              onTap: () => Get.to(() => const DamagedBooksAdminScreen()),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => _showLogoutConfirmationDialog(context),
              icon: const Icon(Iconsax.logout, color: Colors.white),
              label: const Text('Logout', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: const Color(0xFF4A4E69),
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                elevation: 2,
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// Modern Setting Card Widget
  Widget _ModernSettingCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF9A8C98).withOpacity(0.15),
          child: Icon(icon, color: const Color(0xFF4A4E69), size: 26),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 13)),
        trailing: const Icon(Iconsax.arrow_right_3, color: Color(0xFF4A4E69)),
        onTap: onTap,
      ),
    );
  }

  /// Modern Profile Card Widget
  Widget _ModernProfileCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: const Color(0xFF4A4E69),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Row(
          children: [
            const CircleAvatar(
              radius: 32,
              backgroundColor: Color(0xFF9A8C98),
              child: Icon(Iconsax.user, color: Colors.white, size: 34),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'admin@bookverse.com',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
          ],
        ),
      ),
    );
  }

  /// Confirmation Logout Dialog
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
