
import 'package:book_Verse/utils/constants/colors.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import '../features/home/screens/home/home.dart';
import '../features/home/screens/search/search.dart';

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(NavigationController());
    final darkMode = THelperFunction.isDarkMode(context);
    return Scaffold(
      bottomNavigationBar: Obx(() => CurvedNavigationBar(
        index: controller.selectedIndex.value,
        height: 70.0,
        items: <Widget>[
          Icon(Iconsax.search_normal, size: 20,color: Colors.purple,),
          Icon(Iconsax.bookmark, size: 20,color: Colors.purple,),
          Icon(Iconsax.home, size: 30,color: Colors.purple),
          Icon(Iconsax.received, size: 20,color: Colors.purple),
          Icon(Iconsax.profile_2user, size: 20,color: Colors.purple),
        ],
        color: darkMode ? TColors.dark : Colors.white,
        buttonBackgroundColor: darkMode ? TColors.white : TColors.dark,
        backgroundColor: Colors.grey,
        animationCurve: Curves.decelerate,
        animationDuration: const Duration(milliseconds: 600),
        onTap: (index) {
          controller.selectedIndex.value = index;
        },
        letIndexChange: (index) => true,
      )),
      body: Obx(() => controller.screens[controller.selectedIndex.value]),
    );
  }

}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 2.obs;

  final screens  = [
    const SearchScreen(),
    Container(color: Colors.purple),
    const HomeScreen(),
    Container(color: Colors.pink),
    Container(color: Colors.yellowAccent,)
  ];
}
