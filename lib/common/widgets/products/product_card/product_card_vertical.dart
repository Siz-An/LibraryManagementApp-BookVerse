import 'package:book_Verse/common/widgets/images/t_rounded_images.dart';
import 'package:book_Verse/common/widgets/texts/T_genreTitle.dart';
import 'package:book_Verse/utils/constants/colors.dart';
import 'package:book_Verse/utils/constants/enums.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../styles/shadows.dart';
import '../../custom_shapes/rounded_container.dart';
import '../../texts/product_title_text.dart';

class TProductCardVertical extends StatelessWidget {
  const TProductCardVertical({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 180,
        padding: EdgeInsets.all(1),
        decoration: BoxDecoration(
          boxShadow: [TShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(TSizes.productImageRadius),
          color: dark ? TColors.darkerGrey : TColors.white,
        ),
        child: Column(
          /// -----> Thumbnail, Wishlist Button, Discount Tag
          children: [
            Row(
              children: [
                Spacer(),
                Container(
                  child:
                  Icon(Iconsax.bookmark),
                )
              ],
            ),
            Stack(
              children: [
                TRoundedContainer(
                  height: 200,
                  padding: const EdgeInsets.all(TSizes.xs),
                  backgroundColor: dark ? TColors.dark : TColors.light,
                  child: const TRoundedImage(
                    imageUrl: TImages.b1,
                    applyImageRadius: true,
                  ),
                ),

              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),

            /// ----> Details
            Padding(
              padding: EdgeInsets.only(left: TSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TProductTitleText(
                    title: 'IT Ends With Us',
                    smallSize: true,
                  ),
                  SizedBox(height: TSizes.spaceBtwItems / 2),
                  TGenreTitleWithVerification(title: 'Romance'),

                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

