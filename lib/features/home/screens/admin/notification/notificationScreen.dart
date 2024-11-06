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
  bool _isSending = false; // To prevent multiple sends

  void _sendNotification() async {
    if (_messageController.text.isNotEmpty && !_isSending) {
      setState(() {
        _isSending = true;
      });

      final user = _auth.currentUser;
      if (user != null) {
        // Assuming you have a way to get a single recipient user ID
        final recipientUserId = 'user1Id'; // Replace with actual recipient ID

        try {
          await _firestore.collection('notifications').add({
            'message': _messageController.text,
            'sender': user.email,
            'recipientId': recipientUserId,
            'timestamp': FieldValue.serverTimestamp(),
            'isRead': false, // Add isRead field and set it to false initially
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Notification sent successfully')),
          );
        } catch (e) {
          print('Error sending notification: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to send notification')),
          );
        } finally {
          setState(() {
            _isSending = false;
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
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(hintText: 'Enter notification message...'),
                maxLines: null, // Allow multiple lines of text
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 50.0), // Add space above the button
              child: ElevatedButton(
                onPressed: _sendNotification,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.teal, // Text color
                  minimumSize: const Size(double.infinity, 48), // Full-width button
                ),
                child: _isSending
                    ? const CircularProgressIndicator()
                    : const Text('Send Notification'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
