import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminNotificationScreen extends StatelessWidget {
  const AdminNotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .orderBy('timestamp')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final notifications = snapshot.data?.docs ?? [];
          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index].data() as Map<String, dynamic>;
              final message = notification['message'] ?? 'No message';
              final sender = notification.containsKey('sender') ? notification['sender'] : 'Admin';

              return ListTile(
                title: Text(message),
                subtitle: Text('From: $sender'),
                onTap: () async {
                  // Mark notification as read
                  await FirebaseFirestore.instance
                      .collection('notifications')
                      .doc(notifications[index].id)
                      .update({'isRead': true});
                },
              );
            },
          );
        },
      ),
    );
  }
}
