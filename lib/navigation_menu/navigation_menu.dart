import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../features/home/screens/user/home/home.dart';
import '../features/home/screens/user/mark/markApp.dart';
import '../features/home/screens/user/received/received.dart';
import '../features/home/screens/user/search/search.dart';
import '../features/personalization/profile/settings.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_function.dart';

class NavigationMenu extends StatelessWidget {
  NavigationMenu({super.key});

  final NavigationController controller = Get.put(NavigationController());

  @override
  Widget build(BuildContext context) {
    final darkMode = THelperFunction.isDarkMode(context);

    return Scaffold(
      bottomNavigationBar: Obx(
        () => CurvedNavigationBar(
          index: controller.selectedIndex.value,
          height: 60.0,
          items: const [
            Icon(Iconsax.search_normal, size: 30),
            Icon(Iconsax.bookmark, size: 30),
            Icon(Iconsax.home, size: 30),
            Icon(Iconsax.book, size: 30),
            Icon(Iconsax.user, size: 30),
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

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 2.obs;

  NavigationController() {
    updateScreens();
  }

  final RxList<Widget> screens = <Widget>[].obs;

  void updateScreens() {
    screens
      ..clear()
      ..addAll([
        const SearchScreen(),
        const MarkApp(),
        const HomeScreen(),
        const Received(), // Remove userId parameter here
        const SettingScreen(),
      ]);
  }
}