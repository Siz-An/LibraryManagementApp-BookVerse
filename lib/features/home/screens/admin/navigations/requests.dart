import 'package:book_Verse/features/home/screens/admin/userRequest/userScreens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminUserRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('requests').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No requests found.'));
          }

          final requests = snapshot.data!.docs;
          final users = requests.map((request) => request['userId']).toSet(); // Get unique user IDs

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final userId = users.elementAt(index);

              // Fetch user details from 'users' collection using userId
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('Users').doc(userId).get(), // Fetch from 'users' collection
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const ListTile(
                      title: Text('Loading...'),
                    );
                  }

                  final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

                  // Display user details: username, email, phone number
                  return ListTile(
                    title: Text(userData != null && userData['UserName'] != null
                        ? userData['UserName']
                        : 'Unknown User'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Email: ${userData != null && userData['Email'] != null ? userData['Email'] : 'N/A'}'),
                        Text('Phone: ${userData != null && userData['PhoneNumber'] != null ? userData['PhoneNumber'] : 'N/A'}'),
                      ],
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () {
                      // Navigate to UserRequestedBooksScreen when user is clicked
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserRequestedBooksScreen(userId: userId, adminId: '',),
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
