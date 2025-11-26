import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDamagedBooksView extends StatelessWidget {
  const UserDamagedBooksView({super.key});

  @override
  Widget build(BuildContext context) {
    final String userId = FirebaseAuth.instance.currentUser!.uid;

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
                  const SizedBox(width: 10),
                  const Icon(Icons.report_problem, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'My Damage Reports',
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
          stream: FirebaseFirestore.instance
              .collection('damagedBooks')
              .where('userId', isEqualTo: userId)
              .orderBy('reportedAt', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'You have not reported any book damages yet.',
                  style: TextStyle(
                    color: Color(0xFF4A4E69),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              );
            }

            return ListView.separated(
              itemCount: snapshot.data!.docs.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                var doc = snapshot.data!.docs[index];
                var reportData = doc.data() as Map<String, dynamic>;

                String bookTitle = reportData['bookTitle'] ?? 'Unknown Book';
                String damageType = reportData['damageType'] ?? 'Unknown Damage';
                String explanation = reportData['explanation'] ?? 'No explanation provided';
                String? imageUrl = reportData['imageUrl'];
                bool isResolved = reportData['resolved'] ?? false;
                Timestamp timestamp = reportData['reportedAt'] ?? Timestamp.now();
                String reportedDate = DateFormat('MMMM dd, yyyy, h:mm a').format(timestamp.toDate());

                return Container(
                  decoration: BoxDecoration(
                    color: isResolved ? Colors.grey[100] : Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.10),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                bookTitle,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF22223B),
                                ),
                              ),
                            ),
                            if (isResolved)
                              const Icon(Icons.check_circle, color: Colors.green),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Damage Type: $damageType',
                                style: const TextStyle(
                                  color: Color(0xFF4A4E69),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Reported: $reportedDate',
                                style: const TextStyle(
                                  color: Color(0xFF9A8C98),
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                explanation,
                                style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isResolved)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'RESOLVED',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              imageUrl,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 200,
                                  color: const Color(0xFF9A8C98).withOpacity(0.15),
                                  child: const Center(
                                    child: Text('Failed to load image'),
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  height: 200,
                                  color: const Color(0xFF9A8C98).withOpacity(0.15),
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                    ],
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