
import 'package:book_Verse/features/home/screens/mark/markApp.dart';
import 'package:book_Verse/features/home/screens/received/received.dart';
import 'package:book_Verse/features/personalization/profile/settings.dart';
import 'package:book_Verse/utils/constants/colors.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../features/home/screens/home/home.dart';
import '../features/home/screens/search/search.dart';



class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
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

          ],),
      ),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }

}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 2.obs;

  final screens  = [
    const SearchScreen(),
    const MarkApp(),
    const HomeScreen(),
    const Received(),
    const settingScreen()];
}