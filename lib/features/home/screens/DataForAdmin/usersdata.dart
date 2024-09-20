import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'datas.dart';

class UserListPage extends StatelessWidget {
  const UserListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('DATA').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users available.'));
          }

          final data = snapshot.data!.docs;
          final uniqueUsers = <String, Map<String, dynamic>>{};

          // Loop through data and filter unique users by email
          for (var doc in data) {
            final item = doc.data() as Map<String, dynamic>;
            final email = item['Email'] as String? ?? '';

            if (email.isNotEmpty && !uniqueUsers.containsKey(email)) {
              uniqueUsers[email] = item;
            }
          }

          return ListView.builder(
            itemCount: uniqueUsers.length,
            itemBuilder: (context, index) {
              final user = uniqueUsers.values.elementAt(index);
              final username = user['UserName'] as String? ?? 'Unknown User';
              final email = user['Email'] as String? ?? 'Unknown Email';
              final phoneNumber = user['PhoneNumber'] as String? ?? 'Unknown Phone Number';

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    username,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: $username', style: const TextStyle(fontSize: 16)),
                      Text('Email: $email', style: const TextStyle(fontSize: 16)),
                      Text('Phone Number: $phoneNumber', style: const TextStyle(fontSize: 16)),
                    ],
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    if (username.isNotEmpty && email.isNotEmpty) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => IssuedBooksPage(
                            userName: username,
                            userEmail: email,
                            userPhoneNumber: phoneNumber, // Pass phone number to the next page
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Invalid user details.'),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
