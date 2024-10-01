import 'package:book_Verse/features/home/screens/admin/widgets/adminappbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../../utils/constants/sizes.dart';
import '../BookIssue/Issuing.dart';
import '../USersScreen/allUser.dart';
import '../allbooks.dart';
import '../returnedbooks/bookreturn.dart'; // Import the new users screen

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
      FirebaseFirestore.instance.collection('books').get(),
      FirebaseFirestore.instance.collection('Users').get(),
      FirebaseFirestore.instance.collection('issuedBooks').get(),
      FirebaseFirestore.instance.collection('toBeReturnedBooks').get(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
                  SizedBox(height: TSizes.sm),
                  TAdminAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),

            // Dashboard content
            FutureBuilder<List<QuerySnapshot>>(
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
                final toBeReturnedBooks = returnedBooksSnapshot.docs;

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          _buildStatCard('Total Number of Books', totalBooks.toString(), context, AllBooksScreenadmin()),
                          _buildStatCard('Total Number of Users', totalUsers.toString(), context, AllUsersScreen()),
                          _buildNotificationsCard(),
                          _buildIssuedBooksCard(issuedBooks, context),
                          _buildReturnedBooksCard(toBeReturnedBooks, context),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, BuildContext context, [Widget? navigateTo]) {
    return GestureDetector(
      onTap: () {
        if (navigateTo != null) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => navigateTo),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          title: Text(title),
          trailing: Text(value, style: TextStyle(fontWeight: FontWeight.bold)),
        ),
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

  Widget _buildIssuedBooksCard(List<QueryDocumentSnapshot> issuedBooks, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ExpansionTile(
        title: Text('Books Issued'),
        children: _buildUniqueUsersList(issuedBooks, context),
      ),
    );
  }

  List<Widget> _buildUniqueUsersList(List<QueryDocumentSnapshot> issuedBooks, BuildContext context) {
    final Set<String> displayedUsers = {}; // To keep track of displayed user IDs
    final List<Widget> userTiles = [];

    for (var doc in issuedBooks) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'] ?? 'Unknown user';

      // Skip if this userId has already been processed
      if (displayedUsers.contains(userId)) {
        continue;
      }

      displayedUsers.add(userId); // Add userId to the set

      userTiles.add(
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                title: Text('Loading user details...'),
              );
            } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return ListTile(
                title: Text('User not found'),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['UserName'] ?? 'Unknown';
            final email = userData['Email'] ?? 'No email';

            return ListTile(
              title: Text(username),
              subtitle: Text(email),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to the next screen, passing the userId or user details if needed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => IssuedBooksScreen(userId: userId),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return userTiles;
  }


  Widget _buildReturnedBooksCard(List<QueryDocumentSnapshot> returnedBooks, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 4,
      child: ExpansionTile(
        title: Text('Books Returned'),
        children: _buildUniqueReturnedUsersList(returnedBooks, context),
      ),
    );
  }

  List<Widget> _buildUniqueReturnedUsersList(List<QueryDocumentSnapshot> returnedBooks, BuildContext context) {
    final Set<String> displayedUsers = {}; // To keep track of displayed user IDs
    final List<Widget> userTiles = [];

    for (var doc in returnedBooks) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'] ?? 'Unknown user'; // Assuming userId is the field name

      // Skip if this userId has already been processed
      if (displayedUsers.contains(userId)) {
        continue;
      }

      displayedUsers.add(userId); // Add userId to the set

      userTiles.add(
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                title: Text('Loading user details...'),
              );
            } else if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return ListTile(
                title: Text('User not found'),
              );
            }

            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['UserName'] ?? 'Unknown';
            final email = userData['Email'] ?? 'No email';

            return ListTile(
              title: Text(username),
              subtitle: Text(email),
              trailing: Icon(Icons.arrow_forward),
              onTap: () {
                // Navigate to the next screen, passing the userId or user details if needed
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AcceptReturnedBooksScreen(userId: userId), // Navigate to IssuedBooksScreen
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return userTiles;
  }


}
