import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

import 'user_damage_reports_detail_screen.dart';

class UserWiseDamageReportsScreen extends StatelessWidget {
  const UserWiseDamageReportsScreen({super.key});

  Future<void> _generateUserWiseDamageReportsPdf(BuildContext context) async {
    final pdf = pw.Document();

    // Fetch all damage reports
    final querySnapshot = await FirebaseFirestore.instance
        .collection('damagedBooks')
        .orderBy('reportedAt', descending: true)
        .get();

    // Group reports by user
    final Map<String, List<Map<String, dynamic>>> userReports = {};
    for (var doc in querySnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final userName = data['userName'] as String? ?? 'Unknown User';
      
      if (!userReports.containsKey(userName)) {
        userReports[userName] = [];
      }
      userReports[userName]!.add(data);
    }
    
    // Sort users alphabetically
    final sortedUsers = userReports.keys.toList()..sort();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              'User-wise Damage Reports',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Text('Generated on: ${DateFormat('MMMM dd, yyyy, h:mm a').format(DateTime.now())}'),
            pw.SizedBox(height: 20),
            ...sortedUsers.expand((userName) {
              final reports = userReports[userName]!;
              
              return [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 10),
                  child: pw.Text(
                    'User: $userName',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.Table.fromTextArray(
                  headers: ['SN', 'Book Title', 'Damage Type', 'Reported Date', 'Status'],
                  data: List<List<String>>.generate(reports.length, (index) {
                    final item = reports[index];
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
                pw.SizedBox(height: 20),
              ];
            }).toList(),
          ],
        ),
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/user_wise_damage_reports_${DateTime.now().millisecondsSinceEpoch}.pdf');
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
                  const Expanded(
                    child: Text(
                      'User-wise Damage Reports',
                      style: TextStyle(
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
                    onPressed: () => _generateUserWiseDamageReportsPdf(context),
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
                  'No damage reports found.',
                  style: TextStyle(
                    color: Color(0xFF4A4E69),
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                  ),
                ),
              );
            }

            // Group reports by user
            final Map<String, List<Map<String, dynamic>>> userReports = {};
            for (var doc in snapshot.data!.docs) {
              final reportData = doc.data() as Map<String, dynamic>;
              final userName = reportData['userName'] as String? ?? 'Unknown User';
              
              if (!userReports.containsKey(userName)) {
                userReports[userName] = [];
              }
              userReports[userName]!.add(reportData);
            }
            
            // Sort users alphabetically
            final sortedUsers = userReports.keys.toList()..sort();

            return ListView.builder(
              itemCount: sortedUsers.length,
              itemBuilder: (context, index) {
                final userName = sortedUsers[index];
                final reports = userReports[userName]!;
                
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDamageReportsDetailScreen(userName: userName),
                      ),
                    );
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
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
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                        child: const Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Color(0xFF22223B),
                        ),
                      ),
                      subtitle: Text(
                        '${reports.length} report${reports.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Color(0xFF9A8C98),
                          fontSize: 14,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Color(0xFF9A8C98), size: 18),
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