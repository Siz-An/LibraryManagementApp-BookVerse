import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../../common/widgets/custom_shapes/circular_container.dart';
import '../../../../../common/widgets/images/t_rounded_images.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../controllers/home_controller.dart';

class TPromoSlide extends StatelessWidget {
  const TPromoSlide({
    Key? key,
    required this.banner,
  }) : super(key: key);

  final List<String> banner;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(HomeController());

    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            viewportFraction: 1,
            onPageChanged: (index, _) => controller.updatePageIndicator(index),
            autoPlay: true, // Set to true for automatic sliding
            autoPlayInterval: Duration(seconds: 2), // Optional: set the interval between slides
            autoPlayAnimationDuration: Duration(milliseconds: 800), // Optional: animation duration
            autoPlayCurve: Curves.fastOutSlowIn, // Optional: animation curve
          ),
          items: banner.map((url) => TRoundedImage(imageUrl: url)).toList(),
        ),
        const SizedBox(height: TSizes.spaceBtwItems),
        Center(
          child: Obx(
                () => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int i = 0; i < banner.length; i++)
                  TCircularContainer(
                    width: 20,
                    height: 4,
                    margin: const EdgeInsets.only(right: 10),
                    backgroundColor: controller.carousalCurrentIndex.value == i
                        ? TColors.primaryColor
                        : TColors.grey,
                  ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
