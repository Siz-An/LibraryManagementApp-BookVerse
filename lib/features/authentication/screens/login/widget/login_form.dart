import 'package:book_Verse/features/authentication/controller/login/login_controller.dart';
import 'package:book_Verse/features/authentication/controller/login/admin_login_controller.dart';
import 'package:book_Verse/features/authentication/screens/password_configuration/forget_password.dart';
import 'package:book_Verse/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';
import '../../signup/signup.dart';

class TLoginForm extends StatefulWidget {
  const TLoginForm({super.key,});

  @override
  _TLoginFormState createState() => _TLoginFormState();
}

class _TLoginFormState extends State<TLoginForm> {
  final GlobalKey<FormState> _userFormKey = GlobalKey<FormState>();  // Unique GlobalKey for user
  final GlobalKey<FormState> _adminFormKey = GlobalKey<FormState>();  // Unique GlobalKey for admin

  String _selectedRole = 'User'; // Default role

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(LoginController());
    final adminController = Get.put(AdminLoginController());

    // Use the appropriate form key based on the selected role
    final formKey = (_selectedRole == 'User') ? _userFormKey : _adminFormKey;

    return Form(
      key: formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: TSizes.spaceBtwSections,
          horizontal: 16.0,
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Select Role: '),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: <String>['User', 'Admin'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedRole = newValue!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Email
            TextFormField(
              controller: (_selectedRole == 'User') ? userController.email : adminController.email,
              validator: (value) => TValidator.validateEmail(value),
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: TTexts.email,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Password
            Obx(
                  () => TextFormField(
                controller: (_selectedRole == 'User') ? userController.password : adminController.password,
                obscureText: (_selectedRole == 'User') ? userController.hidePassword.value : adminController.hidePassword.value,
                validator: (value) => TValidator.validatePassword(value),
                decoration: InputDecoration(
                  labelText: TTexts.password,
                  prefixIcon: const Icon(Iconsax.password_check),
                  suffixIcon: IconButton(
                    onPressed: () {
                      if (_selectedRole == 'User') {
                        userController.hidePassword.value = !userController.hidePassword.value;
                      } else {
                        adminController.hidePassword.value = !adminController.hidePassword.value;
                      }
                    },
                    icon: Icon((_selectedRole == 'User')
                        ? userController.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye
                        : adminController.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye),
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields / 2),

            /// Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// -- Remember Me
                Row(
                  children: [
                    Obx(
                          () => Checkbox(
                        value: (_selectedRole == 'User') ? userController.rememberMe.value : adminController.rememberMe.value,
                        onChanged: (value) {
                          if (_selectedRole == 'User') {
                            userController.rememberMe.value = value ?? false;
                          } else {
                            adminController.rememberMe.value = value ?? false;
                          }
                        },
                      ),
                    ),
                    const Text(TTexts.rememberMe),
                  ],
                ),
                /// -- Forget Password
                TextButton(
                  onPressed: () => Get.to(() => const ForgetPassword()),
                  child: const Text(TTexts.forgetPassword),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_selectedRole == 'User') {
                    userController.emailAndPasswordSignIn();
                  } else {
                    adminController.emailAndPasswordSignIn();
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.green, // Text color of the button
                  padding: const EdgeInsets.symmetric(vertical: 12.0), // Add some padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Border radius
                    side: const BorderSide(color: Colors.green, width: 2.0), // Outline color and width
                  ),
                ),
                child: const Text(TTexts.signIn),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems / 2),

            /// Create an Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignUpScreen()),
                child: const Text(TTexts.createAccount),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
