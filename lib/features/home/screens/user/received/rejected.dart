import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TRejectedBooks extends StatefulWidget {
  const TRejectedBooks({super.key});

  @override
  _RejectedBooksState createState() => _RejectedBooksState();
}

class _RejectedBooksState extends State<TRejectedBooks> {
  late Future<List<QueryDocumentSnapshot>> _rejectedBooksFuture;

  @override
  void initState() {
    super.initState();
    _fetchRejectedBooks();
  }

  void _fetchRejectedBooks() {
    _rejectedBooksFuture = FirebaseFirestore.instance.collection('deniedbooks').get().then(
          (snapshot) => snapshot.docs,
    );
  }

  void _removeRejectedBook(String docId) async {
    try {
      await FirebaseFirestore.instance.collection('deniedbooks').doc(docId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book removed from rejected list.')),
      );
      setState(() {
        _fetchRejectedBooks(); // Refresh the list by fetching the data again
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rejected Books'),
      ),
      body: SingleChildScrollView(
        child: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: _rejectedBooksFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No books have been rejected.'));
            }

            final rejectedBooks = snapshot.data!;

            // Group books by rejection date
            final groupedBooks = <String, List<Map<String, dynamic>>>{};
            final dateFormat = DateFormat('yyyy-MM-dd'); // Format to display only the date

            for (var doc in rejectedBooks) {
              final data = doc.data() as Map<String, dynamic>;
              final bookData = data['book'] as Map<String, dynamic>?;
              final rejectedAt = (data['timestamp'] as Timestamp?)?.toDate();

              if (bookData == null || rejectedAt == null) {
                continue; // Skip documents without valid book data or timestamp
              }

              final dateOnly = dateFormat.format(rejectedAt);

              if (!groupedBooks.containsKey(dateOnly)) {
                groupedBooks[dateOnly] = [];
              }
              groupedBooks[dateOnly]!.add({
                ...bookData,
                'docId': doc.id, // Add the document ID to the book data
                'comment': data['comment'], // Add comment to book data
                'timestamp': rejectedAt,
              });
            }

            return Column(
              children: groupedBooks.entries.map((entry) {
                final rejectionDate = entry.key;
                final books = entry.value;

                return ExpansionTile(
                  title: Text('Rejected on $rejectionDate'),
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
                          subtitle: Text('Rejected by $adminUsername\nComment: ${book['comment'] ?? 'No comment'}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeRejectedBook(book['docId']),
                          ),
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
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (bookData['imageUrl'] != null && bookData['imageUrl']!.isNotEmpty)
                  Image.network(bookData['imageUrl'], height: 150, fit: BoxFit.cover),
                SizedBox(height: 10), // Add some spacing between the image and text
                Text('Author: ${bookData['writer'] ?? 'Unknown'}'),
                Text('Course: ${bookData['course'] ?? 'Unknown'}'),
                Text('Summary: ${bookData['summary'] ?? 'No summary available'}'),
              ],
            ),
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
