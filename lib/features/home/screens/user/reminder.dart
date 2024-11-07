import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void showReminderPopup(BuildContext context) {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Flag to track if the reminder was already shown
  bool reminderShown = false;

  // Fetch current user ID
  final userId = _auth.currentUser?.uid;

  if (userId == null || reminderShown) {
    return; // If no user is logged in or reminder is already shown, don't show the popup
  }

  // Query the issuedBooks collection for overdue books
  _firestore.collection('issuedBooks')
      .where('userId', isEqualTo: userId)
      .where('issueDate', isLessThan: Timestamp.now()) // Assuming there's an 'isReturned' field to track if the book is returned
      .snapshots()
      .listen((snapshot) {
    if (snapshot.docs.isNotEmpty) {
      // Book is overdue, show the reminder popup
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            titlePadding: EdgeInsets.zero,
            title: Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the popup immediately on single click
                    reminderShown = true; // Mark reminder as shown
                  },
                ),
              ),
            ),
            content: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              height: MediaQuery.of(context).size.height * 0.6,
              child: Column(
                children: [
                  // Title
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Reminder!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  // Divider after title
                  const Divider(
                    color: Colors.grey,
                    thickness: 1,
                    indent: 20,
                    endIndent: 20,
                  ),
                  // Notification message
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'The following book is overdue and needs to be returned:',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.docs.length,
                      itemBuilder: (context, index) {
                        final book = snapshot.docs[index];
                        final title = book['title'] ?? 'Unknown title';
                        final issueDate = (book['issueDate'] as Timestamp).toDate();

                        // Format the issue date to a more readable format
                        String formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(issueDate);

                        return ListTile(
                          title: Text(title),
                          subtitle: Text('Issued on: $formattedDate'),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );

      // Set a 15-second timer to automatically close the popup

    }
  });
}


