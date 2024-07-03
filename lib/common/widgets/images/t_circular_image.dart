import 'package:book_Verse/utils/constants/shimmer.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_function.dart';

class TCircularImage extends StatelessWidget {
  const TCircularImage({
    super.key,
    this.fit = BoxFit.fill,
    required this.image,
     this.isNetworkImage = false,
    this.overlayColor,
    this.backgroundColor,
     this.width = 56,
     this.height = 56,
     this.padding = TSizes.sm,
  });

  final BoxFit? fit;
  final String image;
  final bool isNetworkImage;
  final Color? overlayColor;
  final Color? backgroundColor;
  final double width, height, padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: THelperFunction.isDarkMode(context) ? TColors.black : TColors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Center(
          child: isNetworkImage
          ? CachedNetworkImage(
            fit: fit,
            color: overlayColor,
            imageUrl: image,
            progressIndicatorBuilder: (context, url, downloadProgress) => const TShimmerEffect(width: 65, height: 65, radius: 65,),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )
          : Image(
          fit: fit,
          image: AssetImage(image),
          color: overlayColor,
        ),
        ),
      ),
      );
  }
}