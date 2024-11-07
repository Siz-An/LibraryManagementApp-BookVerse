import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequestedBooksScreen extends StatelessWidget {
  final String userId;
  final String adminId;

  const UserRequestedBooksScreen({required this.userId, required this.adminId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requested Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: userId) // Ensures only books requested by this user
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No requested books found.'));
          }

          final requests = snapshot.data!.docs;
          List<Map<String, dynamic>> books = [];

          // Collect all the books from the requests for this user
          for (var request in requests) {
            List<Map<String, dynamic>> requestBooks = List<Map<String, dynamic>>.from(request['books']);
            books.addAll(requestBooks);
          }

          if (books.isEmpty) {
            return const Center(child: Text('No books requested.'));
          }

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];

              return ListTile(
                title: Text(book['title']),
                subtitle: Text('Author: ${book['writer']}'),
                leading: book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                    ? Image.network(
                  book['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : const Icon(Icons.book),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Accept Button
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => acceptBook(context, book, requests, adminId),
                    ),
                    // Reject Button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => rejectBook(context, book, requests, adminId),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // Function to accept the book and issue it to the specific user (not to all users)
  void acceptBook(BuildContext context, Map<String, dynamic> book, List<DocumentSnapshot> requests, String adminId) async {
    final bookId = book['bookId'];
    final specificUserId = userId; // Ensure the book is issued only to the user who requested it

    // Check if the book exists in the 'books' collection and has copies left
    final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
    if (bookDoc.exists) {
      final bookData = bookDoc.data() as Map<String, dynamic>;
      final int numberOfCopies = bookData['numberOfCopies'];

      if (numberOfCopies > 0) {
        // Issue the book by adding it to the 'issuedBooks' collection for this specific user
        await FirebaseFirestore.instance.collection('issuedBooks').add({
          'userId': specificUserId, // Only issue the book to this specific user
          'adminId': adminId,
          'bookId': bookId,
          'title': book['title'],
          'writer': book['writer'],
          'imageUrl': book['imageUrl'],
          'issueDate': Timestamp.now(),
          'isRead': false, // Default isRead value
        });

        // Decrease the number of copies by 1
        await FirebaseFirestore.instance.collection('books').doc(bookId).update({
          'numberOfCopies': numberOfCopies - 1,
        });

        // Remove the book from this user's requests collection
        await removeBookFromRequests(book, requests);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book accepted, issued, and number of copies updated!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No more copies available for this book.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Book not found in the database.')),
      );
    }
  }

  // Function to reject the book and add a comment with adminId
  void rejectBook(BuildContext context, Map<String, dynamic> book, List<DocumentSnapshot> requests, String adminId) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController reasonController = TextEditingController();

        return AlertDialog(
          title: const Text('Reject Book'),
          content: TextField(
            controller: reasonController,
            decoration: const InputDecoration(
              labelText: 'Reason for rejection',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (reasonController.text.isNotEmpty) {
                  // Add the rejection reason to the rejectedBooks collection with the specific user
                  await FirebaseFirestore.instance.collection('rejectedBooks').add({
                    'userId': userId, // Rejecting only for this user
                    'adminId': adminId, // The admin who rejected the book
                    'bookId': book['bookId'], // Adding bookId to the rejectedBooks collection
                    'title': book['title'],
                    'writer': book['writer'],
                    'imageUrl': book['imageUrl'],
                    'rejectionReason': reasonController.text,
                    'rejectionDate': Timestamp.now(), // Store the current time as rejection date
                  });

                  // Remove the book from this user's requests collection
                  await removeBookFromRequests(book, requests);

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Book rejected and reason saved!')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please provide a rejection reason.')),
                  );
                }
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );
  }

  // Function to remove a book from the requests collection for a specific user
  Future<void> removeBookFromRequests(Map<String, dynamic> book, List<DocumentSnapshot> requests) async {
    for (var request in requests) {
      List<Map<String, dynamic>> requestBooks = List<Map<String, dynamic>>.from(request['books']);

      // Check if the book exists in this request
      requestBooks.removeWhere((b) => b['bookId'] == book['bookId']); // Match based on bookId

      if (requestBooks.isEmpty) {
        // If no books remain in the request, delete the request document
        await FirebaseFirestore.instance.collection('requests').doc(request.id).delete();
      } else {
        // Otherwise, update the request document with the remaining books
        await FirebaseFirestore.instance.collection('requests').doc(request.id).update({
          'books': requestBooks,
        });
      }
    }
  }

  // Function to mark a book as read
  void markBookAsRead(BuildContext context, String issuedBookId) async {
    final issuedBookRef = FirebaseFirestore.instance.collection('issuedBooks').doc(issuedBookId);

    await issuedBookRef.update({
      'isRead': true,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Book marked as read!')),
    );
  }
}
