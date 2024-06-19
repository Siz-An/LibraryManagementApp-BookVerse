
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class TVerticalImageText extends StatelessWidget {
  const TVerticalImageText({
    super.key,
    required this.image,
    required this.title,
    this.textColor = TColors.white,
    this.backgroundColor = TColors.white,
    this.onTap,
  });

  final String image, title;
  final Color textColor;
  final Color? backgroundColor;
  final void Function()? onTap;


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: TSizes.spaceBtwItems),
        child: Column(
          children: [
            /// ---> Circular icon
            Container(
              width: 60,
              height: 56,
              padding: const EdgeInsets.all(TSizes.sm),
              decoration: BoxDecoration(
                color: backgroundColor ?? (dark ? TColors.black : TColors.white),
                borderRadius: BorderRadius.circular(100),
              ),
              child: Center(
                child: Image(image: AssetImage(image), fit: BoxFit.fill,
                    color: dark ? TColors.dark : TColors.light),
              ),
            ),
            /// ---> Text
            SizedBox(height: TSizes.spaceBtwItems/2),
            SizedBox(
                width: 41,
                child: Text(title,
                  style: Theme.of(context).textTheme.labelMedium!.apply(color: textColor),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,))
          ],
        ),
      ),
    );
  }
}

