import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IssuedBooksPage extends StatelessWidget {
  const IssuedBooksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issued Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('DATA').snapshots(),
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
            scrollDirection: Axis.horizontal, // Allow horizontal scrolling
            child: DataTable(
              columnSpacing: 16.0,
              columns: const [
                DataColumn(label: Text('Sn')),
                DataColumn(label: Text('Bookname')),
                DataColumn(label: Text('Issue Date')),
                DataColumn(label: Text('Return Date')),
                DataColumn(label: Text('Remarks')),
              ],
              rows: List<DataRow>.generate(
                data.length,
                    (index) {
                  final item = data[index].data() as Map<String, dynamic>;

                  final bookName = item['bookName'] as String? ?? 'Unknown';
                  final issueDate = item["issueDate"] != null
                      ? (item["issueDate"] as Timestamp).toDate()
                      : null;
                  final returnDate = item["acceptedDate"] != null
                      ? (item["acceptedDate"] as Timestamp).toDate()
                      : null;

                  return DataRow(
                    cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(bookName)),
                      DataCell(Text(issueDate != null ? DateFormat('dd MMMM yyyy').format(issueDate) : 'N/A')),
                      DataCell(Text(returnDate != null ? DateFormat('dd MMMM yyyy').format(returnDate) : 'N/A')),
                      DataCell(Text('')), // Empty cell for remarks
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
