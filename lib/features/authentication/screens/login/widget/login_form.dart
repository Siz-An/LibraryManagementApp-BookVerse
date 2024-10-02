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
  const TLoginForm({super.key, required GlobalKey<FormState> formKey});

  @override
  _TLoginFormState createState() => _TLoginFormState();
}

class _TLoginFormState extends State<TLoginForm> {
  String _selectedRole = 'User'; // Default role

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(LoginController());
    final adminController = Get.put(AdminLoginController());

    final screenWidth = MediaQuery.of(context).size.width;

    return Form(
      key: (_selectedRole == 'User') ? userController.userloginFormKey : adminController.adminloginFormKey,
      child: Padding(
        padding: EdgeInsets.symmetric(
          vertical: screenWidth < 600 ? TSizes.spaceBtwSections : TSizes.spaceBtwSections * 1.5,
          horizontal: screenWidth < 600 ? 16.0 : 32.0,
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
            SizedBox(height: screenWidth < 600 ? TSizes.spaceBtwInputFields : TSizes.spaceBtwInputFields * 1.5),

            /// Email
            TextFormField(
              controller: (_selectedRole == 'User') ? userController.email : adminController.email,
              validator: (value) => TValidator.validateEmail(value),
              decoration: InputDecoration(
                prefixIcon: Icon(Iconsax.direct_right),
                labelText: TTexts.email,
              ),
            ),
            SizedBox(height: screenWidth < 600 ? TSizes.spaceBtwInputFields : TSizes.spaceBtwInputFields * 1.5),

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
            SizedBox(height: screenWidth < 600 ? TSizes.spaceBtwInputFields / 2 : TSizes.spaceBtwInputFields / 2 * 1.5),

            /// Remember Me & Forget Password
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                /// -- Remember ME
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
            SizedBox(height: screenWidth < 600 ? TSizes.spaceBtwSections : TSizes.spaceBtwSections * 1.5),

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
                  padding: EdgeInsets.symmetric(vertical: screenWidth < 600 ? 12.0 : 17.0), // Add some padding
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0), // Border radius
                    side: BorderSide(color: Colors.green, width: 2.0), // Outline color and width
                  ),
                ),
                child: const Text(TTexts.signIn),
              ),
            ),
            SizedBox(height: screenWidth < 600 ? TSizes.spaceBtwItems / 2 : TSizes.spaceBtwItems),

            /// Create an Account Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignUpScreen()),
                child: const Text(TTexts.createAccount),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.green),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}