

import 'package:book_Verse/utils/constants/colors.dart';
import 'package:book_Verse/utils/device/device_utility.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TTabBar extends StatelessWidget implements PreferredSizeWidget{
  const TTabBar({super.key, required this.tabs});

  final List<Widget> tabs;
  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Material(
      color: dark ? TColors.black : TColors.white,
      child: TabBar(
        tabs: tabs,
        isScrollable: true,
        indicatorColor: TColors.primaryColor,
        labelColor:  dark ? TColors.white : TColors.black,
        unselectedLabelColor: TColors.darkerGrey,
      ),
    );
  }

  @override
Size get preferredSize => Size.fromHeight(TDeviceUtils.getAppBarHeight());

}
