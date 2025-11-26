import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:book_Verse/features/home/screens/admin/damagedbooks/report_damage_screen.dart';

class UserReportDamageScreen extends StatelessWidget {
  const UserReportDamageScreen({super.key});

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
                      'Report Book Damage',
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
              .collection('issuedBooks')
              .where('userId', isEqualTo: userId)
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
                  'You have no issued books to report damage for.',
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
                var bookData = doc.data() as Map<String, dynamic>;
                
                String docId = doc.id;
                String imageUrl = bookData['imageUrl'] ?? '';
                String title = bookData['title'] ?? 'No Title';
                String writer = bookData['writer'] ?? 'Unknown';
                Timestamp timestamp = bookData['issueDate'] ?? Timestamp.now();
                String issueDate = DateFormat('MMMM dd, yyyy, h:mm a').format(timestamp.toDate());

                return FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('damagedBooks')
                      .where('bookId', isEqualTo: docId)
                      .where('userId', isEqualTo: userId)
                      .where('resolved', isEqualTo: false)
                      .get(),
                  builder: (context, damageSnapshot) {
                    bool isAlreadyReported = damageSnapshot.hasData && 
                        damageSnapshot.data!.docs.isNotEmpty;
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                        children: [
                          ListTile(
                            contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: imageUrl.isNotEmpty
                                  ? Image.network(
                                      imageUrl,
                                      width: 56,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        // Fallback to a default book icon if image fails to load
                                        return Container(
                                          width: 56,
                                          height: 80,
                                          color: const Color(0xFF9A8C98).withOpacity(0.15),
                                          child: const Icon(Icons.menu_book, size: 36, color: Color(0xFF4A4E69)),
                                        );
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        // Show a loading indicator while the image is loading
                                        if (loadingProgress == null) return child;
                                        return Container(
                                          width: 56,
                                          height: 80,
                                          color: const Color(0xFF9A8C98).withOpacity(0.15),
                                          child: Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF4A4E69)),
                                            ),
                                          ),
                                        );
                                      },
                                    )
                                  : Container(
                                      width: 56,
                                      height: 80,
                                      color: const Color(0xFF9A8C98).withOpacity(0.15),
                                      child: const Icon(Icons.menu_book, size: 36, color: Color(0xFF4A4E69)),
                                    ),
                            ),
                            title: Text(
                              title,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF22223B),
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Writer: $writer',
                                    style: const TextStyle(
                                      color: Color(0xFF4A4E69),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 16, color: Color(0xFF9A8C98)),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Issued: $issueDate',
                                        style: const TextStyle(
                                          color: Color(0xFF9A8C98),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  if (isAlreadyReported)
                                    const Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Damage Already Reported',
                                        style: TextStyle(
                                          color: Colors.orange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isAlreadyReported
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => ReportDamageScreen(
                                              bookId: docId,
                                              bookTitle: title,
                                              userId: userId,
                                            ),
                                          ),
                                        );
                                      },
                                icon: const Icon(Icons.report_problem, color: Colors.white),
                                label: Text(isAlreadyReported ? 'Damage Reported' : 'Report Damage'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isAlreadyReported ? Colors.grey : Colors.redAccent,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                );
              },
            );
          },
        ),
      ),
    );
  }
}