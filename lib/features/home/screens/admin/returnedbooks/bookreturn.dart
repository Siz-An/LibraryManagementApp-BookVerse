import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AcceptReturnedBooksScreen extends StatelessWidget {
  const AcceptReturnedBooksScreen({super.key});

  // Function to handle accepting a book return
  Future<void> _acceptReturn(String docId, String bookId) async {
    final toBeReturnedBooksCollection = FirebaseFirestore.instance.collection('toBeReturnedBooks');
    final booksCollection = FirebaseFirestore.instance.collection('books');

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
    } catch (e) {
      print("Error accepting return and updating copies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    // DateFormat instance to format dates
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accept Returned Books'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'BOOKS TO ACCEPT RETURN:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.8, // Adjust height as needed
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('toBeReturnedBooks').snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('No books to accept.'));
                    }

                    return ListView(
                      children: snapshot.data!.docs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final docId = doc.id; // Get the document ID for accepting
                        final bookId = data["bookId"] as String; // Get the book ID

                        // Check if the issueDate and requestedReturnDate fields are not null
                        final issueDate = data["issueDate"] != null
                            ? (data["issueDate"] as Timestamp).toDate()
                            : null;
                        final requestedReturnDate = data["requestedReturnDate"] != null
                            ? (data["requestedReturnDate"] as Timestamp).toDate()
                            : null;

                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.network(
                                data["imageUrl"] as String,
                                width: 100,
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data["title"] as String,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    Text('Writer: ${data["writer"] as String}'),
                                    if (issueDate != null)
                                      Text('Issue Date: ${dateFormat.format(issueDate)}'),
                                    if (requestedReturnDate != null)
                                      Text('Requested Return Date: ${dateFormat.format(requestedReturnDate)}'),
                                    Text('Book ID: $bookId'), // Display Book ID
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.check_circle, color: Colors.green),
                                onPressed: () {
                                  // Show a confirmation dialog before accepting the book return
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
                                            // Accept the book return and update the number of copies
                                            _acceptReturn(docId, bookId);
                                            Navigator.of(context).pop(); // Close the dialog
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
