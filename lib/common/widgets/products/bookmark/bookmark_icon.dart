import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../../../../../utils/constants/colors.dart';

class TCartCounterIcons extends StatelessWidget {
  const TCartCounterIcons({
    super.key,
    this.iconColor = TColors.bookmark,
    required this.onPressed,
    required this.icon, // Add icon parameter
  });

  final Color? iconColor;
  final VoidCallback onPressed;
  final IconData icon; // Define the icon type

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor), // Use the custom icon
        ),
      ],
    );
  }
}
