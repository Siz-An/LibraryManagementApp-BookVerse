import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class UserDamageReportsDetailScreen extends StatelessWidget {
  final String userName;
  
  const UserDamageReportsDetailScreen({super.key, required this.userName});

  Future<void> _generateUserDamageReportsPdf(BuildContext context) async {
    final pdf = pw.Document();

    // Fetch damage reports for this specific user
    final querySnapshot = await FirebaseFirestore.instance
        .collection('damagedBooks')
        .where('userName', isEqualTo: userName)
        .get();

    final List<Map<String, dynamic>> reportData = [];
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      reportData.add(data);
    }
    
    // Sort reports by reportedAt date (newest first)
    reportData.sort((a, b) {
      final aTimestamp = a['reportedAt'] as Timestamp? ?? Timestamp.now();
      final bTimestamp = b['reportedAt'] as Timestamp? ?? Timestamp.now();
      return bTimestamp.compareTo(aTimestamp);
    });

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              'Damage Reports for $userName',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Generated on: ${DateFormat('MMMM dd, yyyy, h:mm a').format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['SN', 'Book Title', 'Damage Type', 'Reported Date', 'Status'],
              data: List<List<String>>.generate(reportData.length, (index) {
                final item = reportData[index];
                final bookTitle = item['bookTitle'] as String? ?? 'Unknown Book';
                final damageType = item['damageType'] as String? ?? 'Unknown Damage';
                final timestamp = item['reportedAt'] as Timestamp? ?? Timestamp.now();
                final reportedDate = DateFormat('MMM dd, yyyy').format(timestamp.toDate());
                final isAccepted = item['accepted'] as bool? ?? false;
                final isRejected = item['rejected'] as bool? ?? false;
                String status;
                if (isAccepted) {
                  status = 'Accepted';
                } else if (isRejected) {
                  status = 'Rejected';
                } else {
                  status = 'Pending';
                }

                return [
                  '${index + 1}',
                  bookTitle,
                  damageType,
                  reportedDate,
                  status,
                ];
              }),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              headerDecoration: const pw.BoxDecoration(
                color: PdfColors.grey300,
              ),
              cellAlignment: pw.Alignment.centerLeft,
              cellStyle: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/${userName}_damage_reports_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(await pdf.save());

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF generated successfully')),
        );
      }

      // Open the PDF file
      await OpenFile.open(file.path);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating PDF: $e')),
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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.report_problem, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      userName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
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
                  IconButton(
                    icon: const Icon(Icons.download, color: Colors.white, size: 28),
                    onPressed: () => _generateUserDamageReportsPdf(context),
                    tooltip: 'Download PDF Report',
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
              .where('userName', isEqualTo: userName)
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.report_problem, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No damage reports found for this user.',
                      style: TextStyle(
                        color: Color(0xFF4A4E69),
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            }

            final reports = snapshot.data!.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
            
            // Sort reports by reportedAt date (newest first)
            reports.sort((a, b) {
              final aTimestamp = a['reportedAt'] as Timestamp? ?? Timestamp.now();
              final bTimestamp = b['reportedAt'] as Timestamp? ?? Timestamp.now();
              return bTimestamp.compareTo(aTimestamp);
            });

            return ListView.separated(
              itemCount: reports.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final report = reports[index];
                final bookTitle = report['bookTitle'] ?? 'Unknown Book';
                final damageType = report['damageType'] ?? 'Unknown Damage';
                final explanation = report['explanation'] ?? 'No explanation provided';
                final imageUrl = report['imageUrl'];
                final isAccepted = report['accepted'] ?? false;
                final isRejected = report['rejected'] ?? false;
                final timestamp = report['reportedAt'] ?? Timestamp.now();
                final reportedDate = DateFormat('MMMM dd, yyyy, h:mm a').format(timestamp.toDate());
                final bookPrice = report['bookPrice'] ?? 0.0;
                final fineAmount = report['fineAmount'] ?? 0;

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
                              if (isAccepted)
                                const SizedBox(height: 8),
                              if (isAccepted)
                                Text(
                                  'Fine Amount: Rs. $fineAmount',
                                  style: const TextStyle(
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      if (imageUrl != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
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