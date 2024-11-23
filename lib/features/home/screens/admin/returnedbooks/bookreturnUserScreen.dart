import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'bookreturn.dart';

class AcceptReturnUsersScreen extends StatelessWidget {
  const AcceptReturnUsersScreen({super.key});

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final snapshot = await userDoc.get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'UserName': data['UserName'] ?? 'Unknown User',
        'PhoneNumber': data['PhoneNumber'] ?? 'Unknown Phone Number',
        'Email': data['Email'] ?? 'Unknown Email',
      };
    }
    return {
      'UserName': 'Unknown User',
      'PhoneNumber': 'Unknown Phone Number',
      'Email': 'Unknown Email',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users With Returned Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('toBeReturnedBooks').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No users found.'));
          }

          // Fetch distinct user IDs
          final userIds = snapshot.data!.docs
              .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String)
              .toSet()
              .toList();

          return FutureBuilder(
            future: Future.wait(userIds.map((userId) async {
              final userDetails = await _getUserDetails(userId);
              return {
                'userId': userId,
                'userDetails': userDetails,
              };
            }).toList()),
            builder: (context, futureSnapshot) {
              if (futureSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (futureSnapshot.hasError) {
                return Center(child: Text('Error: ${futureSnapshot.error}'));
              }

              final users = futureSnapshot.data as List<Map<String, dynamic>>;

              return ListView.builder(
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  final userDetails = user['userDetails'] as Map<String, dynamic>;
                  final userId = user['userId'] as String;

                  return ListTile(
                    title: Text('UserName: ${userDetails['UserName']}'),
                    subtitle: Text('Email: ${userDetails['Email']}\nPhone: ${userDetails['PhoneNumber']}'),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to the book return page with the selected user's userId
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => AcceptReturnedBooksScreen(userId: userId),
                        ),
                      );
                    },
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
