import 'dart:ui';

import 'package:flutter/material.dart';
import '../../../utils/constants/colors.dart';
import '../curved_edges/curved_edges_widget.dart';

class TCircularContainer extends StatelessWidget {
  final Color backgroundColor;
  final double size;
  final double blur;

  const TCircularContainer({
    Key? key,
    required this.backgroundColor,
    required this.size,
    this.blur = 0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: blur > 0
          ? ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            )
          : null,
    );
  }
}

class TPrimaryHeaderContainer extends StatelessWidget {
  const TPrimaryHeaderContainer({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgeWidget(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(0),
        child: Stack(
          children: [
            // Modern blurred circular decorations
            Positioned(
              top: -100,
              left: -80,
              child: TCircularContainer(
                backgroundColor: TColors.textWhite.withOpacity(0.15),
                blur: 30,
                size: 180,
              ),
            ),
            Positioned(
              bottom: -60,
              right: -60,
              child: TCircularContainer(
                backgroundColor: TColors.textWhite.withOpacity(0.10),
                blur: 40,
                size: 140,
              ),
            ),
            // Add a subtle overlay for depth
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.white.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}