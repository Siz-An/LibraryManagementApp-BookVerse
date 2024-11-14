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
        appBar: AppBar(
          title: const Text('Books'),
        ),
        body: const Center(
          child: Text('No user is logged in.', style: TextStyle(fontSize: 18)),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Issued Books',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('issuedBooks')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 16, color: Colors.red)));
                        }

                        final issuedBooks = snapshot.data?.docs ?? [];

                        return ListView.builder(
                          itemCount: issuedBooks.length,
                          itemBuilder: (context, index) {
                            final book = issuedBooks[index].data() as Map<String, dynamic>;
                            final docId = issuedBooks[index].id;
                            DateTime? issuedDate = (book['issueDate'] as Timestamp?)?.toDate();
                            String formattedIssuedDate = issuedDate != null
                                ? DateFormat('yyyy-MM-dd – kk:mm').format(issuedDate)
                                : 'N/A';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.grey, width: 0.5),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      book['imageUrl'] ?? 'https://via.placeholder.com/150',
                                      width: 50,
                                      height: 75,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    book['title'] ?? 'No Title',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Author: ${book['writer'] ?? 'Unknown'}'),
                                      Text('Issued Date: $formattedIssuedDate'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.restore_from_trash, color: Colors.red),
                                    onPressed: () {
                                      _confirmReturnBook(context, docId, book);
                                    },
                                  ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      'Rejected Books',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('rejectedBooks')
                          .where('userId', isEqualTo: userId)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        if (snapshot.hasError) {
                          return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(fontSize: 16, color: Colors.red)));
                        }

                        final rejectedBooks = snapshot.data?.docs ?? [];

                        return ListView.builder(
                          itemCount: rejectedBooks.length,
                          itemBuilder: (context, index) {
                            final book = rejectedBooks[index].data() as Map<String, dynamic>;
                            final docId = rejectedBooks[index].id;
                            DateTime? rejectionDate = (book['rejectionDate'] as Timestamp?)?.toDate();
                            String formattedRejectionDate = rejectionDate != null
                                ? DateFormat('yyyy-MM-dd – kk:mm').format(rejectionDate)
                                : 'N/A';

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: Colors.grey, width: 0.5),
                              ),
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Image.network(
                                      book['imageUrl'] ?? 'https://via.placeholder.com/150',
                                      width: 50,
                                      height: 75,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  title: Text(
                                    book['title'] ?? 'No Title',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Author: ${book['writer'] ?? 'Unknown'}'),
                                      Text('Rejection Date: $formattedRejectionDate'),
                                      Text('Reason: ${book['rejectionReason'] ?? 'N/A'}'),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.check_circle, color: Colors.green),
                                    onPressed: () {
                                      _removeBook(docId);
                                    },
                                  ),
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

  Future<void> _removeBook(String docId) async {
    final rejectedBooksCollection = FirebaseFirestore.instance.collection('rejectedBooks');
    await rejectedBooksCollection.doc(docId).delete();
  }
}
