import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'editUser.dart';

class AllUsersScreen extends StatelessWidget {
  const AllUsersScreen({super.key});

  // Function to toggle user activation status
  Future<void> _toggleUserActivation(String userId, bool isCurrentlyActive) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'can_login': isCurrentlyActive ? 'no' : 'yes',
      });
    } catch (e) {
      // Handle error if needed
      print('Error updating user activation status: $e');
    }
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
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.people, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'All Users',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
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
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('Users').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Something went wrong'));
            }
            final users = snapshot.data?.docs ?? [];
            if (users.isEmpty) {
              return const Center(child: Text('No users found'));
            }
            return ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final userData = users[index].data() as Map<String, dynamic>;
                final userName = userData['UserName'] ?? 'No Name';
                final userEmail = userData['Email'] ?? 'No Email';
                final userId = users[index].id;
                
                // Check if user can login (default to 'no' if not set)
                final canLogin = userData['can_login'] ?? 'no';
                final isActivated = canLogin == 'yes';
                final isSuspended = canLogin == 'suspended';

                return Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditUserScreen(
                            userId: userId,
                            initialData: {},
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 16),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: const Color(0xFF9A8C98),
                            child: Text(
                              userName.isNotEmpty
                                  ? userName[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Color(0xFF22223B),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userEmail,
                                  style: const TextStyle(
                                    color: Color(0xFF4A4E69),
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // Status indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActivated 
                                        ? Colors.green.withOpacity(0.2) 
                                        : isSuspended 
                                            ? Colors.orange.withOpacity(0.2) 
                                            : Colors.red.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isActivated ? 'Active' : isSuspended ? 'Suspended' : 'Inactive',
                                    style: TextStyle(
                                      color: isActivated 
                                          ? Colors.green 
                                          : isSuspended 
                                              ? Colors.orange 
                                              : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              const Icon(Icons.edit, color: Color(0xFF4A4E69)),
                              const SizedBox(height: 8),
                              // Activation button
                              ElevatedButton(
                                onPressed: () {
                                  if (!isSuspended) { // Don't allow activation if suspended
                                    _toggleUserActivation(userId, isActivated);
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isActivated ? Colors.red : Colors.green,
                                  minimumSize: const Size(80, 30),
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  isActivated ? 'Deactivate' : 'Activate',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}