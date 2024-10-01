import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:book_Verse/features/personalization/controller/admin_Controller.dart';

class ChangeEmailPassword extends StatelessWidget {
  final String changeType; // To identify if it's for email or phone change

  const ChangeEmailPassword({super.key, required this.changeType});

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    final adminController = Get.find<AdminController>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Change $changeType'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'New $changeType',
                hintText: 'Enter new $changeType',
              ),
              keyboardType: changeType == 'Email' ? TextInputType.emailAddress : TextInputType.phone,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Update the email or phone number in the database
                if (changeType == 'Email') {
                  adminController.updateAdminEmail(controller.text);
                } else {
                  adminController.updateAdminPhoneNumber(controller.text);
                }

                // Go back after saving
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white, backgroundColor: Colors.green, // White text color
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Button padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Rounded corners
                ),
              ),
              child: Text('Save $changeType'),
            ),
          ],
        ),
      ),
    );
  }
}
