import 'package:book_Verse/features/authentication/screens/widgets/onboarding_dot_navigation.dart';
import 'package:book_Verse/features/authentication/screens/widgets/onboarding_next_button.dart';
import 'package:book_Verse/features/authentication/screens/widgets/onboarding_page.dart';
import 'package:book_Verse/features/authentication/screens/widgets/onboarding_skip.dart';
import 'package:book_Verse/utils/constants/image_strings.dart';
import 'package:book_Verse/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/get_instance.dart';

import '../controller/onboarding/onboarding_controller.dart';


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
                image: TImages.onBoardingImage2,
                title: TTexts.onBoardingTitle1,
                subTitle: TTexts.onBoardingSubTitle1,),

              OnBoardingPage(
                image: TImages.onBoardingImage3,
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









