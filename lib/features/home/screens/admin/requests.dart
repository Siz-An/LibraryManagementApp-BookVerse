import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../common/widgets/appbar/appbar.dart';
import 'userRequest/bookRequest.dart';

class Requests extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: TAppBar(
          title: const Text('Book Requests'),
        ),
        body: const Center(child: Text('User not logged in.')),
      );
    }
    final userId = user.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: TAppBar(
              title: const Text('User Requests'),
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Scaffold(
            appBar: TAppBar(
              title: const Text('User Requests'),
            ),
            body: const Center(child: Text('No requests found.')),
          );
        }

        // User has made requests, now fetch and display user details
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: TAppBar(
                  title: const Text('User Requests'),
                ),
                body: const Center(child: CircularProgressIndicator()),
              );
            }

            if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
              return Scaffold(
                appBar: TAppBar(
                  title: const Text('User Requests'),
                ),
                body: const Center(child: Text('User not found.')),
              );
            }

            final userData = userSnapshot.data!.data() as Map<String, dynamic>;
            final name = userData['UserName'];
            final phoneNumber = userData['PhoneNumber'];
            final email = userData['Email'];

            return Scaffold(
              appBar: TAppBar(
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
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      width: 250, // Smaller width for compact design
                      height: 100,
                      padding: const EdgeInsets.all(8.0), // Reduced padding
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: Colors.grey[200], // Lighter background for a softer look
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Name: $name',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Phone: $phoneNumber',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Email: $email',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}


