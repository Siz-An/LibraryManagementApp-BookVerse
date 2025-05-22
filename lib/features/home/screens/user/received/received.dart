import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Received extends StatelessWidget {
  const Received({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: _ModernAppBar(),
        body: const Center(
          child: Text('No user is logged in.', style: TextStyle(fontSize: 18)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _ModernAppBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: ListView(
          children: [
            const SizedBox(height: 12),
            Text(
              'Issued Books',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF22223B),
              ),
            ),
            const SizedBox(height: 10),
            _ModernIssuedBooksList(userId: userId, onReturn: (context, docId, book) => _confirmReturnBook(context, docId, book)),
            const SizedBox(height: 28),
            Text(
              'Rejected Books',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF4A4E69),
              ),
            ),
            const SizedBox(height: 10),
            _ModernRejectedBooksList(userId: userId, onRemove: (docId) => _removeBook(docId)),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _ModernAppBar() {
    return PreferredSize(
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
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.library_books, color: Colors.white, size: 32),
                SizedBox(width: 14),
                Expanded(
                  child: Text(
                    'Your Books',
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
    );
  }

  static Future<void> _confirmReturnBook(BuildContext context, String docId, Map<String, dynamic> data) async {
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return Book'),
          content: const Text('Are you sure you want to return this book?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      final toBeReturnedBooksCollection = FirebaseFirestore.instance.collection('toBeReturnedBooks');
      final issuedBooksCollection = FirebaseFirestore.instance.collection('issuedBooks');

      await toBeReturnedBooksCollection.add({
        ...data,
        'returnedDate': Timestamp.now(),
      });

      await issuedBooksCollection.doc(docId).delete();
    }
  }

  static Future<void> _removeBook(String docId) async {
    final rejectedBooksCollection = FirebaseFirestore.instance.collection('rejectedBooks');
    await rejectedBooksCollection.doc(docId).delete();
  }
}

class _ModernIssuedBooksList extends StatelessWidget {
  final String userId;
  final void Function(BuildContext, String, Map<String, dynamic>) onReturn;

  const _ModernIssuedBooksList({
    required this.userId,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('issuedBooks')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 16, color: Colors.red)));
        }

        final issuedBooks = snapshot.data?.docs ?? [];
        if (issuedBooks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('No issued books found.', style: TextStyle(fontSize: 16, color: Colors.grey))),
          );
        }

        return Column(
          children: issuedBooks.map((doc) {
            final book = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            DateTime? issuedDate = (book['issueDate'] as Timestamp?)?.toDate();
            String formattedIssuedDate = issuedDate != null
                ? DateFormat('yyyy-MM-dd – kk:mm').format(issuedDate)
                : 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 5,
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    book['imageUrl'] ?? 'https://via.placeholder.com/150',
                    width: 54,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  book['title'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF22223B)),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Author: ${book['writer'] ?? 'Unknown'}', style: const TextStyle(fontSize: 14, color: Color(0xFF4A4E69))),
                    Text('Issued Date: $formattedIssuedDate', style: const TextStyle(fontSize: 13, color: Color(0xFF9A8C98))),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.restore_from_trash, color: Color(0xFFE07A5F), size: 28),
                  tooltip: 'Return Book',
                  onPressed: () => onReturn(context, docId, book),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

class _ModernRejectedBooksList extends StatelessWidget {
  final String userId;
  final void Function(String) onRemove;

  const _ModernRejectedBooksList({
    required this.userId,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('rejectedBooks')
          .where('userId', isEqualTo: userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24.0),
            child: CircularProgressIndicator(),
          ));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}', style: const TextStyle(fontSize: 16, color: Colors.red)));
        }

        final rejectedBooks = snapshot.data?.docs ?? [];
        if (rejectedBooks.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(child: Text('No rejected books found.', style: TextStyle(fontSize: 16, color: Colors.grey))),
          );
        }

        return Column(
          children: rejectedBooks.map((doc) {
            final book = doc.data() as Map<String, dynamic>;
            final docId = doc.id;
            DateTime? rejectionDate = (book['rejectionDate'] as Timestamp?)?.toDate();
            String formattedRejectionDate = rejectionDate != null
                ? DateFormat('yyyy-MM-dd – kk:mm').format(rejectionDate)
                : 'N/A';

            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 5,
              color: Colors.white,
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: Image.network(
                    book['imageUrl'] ?? 'https://via.placeholder.com/150',
                    width: 54,
                    height: 78,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(
                  book['title'] ?? 'No Title',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Color(0xFF22223B)),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Author: ${book['writer'] ?? 'Unknown'}', style: const TextStyle(fontSize: 14, color: Color(0xFF4A4E69))),
                    Text('Rejection Date: $formattedRejectionDate', style: const TextStyle(fontSize: 13, color: Color(0xFF9A8C98))),
                    Text('Reason: ${book['rejectionReason'] ?? 'N/A'}', style: const TextStyle(fontSize: 13, color: Color(0xFFE07A5F))),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.check_circle, color: Color(0xFF81B29A), size: 28),
                  tooltip: 'Remove',
                  onPressed: () => onRemove(docId),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
