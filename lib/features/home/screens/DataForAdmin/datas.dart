import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IssuedBooksPage extends StatelessWidget {
  final String userName;
  final String userEmail;

  final userPhoneNumber;

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
        appBar: AppBar(title: const Text('Issued Books')),
        body: const Center(child: Text('Invalid user details provided.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Issued Books for $userName'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
            return const Center(child: Text('No issued books data.'));
          }

          final data = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 20.0,
              border: TableBorder.all(color: Colors.grey, width: 1.0),
              headingRowColor: MaterialStateColor.resolveWith(
                      (states) => Colors.blueGrey[100]!),
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
    );
  }
}
