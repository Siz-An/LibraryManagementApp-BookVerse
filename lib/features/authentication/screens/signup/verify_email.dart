import 'package:book_Verse/data/authentication/repository/authentication_repo.dart';
import 'package:book_Verse/features/authentication/controller/signup/verify_emailController.dart';
import 'package:book_Verse/utils/constants/image_strings.dart';
import 'package:book_Verse/utils/constants/sizes.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/text_strings.dart';


class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key,
    this.email});
  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());
    return  Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          actions: [
            IconButton(onPressed: () => AuthenticationRepository.instance.logout(),  icon: const Icon(CupertinoIcons.clear))
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
              Text(email ?? '', style: Theme.of(context).textTheme.labelLarge, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwItems,),
              Text(TTexts.confirmEmailSubTitle, style: Theme.of(context).textTheme.labelMedium, textAlign: TextAlign.center,),
              const SizedBox(height: TSizes.spaceBtwSections,),

              /// Buttons
              SizedBox(
                  width: double.infinity,
                child: ElevatedButton(
                  onPressed: ()=> controller.checkEmailVerificationStatus(),
                  child: const Text(TTexts.tContinue))
              ),
              const SizedBox(height: TSizes.spaceBtwItems,),
              SizedBox(width: double.infinity,
                  child: TextButton(onPressed: () => controller.sendEmailVerification(),
                    child: const Text(TTexts.resendEmail),)),
              const SizedBox(height: TSizes.spaceBtwItems,),
            ],
          ),
          ),
        ),

      );

  }
}
