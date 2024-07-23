import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'adminProfile.dart';
import 'manage_user.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: Text('Manage Users'),
            onTap: () => Get.to(() => ManageUsersScreen()),
          ),
          ListTile(
            title: Text('System Settings'),
            onTap: () => Get.to(() => SystemSettingsScreen()),
          ),
        ],
      ),
    );
  }
}
