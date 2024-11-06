import 'package:book_Verse/features/authentication/controller/signup/signup_controller.dart';
import 'package:book_Verse/features/authentication/controller/signup/admin_signup_controller.dart';
import 'package:book_Verse/features/authentication/screens/signup/upWidget/terms_conditions_checkbox.dart';
import 'package:book_Verse/utils/validators/validation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/text_strings.dart';

class TSignupform extends StatefulWidget {
  const TSignupform({super.key, required GlobalKey<FormState> formKey});

  @override
  _TSignupformState createState() => _TSignupformState();
}

class _TSignupformState extends State<TSignupform> {
  String _selectedRole = 'User'; // Default role

  @override
  Widget build(BuildContext context) {
    final userController = Get.put(SignupController());
    final adminController = Get.put(AdminSignupController());

    return Form(
      key: (_selectedRole == 'User') ? userController.usersignupFormKey : adminController.adminsignupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: (_selectedRole == 'User') ? userController.firstName : adminController.firstName,
                  validator: (value) => TValidator.validateEmptyText('First Name', value),
                  expands: false,
                  decoration: const InputDecoration(
                    labelText: TTexts.firstName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
              ),
              const SizedBox(width: TSizes.spaceBtwInputFields),
              Expanded(
                child: TextFormField(
                  controller: (_selectedRole == 'User') ? userController.lastName : adminController.lastName,
                  validator: (value) => TValidator.validateEmptyText('Last Name', value),
                  expands: false,
                  decoration: const InputDecoration(
                    labelText: TTexts.lastName,
                    prefixIcon: Icon(Iconsax.user),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: (_selectedRole == 'User') ? userController.userName : adminController.userName,
            validator: (value) => TValidator.validateEmptyText('User Name', value),
            expands: false,
            decoration: const InputDecoration(
              labelText: TTexts.userName,
              prefixIcon: Icon(Iconsax.user),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: (_selectedRole == 'User') ? userController.email : adminController.email,
            validator: (value) => TValidator.validateEmail(value),
            expands: false,
            decoration: const InputDecoration(
              labelText: TTexts.email,
              prefixIcon: Icon(Iconsax.direct),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          TextFormField(
            controller: (_selectedRole == 'User') ? userController.phoneNumber : adminController.phoneNumber,
            validator: (value) => TValidator.validatePhoneNumber(value),
            expands: false,
            decoration: const InputDecoration(
              labelText: TTexts.phoneNo,
              prefixIcon: Icon(Iconsax.call),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),
          Obx(
                () => TextFormField(
              controller: (_selectedRole == 'User') ? userController.password : adminController.password,
              obscureText: (_selectedRole == 'User') ? userController.hidePassword.value : adminController.hidePassword.value,
              validator: (value) => TValidator.validatePassword(value),
              decoration: InputDecoration(
                labelText: TTexts.password,
                prefixIcon: Icon(Iconsax.password_check),
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
          const SizedBox(height: TSizes.spaceBtwSections),
          const TTermsAndConditionCheckbox(),
          const SizedBox(height: TSizes.spaceBtwSections),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedRole == 'User') {
                  userController.signup();
                } else {
                  adminController.signup(); // This will check if an admin already exists
                }
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(vertical: 17.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(color: Colors.green, width: 2.0),
                ),
              ),
              child: const Text(TTexts.createAccount),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),
          const Divider(),
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
        ],
      ),
    );
  }
}
