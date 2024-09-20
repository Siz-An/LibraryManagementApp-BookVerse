import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'editUser.dart'; // Import the edit user screen

class AllUsersScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('Users').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          final users = snapshot.data?.docs ?? [];
          if (users.isEmpty) {
            return Center(child: Text('No users found'));
          }

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userData = users[index].data() as Map<String, dynamic>;
              final userName = userData['UserName'] ?? 'No Name';
              final userEmail = userData['Email'] ?? 'No Email';

              return ListTile(
                title: Text(userName),
                subtitle: Text(userEmail),
                onTap: () {
                  // Navigate to the edit user screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditUserScreen(
                        userId: users[index].id, initialData: {},
                      ),
                    ),
                  ).then((_) {
                    // Optionally refresh the UI after returning from the edit screen
                    // This is not necessary with StreamBuilder since it updates automatically
                    // But you can implement it if you have any specific state management
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
