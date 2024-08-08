import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../utils/constants/sizes.dart';

class Received extends StatefulWidget {
  const Received({super.key});

  @override
  _CombinedBooksState createState() => _CombinedBooksState();
}

class _CombinedBooksState extends State<Received> {
  late Future<List<QueryDocumentSnapshot>> _issuedBooksFuture;
  late Future<List<QueryDocumentSnapshot>> _rejectedBooksFuture;

  @override
  void initState() {
    super.initState();
    _fetchIssuedBooks();
    _fetchRejectedBooks();
  }

  void _fetchIssuedBooks() {
    _issuedBooksFuture = FirebaseFirestore.instance
        .collection('issuedbooks')
        .orderBy('issuedAt', descending: true)
        .get()
        .then((snapshot) => snapshot.docs);
  }

  void _fetchRejectedBooks() {
    _rejectedBooksFuture = FirebaseFirestore.instance
        .collection('deniedbooks')
        .get()
        .then((snapshot) => snapshot.docs);
  }

  Future<void> _showReturnDialog(BuildContext context, Map<String, dynamic> book) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Return'),
          content: Text('Are you sure you want to return the book "${book['title']}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _returnBook(book);
              },
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _returnBook(Map<String, dynamic> book) async {
    try {
      // Add the book to the returnbooks collection
      await FirebaseFirestore.instance.collection('returnbooks').add({
        'title': book['title'],
        'writer': book['writer'],
        'imageUrl': book['imageUrl'],
        'course': book['course'],
        'summary': book['summary'],
        'bookId': book['bookId'],
        'returnedAt': FieldValue.serverTimestamp(),
      });

      // Remove the book from the issuedbooks collection
      await FirebaseFirestore.instance.collection('issuedbooks').doc(book['bookId']).delete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Book "${book['title']}" has been returned.')),
      );

      // Refresh the list of issued books
      setState(() {
        _fetchIssuedBooks();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error returning book: $e')),
      );
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Heading for Issued Books
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Issued Books',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Issued Books Section
            FutureBuilder<List<QueryDocumentSnapshot>>(
              future: _issuedBooksFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No books have been issued.'));
                }

                final issuedBooks = snapshot.data!;

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

                return Column(
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
                              trailing: IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.blue),
                                onPressed: () => _showReturnDialog(context, book),
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
            SizedBox(height: TSizes.spaceBtwSections),

            // Heading for Rejected Books
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Rejected Books',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            // Rejected Books Section
            FutureBuilder<List<QueryDocumentSnapshot>>(
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
                                icon: const Icon(Icons.check, color: Colors.red),
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
          ],
        ),
      ),
    );
  }
}
