import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void showNotificationPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: EdgeInsets.zero, // Optional, to remove padding around the content
        content: Container(
          width: MediaQuery.of(context).size.width * 0.8,
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            children: [
              // Close button on the top-right
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              // Notification title
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Notifications',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              // Divider after title
              const Divider(
                color: Colors.grey, // Divider color
                thickness: 1, // Divider thickness
                indent: 20, // Optional: space from left
                endIndent: 20, // Optional: space from right
              ),
              // StreamBuilder for notifications
              Expanded(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('notifications')
                      .orderBy('timestamp')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final notifications = snapshot.data?.docs ?? [];

                    // Filter new and old notifications
                    final newNotifications = notifications.where((notification) {
                      final data = notification.data() as Map<String, dynamic>;
                      return data.containsKey('isRead') && data['isRead'] == false;
                    }).toList();

                    final oldNotifications = notifications.where((notification) {
                      final data = notification.data() as Map<String, dynamic>;
                      return data.containsKey('isRead') && data['isRead'] == true;
                    }).toList();

                    return ListView(
                      children: [
                        // New Notifications Section
                        if (newNotifications.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'New Notifications',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          ListView.builder(
                            shrinkWrap: true, // Ensures the list view is within the available space
                            itemCount: newNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = newNotifications[index].data() as Map<String, dynamic>;
                              final message = notification['message'] ?? 'No message';
                              final sender = notification['sender'] ?? 'Admin';

                              return ListTile(
                                title: Text(message),
                                subtitle: Text('From: Admin'),
                                onTap: () async {
                                  // Mark notification as read
                                  await FirebaseFirestore.instance
                                      .collection('notifications')
                                      .doc(newNotifications[index].id)
                                      .update({'isRead': true});
                                },
                              );
                            },
                          ),
                        ],
                        // Old Notifications Section
                        if (oldNotifications.isNotEmpty) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              'Old Notifications',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                          const Divider(
                            color: Colors.grey,
                            thickness: 1,
                            indent: 20,
                            endIndent: 20,
                          ),
                          ListView.builder(
                            shrinkWrap: true, // Ensures the list view is within the available space
                            itemCount: oldNotifications.length,
                            itemBuilder: (context, index) {
                              final notification = oldNotifications[index].data() as Map<String, dynamic>;
                              final message = notification['message'] ?? 'No message';
                              final sender = notification['sender'] ?? 'Admin';

                              return ListTile(
                                title: Text(message),
                                subtitle: Text('From: Admin'),
                                onTap: () async {
                                  // You can mark notification as read again or add any other logic here
                                },
                              );
                            },
                          ),
                        ],
                      ],
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
}
