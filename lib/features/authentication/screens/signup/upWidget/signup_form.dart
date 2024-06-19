import 'package:book_Verse/features/authentication/screens/signup/upWidget/terms_conditions_checkbox.dart';
import 'package:book_Verse/features/authentication/screens/signup/verify_email.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../../../../utils/helpers/helper_function.dart';

class TSignupform extends StatelessWidget {
  const TSignupform({
    super.key

  });


  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);
    return Form(
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    expands : false,
                    decoration: const InputDecoration(labelText: TTexts.firstName, prefixIcon: Icon(Iconsax.user)),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwInputFields),
                Expanded(
                  child: TextFormField(
                    expands : false,
                    decoration: const InputDecoration(labelText: TTexts.lastName, prefixIcon: Icon(Iconsax.user)),
                  ),
                ),
              ],
            ),
            /// UserName
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              expands : false,
              decoration: const InputDecoration(labelText: TTexts.username, prefixIcon: Icon(Iconsax.user)),
            ),
            /// UserId
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              expands : false,
              decoration: const InputDecoration(labelText: TTexts.userId, prefixIcon: Icon(Iconsax.user_add)),
            ),
            /// Email
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              expands : false,
              decoration: const InputDecoration(labelText: TTexts.email, prefixIcon: Icon(Iconsax.direct)),
            ),
            /// Phone Number
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              expands : false,
              decoration: const InputDecoration(labelText: TTexts.phoneNo, prefixIcon: Icon(Iconsax.call)),
            ),
            /// Password
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              expands : false,
              decoration: const InputDecoration(labelText: TTexts.password, prefixIcon: Icon(Iconsax.password_check), suffixIcon: Icon(Iconsax.eye_slash)),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Terms and Conditions
            const TTermsAndConditionCheckbox(),
            const SizedBox(height: TSizes.spaceBtwSections),
            /// SignUp Button
            SizedBox(width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => const VerifyEmailScreen()), child: const Text(TTexts.createAccount),
              ),)
          ],
        ));
  }
}

