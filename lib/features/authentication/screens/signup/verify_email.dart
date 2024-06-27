
import 'package:book_Verse/common/widgets/sucess_screen/success_screen.dart';
import 'package:book_Verse/features/authentication/screens/login/login.dart';
import 'package:book_Verse/utils/constants/image_strings.dart';
import 'package:book_Verse/utils/constants/sizes.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/text_strings.dart';


class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: () => Get.offAll(() => const LoginScreen() ),  icon: const Icon(CupertinoIcons.clear))
          ],
        ),
        body:  SingleChildScrollView(
          //Padding to give Default Equal Space on all Sides in a screen
          child: Padding(
              padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            children: [
              /// Image
                Image(image: const AssetImage(TImages.deliveredInPlaneIllustration), width: THelperFunction.screenWidth() * 0.6,),
              const SizedBox(height: TSizes.spaceBtwItems,),

              /// Title & SubTitle
                Text(TTexts.confirmEmail, style: Theme.of(context).textTheme.headlineMedium, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwItems,),
              Text('vookberse@gmail.com', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwItems,),
              Text(TTexts.confirmEmailSubTitle, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwSections,),

              /// Buttons
              SizedBox(width: double.infinity,
                child: ElevatedButton(onPressed: ()=> Get.to(() =>  SuccessScreen(
                  image: TImages.deliveredInPlaneIllustration,
                  title: TTexts.yourAccountCreatedTitle,
                  subTitle: TTexts.yourAccountCreatedSubTitle,
                  onPressed: () => Get.to(()=> const LoginScreen()),
                ),
                ),
                  child: const Text(TTexts.tContinue),
                )
              ),
              const SizedBox(height: TSizes.spaceBtwItems,),
              SizedBox(width: double.infinity,
                  child: TextButton(onPressed: (){}, child: const Text(TTexts.resendEmail),)),
              const SizedBox(height: TSizes.spaceBtwItems,),
            ],
          ),
          ),
        ),

      );

  }
}
