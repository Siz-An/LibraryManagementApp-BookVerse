import 'package:book_Verse/features/home/screens/admin/widgets/adminappbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../../../common/widgets/custom_shapes/primary_header_container.dart';
import '../../../../../utils/constants/sizes.dart';
import '../BookIssue/Issuing.dart';
import '../USersScreen/allUser.dart';
import '../allbooks.dart';
import '../returnedbooks/bookreturn.dart';

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
      backgroundColor: Colors.grey[200],
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
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const Center(child: Text('Something went wrong'));
                }

                if (!snapshot.hasData) {
                  return const Center(child: Text('No data found'));
                }

                final booksSnapshot = snapshot.data![0];
                final usersSnapshot = snapshot.data![1];
                final issuedBooksSnapshot = snapshot.data![2];
                final returnedBooksSnapshot = snapshot.data![3];

                final totalBooks = booksSnapshot.size;
                final totalUsers = usersSnapshot.size;
                final issuedBooks = issuedBooksSnapshot.docs;
                final toBeReturnedBooks = returnedBooksSnapshot.docs;

                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildStatCard('Total Books', Icons.book, totalBooks.toString(), context, AllBooksScreenAdmin()),
                      _buildStatCard('Total Users', Icons.people, totalUsers.toString(), context, AllUsersScreen()),
                      _buildNotificationsCard(),
                      _buildIssuedBooksCard(issuedBooks, context),
                      _buildReturnedBooksCard(toBeReturnedBooks, context),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, String value, BuildContext context, [Widget? navigateTo]) {
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
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 3,
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: Icon(icon, color: Colors.blueAccent),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          trailing: Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const ListTile(
              title: Text('Notifications Sent'),
              subtitle: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError) {
            return const ListTile(
              title: Text('Notifications Sent'),
              subtitle: Center(child: Text('Something went wrong')),
            );
          }

          final notifications = snapshot.data?.docs ?? [];
          final uniqueNotifications = _getUniqueNotifications(notifications);

          return ExpansionTile(
            title: Text('Notifications (${uniqueNotifications.length})'),
            children: uniqueNotifications.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              final message = data['message'] ?? 'No message';
              final timestamp = (data['timestamp'] as Timestamp).toDate();

              return ListTile(
                title: Text(message),
                subtitle: Text('Sent on ${timestamp.toLocal()}'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    bool success = await _deleteNotification(doc.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(success ? 'Deleted successfully' : 'Failed to delete')),
                    );
                  },
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Widget _buildIssuedBooksCard(List<QueryDocumentSnapshot> issuedBooks, BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ExpansionTile(
        title: const Text('Books Issued'),
        children: _buildUniqueUsersList(issuedBooks, context),
      ),
    );
  }

  Widget _buildReturnedBooksCard(List<QueryDocumentSnapshot> returnedBooks, BuildContext context) {
    return Card(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      child: ExpansionTile(
        title: const Text('Books Returned'),
        children: _buildUniqueReturnedUsersList(returnedBooks, context),
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
      await FirebaseFirestore.instance.collection('notifications').doc(notificationId).delete();
      return true;
    } catch (e) {
      print('Error deleting notification: $e');
      return false;
    }
  }

  List<Widget> _buildUniqueUsersList(List<QueryDocumentSnapshot> issuedBooks, BuildContext context) {
    final Set<String> displayedUsers = {};
    final List<Widget> userTiles = [];

    for (var doc in issuedBooks) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'] ?? 'Unknown user';

      if (displayedUsers.contains(userId)) continue;

      displayedUsers.add(userId);
      userTiles.add(
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(title: Text('Loading user details...'));
            }
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return const ListTile(title: Text('User not found'));
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['UserName'] ?? 'Unknown';
            final email = userData['Email'] ?? 'No email';

            return ListTile(
              title: Text(username),
              subtitle: Text(email),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IssuedBooksScreen(userId: userId)),
              ),
            );
          },
        ),
      );
    }

    return userTiles;
  }

  List<Widget> _buildUniqueReturnedUsersList(List<QueryDocumentSnapshot> returnedBooks, BuildContext context) {
    final Set<String> displayedUsers = {};
    final List<Widget> userTiles = [];

    for (var doc in returnedBooks) {
      final data = doc.data() as Map<String, dynamic>;
      final userId = data['userId'] ?? 'Unknown user';

      if (displayedUsers.contains(userId)) continue;

      displayedUsers.add(userId);
      userTiles.add(
        FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const ListTile(title: Text('Loading user details...'));
            }
            if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
              return const ListTile(title: Text('User not found'));
            }
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            final username = userData['UserName'] ?? 'Unknown';
            final email = userData['Email'] ?? 'No email';

            return ListTile(
              title: Text(username),
              subtitle: Text(email),
              trailing: const Icon(Icons.arrow_forward),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AcceptReturnedBooksScreen(userId: userId)),
              ),
            );
          },
        ),
      );
    }

    return userTiles;
  }
}
