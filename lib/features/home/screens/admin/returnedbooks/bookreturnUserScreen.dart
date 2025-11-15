import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'bookreturn.dart';

class AcceptReturnUsersScreen extends StatelessWidget {
  const AcceptReturnUsersScreen({super.key});

  Future<Map<String, dynamic>> _getUserDetails(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('Users').doc(userId);
    final snapshot = await userDoc.get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return {
        'UserName': data['UserName'] ?? 'Unknown User',
        'PhoneNumber': data['PhoneNumber'] ?? 'Unknown Phone Number',
        'Email': data['Email'] ?? 'Unknown Email',
      };
    }
    return {
      'UserName': 'Unknown User',
      'PhoneNumber': 'Unknown Phone Number',
      'Email': 'Unknown Email',
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.people, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Users With Returned Books',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('toBeReturnedBooks').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No users found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            // Fetch distinct user IDs
            final userIds = snapshot.data!.docs
                .map((doc) => (doc.data() as Map<String, dynamic>)['userId'] as String)
                .toSet()
                .toList();

            return FutureBuilder(
              future: Future.wait(userIds.map((userId) async {
                final userDetails = await _getUserDetails(userId);
                return {
                  'userId': userId,
                  'userDetails': userDetails,
                };
              }).toList()),
              builder: (context, futureSnapshot) {
                if (futureSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (futureSnapshot.hasError) {
                  return Center(child: Text('Error: ${futureSnapshot.error}'));
                }

                final users = futureSnapshot.data as List<Map<String, dynamic>>;

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    final userDetails = user['userDetails'] as Map<String, dynamic>;
                    final userId = user['userId'] as String;

                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF9A8C98).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person,
                            color: Color(0xFF4A4E69),
                            size: 30,
                          ),
                        ),
                        title: Text(
                          userDetails['UserName'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF22223B),
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Email: ${userDetails['Email']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A4E69),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Phone: ${userDetails['PhoneNumber']}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF4A4E69),
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF9A8C98).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.arrow_forward_ios,
                            color: Color(0xFF4A4E69),
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          // Navigate to the book return page with the selected user's userId
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => AcceptReturnedBooksScreen(userId: userId),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}