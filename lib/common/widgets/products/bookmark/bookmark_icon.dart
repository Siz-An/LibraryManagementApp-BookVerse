

import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../../../utils/constants/colors.dart';

class TCartCounterIcons extends StatelessWidget {
  const TCartCounterIcons({
    super.key,
     this.iconColor = TColors.bookmark,
    required this.onPressed,
  });
  final Color? iconColor;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) {

    return Stack(
      children: [
        IconButton(onPressed: onPressed, icon: Icon(Iconsax.search_normal, color: iconColor,)),

      ],
    );
  }
}