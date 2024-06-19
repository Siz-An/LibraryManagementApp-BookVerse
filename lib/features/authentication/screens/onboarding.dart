import 'package:book_Verse/features/authentication/controllers.onboarding/onboarding_controller.dart';
import 'package:book_Verse/features/authentication/screens/widgets/onboarding_dot_navigation.dart';
import 'package:book_Verse/features/authentication/screens/widgets/onboarding_next_button.dart';
import 'package:book_Verse/features/authentication/screens/widgets/onboarding_page.dart';
import 'package:book_Verse/features/authentication/screens/widgets/onboarding_skip.dart';
import 'package:book_Verse/utils/constants/image_strings.dart';
import 'package:book_Verse/utils/constants/sizes.dart';
import 'package:book_Verse/utils/constants/text_strings.dart';
import 'package:book_Verse/utils/device/device_utility.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';
import 'package:iconsax/iconsax.dart';
import 'package:get/get_navigation/get_navigation.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../utils/constants/colors.dart';

class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnboardingController());

    return  Scaffold(
      body: Stack(
        children: [
          /// Horizontal Scrollable Pages
          PageView(
            controller: controller.pageController,
            onPageChanged: controller.updatePageIndicator,
            children: const [
              OnBoardingPage(
                image: TImages.onBoardingImage1,
                title: TTexts.onBoardingTitle1,
                subTitle: TTexts.onBoardingSubTitle1,),

              OnBoardingPage(
                image: TImages.onBoardingImage1,
                title: TTexts.onBoardingTitle1,
                subTitle: TTexts.onBoardingSubTitle1,),

              OnBoardingPage(
                image: TImages.onBoardingImage1,
                title: TTexts.onBoardingTitle1,
                subTitle: TTexts.onBoardingSubTitle1,),
            ],
          ),
          /// Skip Button
          const onBoardingSkip(),

          /// Dot Navigation SmoothPageIndicator
          
          const OnBoardingDotNavigation(),

          /// circular Button

          const OnBoardingNextButton()

        ],
      ),
    );
  }
}









