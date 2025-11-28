import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserDamagedBooksView extends StatefulWidget {
  const UserDamagedBooksView({super.key});

  @override
  State<UserDamagedBooksView> createState() => _UserDamagedBooksViewState();
}

class _UserDamagedBooksViewState extends State<UserDamagedBooksView> {
  Future<void> _showPaymentConfirmation(BuildContext context, String docId, int fineAmount) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Payment'),
          content: Text('Are you sure you want to pay the fine of Rs. $fineAmount?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Pay'),
              onPressed: () async {
                Navigator.of(context).pop();
                // Get the damage report to get bookId and userId
                final reportDoc = await FirebaseFirestore.instance.collection('damagedBooks').doc(docId).get();
                if (reportDoc.exists) {
                  final reportData = reportDoc.data() as Map<String, dynamic>;
                  final String bookId = reportData['bookId'] ?? '';
                  final String userId = reportData['userId'] ?? '';
                  final String bookTitle = reportData['bookTitle'] ?? 'Unknown Book';
                  final String damageType = reportData['damageType'] ?? 'Unknown Damage';
                  final String explanation = reportData['explanation'] ?? '';
                  final String? imageUrl = reportData['imageUrl'];
                  final int? fineAmount = reportData['fineAmount'];
                  
                  // Update the damage report as resolved
                  await FirebaseFirestore.instance.collection('damagedBooks').doc(docId).update({
                    'resolved': true,
                    'resolvedAt': FieldValue.serverTimestamp(),
                  });
                  
                  // Remove the book from issued books
                  if (bookId.isNotEmpty && userId.isNotEmpty) {
                    try {
                      print('Attempting to remove book from issuedBooks: bookId=$bookId, userId=$userId');
                      
                      // Query issuedBooks with the correct field names
                      // Using separate queries to avoid composite index requirements
                      final issuedBooksByBookId = await FirebaseFirestore.instance
                          .collection('issuedBooks')
                          .where('bookId', isEqualTo: bookId)
                          .get();
                      
                      final issuedBooksQuery = issuedBooksByBookId.docs.where((doc) => 
                        doc['userId'] == userId
                      ).toList();
                      
                      print('Found ${issuedBooksByBookId.docs.length} issued books with bookId=$bookId');
                      print('Filtered to ${issuedBooksQuery.length} issued books for userId=$userId');
                      
                      print('Found ${issuedBooksQuery.length} issued book records to delete');
                      
                      if (issuedBooksQuery.isEmpty) {
                        print('No matching issued book records found');
                        // Try a broader query to debug
                        final allIssuedBooks = await FirebaseFirestore.instance
                            .collection('issuedBooks')
                            .limit(5)
                            .get();
                        print('Sample issued books:');
                        for (var doc in allIssuedBooks.docs) {
                          print('  Doc ID: ${doc.id}, Data: ${doc.data()}');
                        }
                      }
                      
                      for (var doc in issuedBooksQuery) {
                        print('Deleting issued book record with ID: ${doc.id}');
                        await FirebaseFirestore.instance.collection('issuedBooks').doc(doc.id).delete();
                        print('Successfully deleted issued book record');
                      }
                    } catch (e) {
                      print('Error removing book from issuedBooks: $e');
                      // Continue with the process even if deletion fails
                    }
                    
                    // Add the book to damageBookData collection
                    try {
                      await FirebaseFirestore.instance.collection('damageBookData').add({
                        'bookId': bookId,
                        'bookTitle': bookTitle,
                        'userId': userId,
                        'damageType': damageType,
                        'explanation': explanation,
                        'imageUrl': imageUrl,
                        'fineAmount': fineAmount,
                        'resolvedAt': FieldValue.serverTimestamp(),
                        'paidAt': FieldValue.serverTimestamp(),
                      });
                      print('Successfully added record to damageBookData');
                    } catch (e) {
                      print('Error adding record to damageBookData: $e');
                    }
                  }
                }
                
                // Show success message
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment successful! Thank you.'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

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

            final userReports = snapshot.data!.docs.where((doc) => doc['userId'] == userId).toList();
            
            if (userReports.isEmpty) {
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
              itemCount: userReports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                var doc = userReports[index];
                var reportData = doc.data() as Map<String, dynamic>;

                String bookTitle = reportData['bookTitle'] ?? 'Unknown Book';
                String damageType = reportData['damageType'] ?? 'Unknown Damage';
                String explanation = reportData['explanation'] ?? 'No explanation provided';
                String? imageUrl = reportData['imageUrl'];
                bool isResolved = reportData['resolved'] ?? false;
                bool isAccepted = reportData['accepted'] ?? false;
                bool isRejected = reportData['rejected'] ?? false;
                int? fineAmount = reportData['fineAmount'];
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
                              if (isAccepted && fineAmount != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'Fine Amount: Rs. $fineAmount',
                                    style: const TextStyle(
                                      color: Colors.deepPurple,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              if (isAccepted)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'ACCEPTED',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else if (isRejected)
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'REJECTED',
                                    style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              else
                                const Padding(
                                  padding: EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    'PENDING',
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
                      if (isAccepted && fineAmount != null && !isResolved)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                // TODO: Implement payment functionality
                                _showPaymentConfirmation(context, doc.id, fineAmount);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.deepPurple,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Pay Fine',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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