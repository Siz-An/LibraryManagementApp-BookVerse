import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class ReturnHistory extends StatelessWidget {
  const ReturnHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      // Modern AppBar with gradient and rounded corners
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
              padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.history, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Return History',
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
        padding: const EdgeInsets.all(18.0),
        child: FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance.collection('DATA').get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('Error fetching data'));
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No return history found'));
            }

            // Create a list of rows for the DataTable
            List<DataRow> rows = [];

            // Data for PDF generation
            List<Map<String, dynamic>> returnData = [];

            // Iterate over documents to create rows
            for (var doc in snapshot.data!.docs) {
              final data = doc.data() as Map<String, dynamic>;
              final userId = data['UserId'] ?? 'Unknown user';
              final bookName = data['BookName'] ?? 'Unknown book';

              // Handle potential null values for issueDate and returnDate
              final issueDateTimestamp = data['IssueDate'] as Timestamp?;
              final returnDateTimestamp = data['AcceptedDate'] as Timestamp?;

              final issueDate = issueDateTimestamp != null
                  ? DateFormat('yyyy-MM-dd – kk:mm').format(issueDateTimestamp.toDate())
                  : 'Unknown date';
              final returnDate = returnDateTimestamp != null
                  ? DateFormat('yyyy-MM-dd – kk:mm').format(returnDateTimestamp.toDate())
                  : 'Unknown date';

              // Add to returnData for PDF generation
              returnData.add({
                'userId': userId,
                'bookName': bookName,
                'issueDate': issueDate,
                'returnDate': returnDate,
              });

              // FutureBuilder to fetch user details
              rows.add(DataRow(cells: [
                DataCell(FutureBuilder<DocumentSnapshot>(
                  future: FirebaseFirestore.instance.collection('Users').doc(userId).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const Text('Loading...');
                    } else if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const Text('User not found');
                    }

                    final userData = userSnapshot.data!.data() as Map<String, dynamic>;
                    final username = userData['UserName'] ?? 'Unknown';
                    final email = userData['Email'] ?? 'No email';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(username),
                        Text(email, style: const TextStyle(fontSize: 12)),
                      ],
                    );
                  },
                )),
                DataCell(Text(bookName)),
                DataCell(Text(issueDate)),
                DataCell(Text(returnDate)),
              ]));
            }

            return Column(
              children: [
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () => _generatePdf(context, returnData),
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    label: const Text('Download PDF', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4A4E69),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                    child: DataTable(
                      headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xFF9A8C98).withOpacity(0.2)),
                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4A4E69),
                      ),
                      columns: const [
                        DataColumn(label: Text('User')),
                        DataColumn(label: Text('Book Name')),
                        DataColumn(label: Text('Issue Date')),
                        DataColumn(label: Text('Return Date')),
                      ],
                      rows: rows,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context, List<Map<String, dynamic>> returnData) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              'Return History Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['User ID', 'Book Name', 'Issue Date', 'Return Date'],
              data: returnData.map((item) {
                return [
                  item['userId'],
                  item['bookName'],
                  item['issueDate'],
                  item['returnDate'],
                ];
              }).toList(),
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
      final file = File('${dir.path}/return_history.pdf');
      await file.writeAsBytes(await pdf.save());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF generated successfully')),
      );

      // Open the PDF file
      await OpenFile.open(file.path);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e')),
      );
    }
  }
}