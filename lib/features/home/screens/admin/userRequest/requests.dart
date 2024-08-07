import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class Requests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('User not logged in.'));
    }
    final userId = user.uid;

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Center(child: Text('User not found.'));
        }

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final name = userData['UserName'];
        final phoneNumber = userData['PhoneNumber'];
        final email = userData['Email'];

        return Scaffold(
          appBar: AppBar(
            title: const Text('User Requests'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserRequestsScreen(),
                  ),
                );
              },
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 130), // Limit the height
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Name: $name', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Phone: $phoneNumber', style: TextStyle(fontSize: 16)),
                      SizedBox(height: 8),
                      Text('Email: $email', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class UserRequestsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Center(child: Text('User not logged in.'));
    }
    final userId = user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requested Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No requests found.'));
          }

          final requests = snapshot.data!.docs;

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final books = List<Map<String, dynamic>>.from(request['books']);

              return ExpansionTile(
                title: Text('Request ${index + 1}'),
                children: books.map((book) {
                  return ListTile(
                    title: Text(book['title']),
                    subtitle: Text('Author: ${book['writer']}'),
                    leading: book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                        ? Image.network(
                      book['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.book);
                      },
                    )
                        : const Icon(Icons.book),
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
