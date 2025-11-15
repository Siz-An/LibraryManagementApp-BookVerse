import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';

class IssuedBooksPage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String userPhoneNumber;

  const IssuedBooksPage({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userPhoneNumber,
  });

  @override
  Widget build(BuildContext context) {
    // Ensure userName and userEmail are not null or empty
    if (userName.isEmpty || userEmail.isEmpty) {
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
                    const Icon(Icons.error, color: Colors.white, size: 32),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text(
                        'Issued Books',
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
        body: const Center(child: Text('Invalid user details provided.')),
      );
    }

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
                  const Icon(Icons.menu_book, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Issued Books for $userName',
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
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Info Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22223B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Name: $userName',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A4E69),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Email: $userEmail',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A4E69),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Phone: $userPhoneNumber',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF4A4E69),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Download Button
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _generatePdf(context, userName, userEmail, userPhoneNumber),
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
            
            // Data Table
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('DATA')
                    .where('UserName', isEqualTo: userName)
                    .where('Email', isEqualTo: userEmail)
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
                          Icon(Icons.menu_book_outlined, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'No issued books data',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  final data = snapshot.data!.docs;

                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 20.0,
                      border: TableBorder.all(color: Colors.grey, width: 1.0),
                      headingRowColor: MaterialStateColor.resolveWith(
                          (states) => const Color(0xFF9A8C98).withOpacity(0.2)),
                      headingTextStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF22223B),
                      ),
                      dataRowColor: MaterialStateColor.resolveWith((states) => Colors.white),
                      columns: const [
                        DataColumn(label: Text('SN', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Book Name', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Issue Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Return Date', style: TextStyle(fontWeight: FontWeight.bold))),
                        DataColumn(label: Text('Remarks', style: TextStyle(fontWeight: FontWeight.bold))),
                      ],
                      rows: List<DataRow>.generate(
                        data.length,
                        (index) {
                          final item = data[index].data() as Map<String, dynamic>;
                          final bookName = item['BookName'] as String? ?? 'Unknown';
                          final issueDate = item["IssueDate"] != null
                              ? (item["IssueDate"] as Timestamp).toDate()
                              : null;
                          final returnDate = item["AcceptedDate"] != null
                              ? (item["AcceptedDate"] as Timestamp).toDate()
                              : null;

                          return DataRow(
                            cells: [
                              DataCell(Text('${index + 1}')),
                              DataCell(Text(bookName)),
                              DataCell(Text(issueDate != null
                                  ? DateFormat('dd MMMM yyyy').format(issueDate)
                                  : 'N/A')),
                              DataCell(Text(returnDate != null
                                  ? DateFormat('dd MMMM yyyy').format(returnDate)
                                  : 'N/A')),
                              DataCell(Text(userName)), // Remarks
                            ],
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePdf(BuildContext context, String userName, String userEmail, String userPhoneNumber) async {
    final pdf = pw.Document();

    // Fetch data for PDF
    final querySnapshot = await FirebaseFirestore.instance
        .collection('DATA')
        .where('UserName', isEqualTo: userName)
        .where('Email', isEqualTo: userEmail)
        .get();

    final List<Map<String, dynamic>> bookData = [];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      bookData.add(data);
    }

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          children: [
            pw.Text(
              'Issued Books Report',
              style: pw.TextStyle(
                fontSize: 24,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('User Information:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 5),
                  pw.Text('Name: $userName'),
                  pw.Text('Email: $userEmail'),
                  pw.Text('Phone: $userPhoneNumber'),
                ],
              ),
            ),
            pw.SizedBox(height: 20),
            pw.Table.fromTextArray(
              headers: ['SN', 'Book Name', 'Issue Date', 'Return Date', 'Remarks'],
              data: List<List<String>>.generate(bookData.length, (index) {
                final item = bookData[index];
                final bookName = item['BookName'] as String? ?? 'Unknown';
                final issueDate = item["IssueDate"] != null
                    ? DateFormat('dd MMMM yyyy').format((item["IssueDate"] as Timestamp).toDate())
                    : 'N/A';
                final returnDate = item["AcceptedDate"] != null
                    ? DateFormat('dd MMMM yyyy').format((item["AcceptedDate"] as Timestamp).toDate())
                    : 'N/A';

                return [
                  '${index + 1}',
                  bookName,
                  issueDate,
                  returnDate,
                  userName,
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
      final file = File('${dir.path}/issued_books_$userName.pdf');
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