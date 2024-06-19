import 'package:flutter/material.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_function.dart';


class OnBoardingPage extends StatelessWidget {
  const OnBoardingPage({
    super.key, required this.image, required this.title, required this.subTitle,
  });

  final String image, title, subTitle;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(TSizes.defaultSpace),
      child: Column(
        children: [
          Image(
            width: THelperFunction.screenWidth() * 0.8,
            height: THelperFunction.screenHeight() * 0.7,
            image:  AssetImage(image),
          ),
          Text(title,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,),
          const SizedBox(height: TSizes.spaceBtwItems,),
          Text(subTitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,),
        ],
      ),
    );
  }
}