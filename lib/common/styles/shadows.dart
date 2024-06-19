

import 'package:book_Verse/utils/constants/colors.dart';
import 'package:flutter/cupertino.dart';

class TShadowStyle{
  static final verticalProductShadow = BoxShadow(
    color: TColors.darkerGrey.withOpacity(0.1),
    blurRadius: 50,
    spreadRadius: 5,
    offset: const Offset(0, 2)
  );

  static final horizontalProductShadow = BoxShadow(
      color: TColors.darkerGrey.withOpacity(0.1),
      blurRadius: 50,
      spreadRadius: 5,
      offset: const Offset(0, 2)
  );

}