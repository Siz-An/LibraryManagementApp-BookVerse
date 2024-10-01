import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class ReturnHistory extends StatelessWidget {
  const ReturnHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return History'),
      ),
      body: FutureBuilder<QuerySnapshot>(
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

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal, // Enable horizontal scrolling
            child: DataTable(
              columns: const [
                DataColumn(label: Text('User')),
                DataColumn(label: Text('Book Name')),
                DataColumn(label: Text('Issue Date')),
                DataColumn(label: Text('Return Date')),
              ],
              rows: rows,
            ),
          );
        },
      ),
    );
  }
}
