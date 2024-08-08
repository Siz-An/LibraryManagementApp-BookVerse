import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Received extends StatelessWidget {
  const Received({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Issued Books'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('issuedbooks').orderBy('issuedAt', descending: true).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No books have been issued.'));
          }

          final issuedBooks = snapshot.data!.docs;

          // Group books by issue date
          final groupedBooks = <String, List<Map<String, dynamic>>>{};
          final dateFormat = DateFormat('yyyy-MM-dd'); // Format to display only the date

          for (var doc in issuedBooks) {
            final data = doc.data() as Map<String, dynamic>;
            final issuedAt = (data['issuedAt'] as Timestamp).toDate();
            final dateOnly = dateFormat.format(issuedAt);

            if (!groupedBooks.containsKey(dateOnly)) {
              groupedBooks[dateOnly] = [];
            }
            groupedBooks[dateOnly]!.add(data);
          }

          return ListView(
            children: groupedBooks.entries.map((entry) {
              final issueDate = entry.key;
              final books = entry.value;

              return ExpansionTile(
                title: Text('Issued on $issueDate'),
                children: books.map((book) {
                  return FutureBuilder<String>(
                    future: _fetchAdminUsername(book['adminId']),
                    builder: (context, adminSnapshot) {
                      String adminUsername = 'Unknown Admin';
                      if (adminSnapshot.connectionState == ConnectionState.waiting) {
                        adminUsername = 'Loading...';
                      } else if (adminSnapshot.hasError) {
                        adminUsername = 'Error fetching admin';
                      } else if (adminSnapshot.hasData) {
                        adminUsername = adminSnapshot.data ?? 'Unknown Admin';
                      }

                      return ListTile(
                        leading: book['imageUrl'] != null && book['imageUrl']!.isNotEmpty
                            ? Image.network(book['imageUrl'], width: 50, height: 50, fit: BoxFit.cover)
                            : const Icon(Icons.book),
                        title: Text(book['title'] ?? 'Unknown Title'),
                        subtitle: Text('Issued by $adminUsername'),
                        onTap: () => _showBookDetails(context, book['bookId']),
                      );
                    },
                  );
                }).toList(),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  Future<String> _fetchAdminUsername(String? adminId) async {
    if (adminId == null || adminId.isEmpty) {
      return 'Unknown Admin';
    }

    final adminDoc = FirebaseFirestore.instance.collection('admins').doc(adminId);
    final adminSnapshot = await adminDoc.get();

    if (adminSnapshot.exists) {
      final adminData = adminSnapshot.data() as Map<String, dynamic>;
      return adminData['userName'] as String? ?? 'Unknown Admin';
    } else {
      return 'Admin not found';
    }
  }

  Future<void> _showBookDetails(BuildContext context, String bookId) async {
    final bookDoc = FirebaseFirestore.instance.collection('books').doc(bookId);
    final bookSnapshot = await bookDoc.get();

    if (bookSnapshot.exists) {
      final bookData = bookSnapshot.data() as Map<String, dynamic>;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(bookData['title'] ?? 'Unknown Title'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (bookData['imageUrl'] != null && bookData['imageUrl']!.isNotEmpty)
                Image.network(bookData['imageUrl'], height: 150, fit: BoxFit.cover),
              Text('Author: ${bookData['writer'] ?? 'Unknown'}'),
              Text('Course: ${bookData['course'] ?? 'Unknown'}'),
              Text('Summary: ${bookData['summary'] ?? 'No summary available'}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book details not found.')),
      );
    }
  }
}
