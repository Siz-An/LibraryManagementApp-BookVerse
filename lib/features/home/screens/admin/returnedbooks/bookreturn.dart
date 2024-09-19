import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AcceptReturnedBooksScreen extends StatelessWidget {
  final String userId;

  const AcceptReturnedBooksScreen({required this.userId, super.key});

  // Function to handle accepting a book return and storing data in "DATA" collection
  Future<void> _acceptReturn(String docId, String bookId, Map<String, dynamic> bookData) async {
    final toBeReturnedBooksCollection = FirebaseFirestore.instance.collection('toBeReturnedBooks');
    final booksCollection = FirebaseFirestore.instance.collection('books');
    final usersCollection = FirebaseFirestore.instance.collection('Users');
    final dataCollection = FirebaseFirestore.instance.collection('DATA');

    try {
      // Remove the book from 'toBeReturnedBooks'
      await toBeReturnedBooksCollection.doc(docId).delete();

      // Increment the 'numberOfCopies' in the 'books' collection for the returned book
      final bookDoc = booksCollection.doc(bookId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(bookDoc);
        if (snapshot.exists) {
          final currentCopies = snapshot.get('numberOfCopies') as int;
          transaction.update(bookDoc, {'numberOfCopies': currentCopies + 1});
        }
      });

      // Get user details from 'Users' collection
      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;

        // Prepare data for 'DATA' collection
        final acceptedDate = DateTime.now();
        await dataCollection.add({
          'UserId': userId, // Insert userId here
          'UserName': userData['UserName'],
          'Email': userData['Email'],
          'PhoneNumber': userData['PhoneNumber'],
          'Image': bookData['imageUrl'],
          'BookName': bookData['title'],
          'IssueDate': bookData['issueDate'],
          'AcceptedDate': acceptedDate,
        });

        print('Book return accepted and data stored successfully.');
      } else {
        print('User not found.');
      }
    } catch (e) {
      print("Error accepting return and updating copies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Books to be Returned'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('toBeReturnedBooks')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No books to accept for return.'));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final data = books[index].data() as Map<String, dynamic>;
              final docId = books[index].id;
              final bookId = data['bookId'] as String;

              final issueDate = data["issueDate"] != null
                  ? (data["issueDate"] as Timestamp).toDate()
                  : null;
              final requestedReturnDate = data["requestedReturnDate"] != null
                  ? (data["requestedReturnDate"] as Timestamp).toDate()
                  : null;
              final returnDate = data["returnDate"] != null
                  ? (data["returnDate"] as Timestamp).toDate()
                  : null;

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Book cover image
                      if (data["imageUrl"] != null)
                        Image.network(
                          data["imageUrl"] as String,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        )
                      else
                        const SizedBox(
                          width: 80,
                          height: 120,
                          child: Placeholder(),
                        ),
                      const SizedBox(width: 10),
                      // Book details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['title'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text('Writer: ${data["writer"] as String}'),
                            if (issueDate != null)
                              Text('Issue Date: ${dateFormat.format(issueDate)}'),
                            if (requestedReturnDate != null)
                              Text('Requested Return Date: ${dateFormat.format(requestedReturnDate)}'),
                            if (returnDate != null)
                              Text(
                                'Return Date: ${dateFormat.format(returnDate)}',
                                style: const TextStyle(color: Colors.red),
                              )
                            else
                              const Text(
                                'Return Date: Not yet returned',
                                style: TextStyle(color: Colors.grey),
                              ),
                          ],
                        ),
                      ),
                      // Accept button
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () {
                          // Confirm return
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Accept Book Return'),
                              content: const Text('Are you sure you want to accept this returned book?'),
                              actions: [
                                TextButton(
                                  child: const Text('Cancel'),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                                TextButton(
                                  child: const Text('OK'),
                                  onPressed: () {
                                    _acceptReturn(docId, bookId, data);
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
