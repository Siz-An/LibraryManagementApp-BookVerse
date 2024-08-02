import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _sendNotification() async {
    if (_messageController.text.isNotEmpty) {
      final user = _auth.currentUser;
      if (user != null) {
        // Assuming you have a way to get recipient user IDs
        // You can modify this to fetch user IDs based on some criteria
        final recipientUserIds = ['user1Id', 'user2Id']; // Replace with actual recipient IDs

        for (String userId in recipientUserIds) {
          await _firestore.collection('notifications').add({
            'message': _messageController.text,
            'sender': user.email,
            'recipientId': userId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        }
        _messageController.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Notification'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(hintText: 'Enter notification message...'),
                maxLines: null, // Allow multiple lines of text
              ),
            ),
            ElevatedButton(
              onPressed: _sendNotification,
              child: const Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
