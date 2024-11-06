import 'package:flutter/material.dart';
import '../../../../../../../../utils/constants/colors.dart';

class TCartCounterIcons extends StatelessWidget {
  const TCartCounterIcons({
    super.key,
    this.iconColor = TColors.bookmark,
    required this.onPressed,
    required this.icon,
    this.count = 0, // Add count parameter
  });

  final Color? iconColor;
  final VoidCallback onPressed;
  final IconData icon;
  final int count; // Define count as an integer

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          onPressed: onPressed,
          icon: Icon(icon, color: iconColor),
        ),
        // Show the count badge if count is greater than zero
        if (count > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
