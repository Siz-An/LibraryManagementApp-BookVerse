import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../features/home/screens/admin/adminDashbord/admin_dashbord.dart';
import '../features/home/screens/admin/adminProfile.dart';
import '../features/home/screens/admin/manage_books.dart';
import '../features/home/screens/admin/manage_user.dart';

class AdminNavigationMenu extends StatelessWidget {
  const AdminNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AdminNavigationController>();
    final darkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      bottomNavigationBar: Obx(
            () => NavigationBar(
          height: 60,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: darkMode ? Colors.black : Colors.white.withOpacity(0.1),
          indicatorColor: darkMode ? Colors.white.withOpacity(0.3) : Colors.black.withOpacity(0.3),
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.add), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Users'),
            NavigationDestination(icon: Icon(Iconsax.book), label: 'Books'),
            NavigationDestination(icon: Icon(Iconsax.profile), label: 'Profile'),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class AdminNavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  final screens = [
    const AdminDashboardScreen(),
    const ManageUsersScreen(),
    const ManageBooks(),
    const SystemSettingsScreen(),
  ];
}
