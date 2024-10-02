import 'package:book_Verse/features/authentication/screens/signup/upWidget/signup_form.dart';
import 'package:book_Verse/utils/constants/text_strings.dart';
import 'package:flutter/material.dart';
import '../../../../common/widgets/login_signup/form_divider.dart';
import '../../../../common/widgets/login_signup/social_buttons.dart';
import '../../../../utils/constants/sizes.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a unique GlobalKey for the signup form

    return Scaffold(
      appBar: AppBar(
        title: const Text(TTexts.signupTitle),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Title
              Text(TTexts.signupTitle, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: TSizes.spaceBtwSections),

              /// Form with the unique GlobalKey
              TSignupform(),

              /// -- Divider
              const SizedBox(height: TSizes.spaceBtwSections),

              /// -- Social Buttons
              const TSocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
