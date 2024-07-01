import 'package:book_Verse/features/authentication/controller/signup/signup_controller.dart';
import 'package:book_Verse/features/authentication/screens/signup/upWidget/terms_conditions_checkbox.dart';
import 'package:book_Verse/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';


class TSignupform extends StatelessWidget {
  const TSignupform({
    super.key
  });
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(SignupController());
    return Form(
      key: controller.signupFormKey,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: controller.firstName,
                    validator: (value) => TValidator.validateEmptyText('First Name', value),
                    expands : false,
                    decoration: const InputDecoration(labelText: TTexts.firstName, prefixIcon: Icon(Iconsax.user)),
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwInputFields),
                Expanded(
                  child: TextFormField(
                    controller: controller.lastName,
                    validator: (value) => TValidator.validateEmptyText('Last Name', value),
                    expands : false,
                    decoration: const InputDecoration(labelText: TTexts.lastName, prefixIcon: Icon(Iconsax.user)),
                  ),
                ),
              ],
            ),
            /// UserName
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              controller: controller.userName,
              validator: (value) => TValidator.validateEmptyText('User Name', value),
              expands : false,
              decoration: const InputDecoration(labelText: TTexts.userName, prefixIcon: Icon(Iconsax.user)),
            ),
            /// Email
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              controller: controller.email,
              validator: (value) => TValidator.validateEmail(value),
              expands : false,
              decoration: const InputDecoration(labelText: TTexts.email, prefixIcon: Icon(Iconsax.direct)),
            ),
            /// Phone Number
            const SizedBox(height: TSizes.spaceBtwInputFields),
            TextFormField(
              controller: controller.phoneNo,
              validator: (value) => TValidator.validatePhoneNumber(value),
              expands : false,
              decoration: const InputDecoration(labelText: TTexts.phoneNo, prefixIcon: Icon(Iconsax.call)),
            ),
            /// Password
            const SizedBox(height: TSizes.spaceBtwInputFields),
            Obx(
              () => TextFormField(
                controller: controller.password,
                obscureText: controller.hidePassword.value,
                validator: (value) => TValidator.validatePassword(value),
                decoration:  InputDecoration(
                    labelText: TTexts.password,
                    prefixIcon: Icon(Iconsax.password_check),
                    suffixIcon: IconButton(
                      onPressed: ()=>controller.hidePassword.value = !controller.hidePassword.value,
                      icon:  Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                    )),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Terms and Conditions
            const TTermsAndConditionCheckbox(),
            const SizedBox(height: TSizes.spaceBtwSections),
            /// SignUp Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.signup();
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Text color of the button
                  backgroundColor: Colors.green, // Background color of the button
                  padding: EdgeInsets.symmetric(vertical: 17.0), // Add some padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Border radius
                    side: BorderSide(color: Colors.green, width: 2.0), // Outline color and width
                  ),
                ),
                child: const Text(TTexts.createAccount),
              ),
            ),

          ],
        ));
  }
}

