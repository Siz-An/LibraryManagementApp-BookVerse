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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header section (unchanged)
            const TPrimaryHeaderContainer(
              child: Column(
                children: [
                  SizedBox(height: TSizes.sm),
                  TAdminAppBar(),
                  SizedBox(height: TSizes.spaceBtwSections),
                ],
              ),
            ),
            // Modern Dashboard content
            FutureBuilder<List<QuerySnapshot>>(
              future: _futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.only(top: 60.0),
                    child: Center(child: CircularProgressIndicator()),
                  );
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
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Modern Stat Cards Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _modernStatCard(
                            title: 'Books',
                            icon: Icons.menu_book_rounded,
                            value: totalBooks.toString(),
                            color: Colors.blueAccent,
                            context: context,
                            navigateTo: AllBooksScreenAdmin(),
                          ),
                          _modernStatCard(
                            title: 'Users',
                            icon: Icons.people_alt_rounded,
                            value: totalUsers.toString(),
                            color: Colors.deepPurpleAccent,
                            context: context,
                            navigateTo: AllUsersScreen(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Modern Notifications Card
                      _modernNotificationsCard(),
                      const SizedBox(height: 20),
                      // Modern Issued Books Card
                      _modernExpandableCard(
                        title: 'Books Issued',
                        icon: Icons.assignment_turned_in_rounded,
                        color: Colors.greenAccent.shade400,
                        children: _buildUniqueUsersList(issuedBooks, context),
                      ),
                      const SizedBox(height: 16),
                      // Modern Returned Books Card
                      _modernExpandableCard(
                        title: 'Books Returned',
                        icon: Icons.assignment_return_rounded,
                        color: Colors.orangeAccent.shade200,
                        children: _buildUniqueReturnedUsersList(toBeReturnedBooks, context),
                      ),
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

  Widget _modernStatCard({
    required String title,
    required IconData icon,
    required String value,
    required Color color,
    required BuildContext context,
    Widget? navigateTo,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          if (navigateTo != null) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => navigateTo),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 6),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(color: color.withOpacity(0.15), width: 1.2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, color: color, size: 28),
                radius: 26,
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernNotificationsCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('notifications').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent.withOpacity(0.12),
                  child: const Icon(Icons.notifications, color: Colors.blueAccent),
                ),
                title: const Text('Notifications Sent'),
                subtitle: const LinearProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.redAccent.withOpacity(0.12),
                  child: const Icon(Icons.notifications_off, color: Colors.redAccent),
                ),
                title: const Text('Notifications Sent'),
                subtitle: const Text('Something went wrong'),
              );
            }

            final notifications = snapshot.data?.docs ?? [];
            final uniqueNotifications = _getUniqueNotifications(notifications);

            return ExpansionTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blueAccent.withOpacity(0.12),
                child: const Icon(Icons.notifications, color: Colors.blueAccent),
              ),
              title: Text(
                'Notifications (${uniqueNotifications.length})',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              children: uniqueNotifications.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Text('No notifications sent yet.'),
                      )
                    ]
                  : uniqueNotifications.map((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      final message = data['message'] ?? 'No message';
                      final timestamp = (data['timestamp'] as Timestamp).toDate();

                      return ListTile(
                        leading: const Icon(Icons.message_rounded, color: Colors.blueAccent),
                        title: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
                        subtitle: Text(
                          'Sent on ${timestamp.toLocal().toString().substring(0, 16)}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
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
      ),
    );
  }

  Widget _modernExpandableCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color, size: 26),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: color.darken(0.2),
            fontSize: 17,
          ),
        ),
        children: children.isEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text('No $title yet.'),
                )
              ]
            : children,
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
              leading: CircleAvatar(
                backgroundColor: Colors.greenAccent.withOpacity(0.15),
                child: const Icon(Icons.person, color: Colors.green),
              ),
              title: Text(username, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(email, style: const TextStyle(fontSize: 13)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
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
              leading: CircleAvatar(
                backgroundColor: Colors.orangeAccent.withOpacity(0.15),
                child: const Icon(Icons.person, color: Colors.orange),
              ),
              title: Text(username, style: const TextStyle(fontWeight: FontWeight.w500)),
              subtitle: Text(email, style: const TextStyle(fontSize: 13)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
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

// Extension for color darken
extension ColorUtils on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
