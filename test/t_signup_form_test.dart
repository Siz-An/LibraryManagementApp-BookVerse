import 'package:book_Verse/features/authentication/screens/signup/upWidget/signup_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:book_Verse/features/authentication/controller/signup/signup_controller.dart';
import 'package:book_Verse/features/authentication/controller/signup/admin_signup_controller.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('TSignupform widget test', (WidgetTester tester) async {
    // Setup the GetX dependency injection
    Get.put(SignupController());
    Get.put(AdminSignupController());

    final formKey = GlobalKey<FormState>();

    // Build the TSignupform widget
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: TSignupform(formKey: formKey),
        ),
      ),
    );

    // Verify default role is 'User'
    expect(find.text('Select Role: Admin'), findsNothing);

    // Test filling in the form
    await tester.enterText(find.byType(TextFormField).at(0), 'FirstNameTest');
    await tester.enterText(find.byType(TextFormField).at(1), 'LastNameUser');
  });
}