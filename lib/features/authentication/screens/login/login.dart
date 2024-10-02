import 'package:book_Verse/common/styles/spacing_styles.dart';
import 'package:book_Verse/features/authentication/screens/login/widget/login_form.dart';
import 'package:book_Verse/features/authentication/screens/login/widget/login_header.dart';
import 'package:book_Verse/utils/constants/sizes.dart';
import 'package:book_Verse/utils/helpers/helper_function.dart';
import 'package:flutter/material.dart';
import 'package:book_Verse/common/widgets/login_signup/form_divider.dart';
import 'package:book_Verse/common/widgets/login_signup/social_buttons.dart';
import 'package:book_Verse/utils/constants/text_strings.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunction.isDarkMode(context);

    // Create a unique GlobalKey for the login form
    final GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Padding(
            padding: TSpacingStyle.paddingWithAppBarHeight,
            child: Column(
              children: [
                /// -- Logo, Title & Sub-Title
                TLoginHeader(dark: dark),

                /// Form with the unique GlobalKey
                TLoginForm(formKey: loginFormKey),

                /// -- Divider
                const TFormDivider(dividerText: TTexts.orSignInWith),
                const SizedBox(height: TSizes.spaceBtwSections),

                /// -- Footer
                const TSocialButtons()
              ],
            ),
          ),
        ),
      ),
    );
  }
}