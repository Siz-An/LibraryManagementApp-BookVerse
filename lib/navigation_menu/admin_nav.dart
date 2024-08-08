import 'package:book_Verse/features/home/screens/user/search/search.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../features/home/screens/admin/addBooks.dart';
import '../features/home/screens/admin/dashboard.dart';
import '../features/home/screens/admin/editScreen.dart';
import '../features/home/screens/admin/requests.dart';
import '../features/home/screens/admin/settingScreen.dart';
import '../features/home/screens/admin/userRequest/userScreens.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_function.dart';

class AdminNavigationMenu extends StatelessWidget {
  const AdminNavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminNavigationController());
    final darkMode = THelperFunction.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(
            () => NavigationBar(
          height: 60,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: darkMode ? TColors.black : Colors.white.withOpacity(0.1),
          indicatorColor: darkMode ? TColors.white.withOpacity(0.3) : TColors.black.withOpacity(0.3),
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.add), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Users'),
            NavigationDestination(icon: Icon(Iconsax.book_1), label: 'Add Books'),
            NavigationDestination(icon: Icon(Iconsax.edit), label: 'Edit'),
            NavigationDestination(icon: Icon(Iconsax.setting), label: 'Settings'),
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
    const Dashboard(),
     Requests(),
    const AddBooks(),
     SearchBookScreen(),
    const SettingsScreen(),
  ];
}
