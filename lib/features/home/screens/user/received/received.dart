import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Received extends StatelessWidget {
  const Received({super.key});

  @override
  Widget build(BuildContext context) {
    // Get the current user's ID
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Books'),
        ),
        body: Center(
          child: const Text('No user is logged in.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Issued Books Section
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Issued Books',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('issuedBooks')
                          .where('userId', isEqualTo: userId) // Filter by userId
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final issuedBooks = snapshot.data?.docs ?? [];

                        return ListView.builder(
                          itemCount: issuedBooks.length,
                          itemBuilder: (context, index) {
                            final book = issuedBooks[index].data() as Map<String, dynamic>;
                            final docId = issuedBooks[index].id; // Get the document ID

                            // Safely get issued date
                            DateTime? issuedDate = (book['issueDate'] as Timestamp?)?.toDate();
                            String formattedIssuedDate = issuedDate != null
                                ? DateFormat('yyyy-MM-dd – kk:mm').format(issuedDate)
                                : 'N/A';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    book['imageUrl'] ?? 'https://via.placeholder.com/150', // Fallback image
                                    width: 50,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(book['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Author: ${book['writer'] ?? 'Unknown'}'),
                                    Text('Issued Date: $formattedIssuedDate'), // Display formatted date
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.reset_tv_sharp, color: Colors.red),
                                  onPressed: () {
                                    _confirmReturnBook(context, docId, book);
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Rejected Books Section
            Expanded(
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Rejected Books',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('rejectedBooks')
                          .where('userId', isEqualTo: userId) // Filter by userId
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}'));
                        }

                        final rejectedBooks = snapshot.data?.docs ?? [];

                        return ListView.builder(
                          itemCount: rejectedBooks.length,
                          itemBuilder: (context, index) {
                            final book = rejectedBooks[index].data() as Map<String, dynamic>;
                            final docId = rejectedBooks[index].id; // Get the document ID

                            // Safely get rejection date
                            DateTime? rejectionDate = (book['rejectionDate'] as Timestamp?)?.toDate();
                            String formattedRejectionDate = rejectionDate != null
                                ? DateFormat('yyyy-MM-dd – kk:mm').format(rejectionDate)
                                : 'N/A';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              elevation: 4,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8.0),
                                  child: Image.network(
                                    book['imageUrl'] ?? 'https://via.placeholder.com/150', // Fallback image
                                    width: 50,
                                    height: 75,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                title: Text(book['title'] ?? 'No Title', style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Author: ${book['writer'] ?? 'Unknown'}'),
                                    Text('Rejection Date: $formattedRejectionDate'), // Display formatted date
                                    Text('Reason: ${book['rejectionReason'] ?? 'N/A'}'),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: const Icon(Icons.check, color: Colors.green), // OK icon
                                  onPressed: () {
                                    _removeBook(docId); // Remove the book from rejectedBooks
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmReturnBook(BuildContext context, String docId, Map<String, dynamic> data) async {
    final bool? isConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Return Book'),
          content: const Text('Are you sure you want to return this book?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false), // Cancel
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true), // Confirm
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );

    if (isConfirmed == true) {
      final toBeReturnedBooksCollection = FirebaseFirestore.instance.collection('toBeReturnedBooks');
      final issuedBooksCollection = FirebaseFirestore.instance.collection('issuedBooks');

      // Add the book to the 'toBeReturnedBooks' collection with the return date
      await toBeReturnedBooksCollection.add({
        ...data, // Spread the existing book data
        'returnedDate': Timestamp.now(), // Add the current timestamp as the returned date
      });

      // Remove the book from the 'issuedBooks' collection
      await issuedBooksCollection.doc(docId).delete();
    }
  }

  Future<void> _removeBook(String docId) async {
    final rejectedBooksCollection = FirebaseFirestore.instance.collection('rejectedBooks');

    // Remove the rejected book document from Firestore
    await rejectedBooksCollection.doc(docId).delete();
  }
}
