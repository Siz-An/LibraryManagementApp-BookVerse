import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DamagedBooksAdminScreen extends StatelessWidget {
  const DamagedBooksAdminScreen({super.key});

  // Fine amounts based on damage type
  int _calculateFine(String damageType, double bookPrice) {
    switch (damageType.toLowerCase()) {
      case 'minor damage':
      case 'torn pages':
        return 500;
      case 'major damage':
      case 'water damage':
      case 'cover damage':
      case 'spine damage':
        return 2000;
      case 'lost':
      case 'missing pages':
        return bookPrice.toInt();
      default:
        return 10000; // Default fine for other damage types
    }
  }

  Future<void> _acceptDamageReport(BuildContext context, String docId, String userId, String bookId, String damageType, double bookPrice) async {
    final fineAmount = _calculateFine(damageType, bookPrice);
    
    try {
      // Update the damage report as accepted
      await FirebaseFirestore.instance.collection('damagedBooks').doc(docId).update({
        'accepted': true,
        'acceptedAt': FieldValue.serverTimestamp(),
        'fineAmount': fineAmount,
      });
      
      // Show success message
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Damage report accepted. Fine amount: Rs. $fineAmount'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept damage report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _rejectDamageReport(BuildContext context, String docId) async {
    try {
      await FirebaseFirestore.instance.collection('damagedBooks').doc(docId).update({
        'rejected': true,
        'rejectedAt': FieldValue.serverTimestamp(),
      });
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Damage report rejected'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to reject damage report: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
                  const SizedBox(width: 10),
                  const Icon(Icons.report_problem, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Damage Reports',
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
          stream: FirebaseFirestore.instance.collection('damagedBooks').orderBy('reportedAt', descending: true).snapshots(),
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
                  'No damage reports found.',
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
                
                String docId = doc.id;
                String bookTitle = reportData['bookTitle'] ?? 'Unknown Book';
                String userName = reportData['userName'] ?? 'Unknown User';
                String damageType = reportData['damageType'] ?? 'Unknown Damage';
                String explanation = reportData['explanation'] ?? 'No explanation provided';
                String? imageUrl = reportData['imageUrl'];
                bool isAccepted = reportData['accepted'] ?? false;
                bool isRejected = reportData['rejected'] ?? false;
                Timestamp timestamp = reportData['reportedAt'] ?? Timestamp.now();
                String reportedDate = DateFormat('MMMM dd, yyyy, h:mm a').format(timestamp.toDate());
                double bookPrice = reportData['bookPrice'] ?? 0.0;
                int fineAmount = reportData['fineAmount'] ?? _calculateFine(damageType, bookPrice);

                return Container(
                  decoration: BoxDecoration(
                    color: isAccepted ? Colors.green[50] : (isRejected ? Colors.red[50] : Colors.white),
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
                            if (isAccepted)
                              const Icon(Icons.check_circle, color: Colors.green)
                            else if (isRejected)
                              const Icon(Icons.cancel, color: Colors.red)
                            else
                              const Icon(Icons.pending, color: Colors.orange),
                          ],
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Reported by: $userName',
                                style: const TextStyle(
                                  color: Color(0xFF4A4E69),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
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
                              const SizedBox(height: 8),
                              Text(
                                'Fine Amount: Rs. $fineAmount',
                                style: const TextStyle(
                                  color: Colors.deepPurple,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
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
                      if (!isAccepted && !isRejected)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _acceptDamageReport(context, docId, reportData['userId'], reportData['bookId'], damageType, bookPrice),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Accept & Set Fine',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _rejectDamageReport(context, docId),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reject',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
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