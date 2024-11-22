
import 'package:book_Verse/features/authentication/controller/login/login_controller.dart';
import 'package:book_Verse/features/authentication/controller/login/admin_login_controller.dart';
import 'package:book_Verse/features/authentication/screens/login/widget/login_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('TLoginForm widget test', (WidgetTester tester) async {
    // Initialize controllers using GetX dependency injection
    Get.put(LoginController());
    Get.put(AdminLoginController());

    final formKey = GlobalKey<FormState>();

    // Build the TLoginForm widget
    await tester.pumpWidget(
      GetMaterialApp(
        home: Scaffold(
          body: TLoginForm(formKey: formKey),
        ),
      ),
    );

    // Verify the initial role is 'User'
    expect(find.text('Select Role: '), findsOneWidget);
    expect(find.text('User'), findsOneWidget);

    // Verify input fields and buttons are present
    expect(find.byType(TextFormField), findsNWidgets(2)); // Email and Password
    expect(find.byType(ElevatedButton), findsOneWidget); // Sign In button
    expect(find.byType(OutlinedButton), findsOneWidget); // Create Account button

    // Interact with the dropdown to switch role
    await tester.tap(find.byType(DropdownButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Admin').last);
    await tester.pumpAndSettle();

    // Verify the role changes to 'Admin'
    expect(find.text('Admin'), findsOneWidget);
    expect(find.text('User'), findsNothing);

    // Test filling the email and password fields
    await tester.enterText(find.byType(TextFormField).at(0), 'sizanmahato@gmail.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');

    // Verify the input values
    final adminController = Get.find<AdminLoginController>();
    expect(adminController.email.text, 'admin@example.com');
    expect(adminController.password.text, 'password123');

    // Test clicking the Sign In button
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify the sign-in method was called
    // Replace with a mock or spy in a real-world test setup
  });
}
