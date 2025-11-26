import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import '../features/home/screens/admin/navigations/addBooks.dart';
import '../features/home/screens/admin/navigations/dashboard.dart';
import '../features/home/screens/admin/navigations/editScreen.dart';
import '../features/home/screens/admin/navigations/requests.dart';
import '../features/home/screens/admin/navigations/settingScreen.dart';
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
        () => CurvedNavigationBar(
          index: controller.selectedIndex.value,
          height: 60.0,
          items: const [
            Icon(Iconsax.add, size: 30),
            Icon(Iconsax.user, size: 30),
            Icon(Iconsax.book_1, size: 30),
            Icon(Iconsax.edit, size: 30),
            Icon(Iconsax.setting, size: 30),
          ],
          color: Colors.grey,
          buttonBackgroundColor: Colors.grey,
          backgroundColor: darkMode ? TColors.black : Colors.transparent,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          onTap: (index) => controller.selectedIndex.value = index,
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
    AdminUserRequestsScreen(),
    const AddBooks(),
     SearchBookScreen(),
    const AdminSettingsScreen(),
  ];
}
