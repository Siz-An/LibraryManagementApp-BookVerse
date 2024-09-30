import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'Issuing.dart'; // Ensure this import is correct

class UsersListScreen extends StatelessWidget {
  const UsersListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users with Issued Books'),
        centerTitle: true,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('issuedBooks').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No issued books found.'));
          }

          // Get a list of unique userIds from issuedBooks
          final List<String> issuedUserIds = snapshot.data!.docs
              .map((doc) => doc['userId'] as String)
              .toSet() // Use a Set to get unique userIds
              .toList();

          return FutureBuilder<QuerySnapshot>(
            future: FirebaseFirestore.instance.collection('Users').get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (userSnapshot.hasError) {
                return Center(child: Text('Error: ${userSnapshot.error}'));
              }

              if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No users found.'));
              }

              // Filter users who have issued books
              final List<QueryDocumentSnapshot> filteredUsers = userSnapshot.data!.docs
                  .where((doc) => issuedUserIds.contains(doc.id))
                  .toList();

              if (filteredUsers.isEmpty) {
                return const Center(child: Text('No users have issued books.'));
              }

              return ListView(
                children: filteredUsers.map((doc) {
                  var userData = doc.data() as Map<String, dynamic>;
                  String userId = doc.id; // Get the document ID
                  String userName = userData['UserName'] ?? 'No Name';
                  String email = userData['Email'] ?? 'No Email';
                  String phoneNumber = userData['PhoneNumber'] ?? 'No Phone Number';

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: ListTile(
                      title: Text(userName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Email: $email'),
                          Text('Phone: $phoneNumber'),
                        ],
                      ),
                      onTap: () {
                        // Pass the actual userId to the IssuedBooksScreen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => IssuedBooksScreen(userId: userId),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
