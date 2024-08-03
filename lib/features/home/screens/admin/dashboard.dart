import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late Future<List<QuerySnapshot>> _futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _futureData = Future.wait([
      FirebaseFirestore.instance.collection('Books').get(),
      FirebaseFirestore.instance.collection('Users').get(),
      FirebaseFirestore.instance.collection('IssuedBooks').get(),
      FirebaseFirestore.instance.collection('ReturnedBooks').get(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<QuerySnapshot>>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (!snapshot.hasData) {
            return Center(child: Text('No data found'));
          }

          final booksSnapshot = snapshot.data![0];
          final usersSnapshot = snapshot.data![1];
          final issuedBooksSnapshot = snapshot.data![2];
          final returnedBooksSnapshot = snapshot.data![3];

          final totalBooks = booksSnapshot.size;
          final totalUsers = usersSnapshot.size;
          final issuedBooks = issuedBooksSnapshot.docs;
          final returnedBooks = returnedBooksSnapshot.docs;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildStatCard('Total Number of Books', totalBooks.toString()),
              _buildStatCard('Total Number of Users', totalUsers.toString()),
              _buildNotificationsCard(),
              _buildIssuedBooksCard(issuedBooks),
              _buildReturnedBooksCard(returnedBooks),
            ],
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(title),
        trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return ListTile(
              title: Text('Notifications Sent'),
              subtitle: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return ListTile(
              title: Text('Notifications Sent'),
              subtitle: Center(child: Text('Something went wrong')),
            );
          }

          final notifications = snapshot.data?.docs ?? [];
          final uniqueNotifications = _getUniqueNotifications(notifications);

          return ExpansionTile(
            title: Text('Notifications Sent (${uniqueNotifications.length})'),
            children: uniqueNotifications.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final message = data['message'] ?? 'No message';
              final timestamp = (data['timestamp'] as Timestamp).toDate();

              return ListTile(
                title: Text(message),
                subtitle: Text('Sent on ${timestamp.toLocal()}'),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool success = await _deleteNotification(doc.id);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Notification deleted successfully')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to delete notification')),
                      );
                    }
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  List<QueryDocumentSnapshot> _getUniqueNotifications(List<QueryDocumentSnapshot> notifications) {
    final Map<String, QueryDocumentSnapshot> uniqueNotifications = {};
    for (var doc in notifications) {
      final data = doc.data() as Map<String, dynamic>;
      final message = data['message'] ?? '';
      if (!uniqueNotifications.containsKey(message)) {
        uniqueNotifications[message] = doc;
      }
    }
    return uniqueNotifications.values.toList();
  }

  Future<bool> _deleteNotification(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  Widget _buildIssuedBooksCard(List<QueryDocumentSnapshot> issuedBooks) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ExpansionTile(
        title: Text('Books Issued'),
        children: issuedBooks.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final bookTitle = data['bookTitle'] ?? 'No title';
          final user = data['user'] ?? 'Unknown user';
          final issueDate = (data['issueDate'] as Timestamp).toDate();
          return ListTile(
            title: Text(bookTitle),
            subtitle: Text('Issued to $user on ${issueDate.toLocal()}'),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReturnedBooksCard(List<QueryDocumentSnapshot> returnedBooks) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ExpansionTile(
        title: Text('Books Returned'),
        children: returnedBooks.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final bookTitle = data['bookTitle'] ?? 'No title';
          final user = data['user'] ?? 'Unknown user';
          final returnDate = (data['returnDate'] as Timestamp).toDate();
          return ListTile(
            title: Text(bookTitle),
            subtitle: Text('Returned by $user on ${returnDate.toLocal()}'),
          );
        }).toList(),
      ),
    );
  }
}
