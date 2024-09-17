import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../features/home/screens/user/home/home.dart';
import '../features/home/screens/user/mark/markApp.dart';
import '../features/home/screens/user/received/received.dart';
import '../features/home/screens/user/search/search.dart';
import '../features/personalization/profile/settings.dart';
import '../utils/constants/colors.dart';
import '../utils/helpers/helper_function.dart';

class NavigationMenu extends StatelessWidget {
  final String userId;

  NavigationMenu({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.put(NavigationController(userId));
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
            NavigationDestination(icon: Icon(Iconsax.search_normal), label: 'Search'),
            NavigationDestination(icon: Icon(Iconsax.bookmark), label: 'BookMark'),
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.book), label: 'Received'),
            NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
          ],
        ),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 2.obs;
  final String userId;

  NavigationController(this.userId) {
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
        Received(userId: userId), // Pass userId to Received screen
        const SettingScreen(),
      ]);
  }
}
