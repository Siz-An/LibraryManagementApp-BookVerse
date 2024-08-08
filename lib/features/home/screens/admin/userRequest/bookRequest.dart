import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../../../common/widgets/appbar/appbar.dart';

class UserRequestsScreen extends StatefulWidget {
  @override
  _UserRequestsScreenState createState() => _UserRequestsScreenState();
}

class _UserRequestsScreenState extends State<UserRequestsScreen> {
  final _commentController = TextEditingController();

  Future<void> _acceptAllRequests(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;

    final requestsSnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .get();

    for (var request in requestsSnapshot.docs) {
      final books = List<Map<String, dynamic>>.from(request['books']);

      for (var book in books) {
        await _acceptBook(context, request.id, book);
      }

      await request.reference.delete();
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('All requests have been accepted.')),
    );
  }

  Future<void> _denyAllRequests(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userId = user.uid;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Provide a comment for denying all requests'),
          content: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: 'Enter reason for denial',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final comment = _commentController.text;

                final requestsSnapshot = await FirebaseFirestore.instance
                    .collection('requests')
                    .where('userId', isEqualTo: userId)
                    .get();

                for (var request in requestsSnapshot.docs) {
                  final books = List<Map<String, dynamic>>.from(request['books']);

                  for (var book in books) {
                    await _denyBook(context, request.id, book, comment);
                  }

                  await request.reference.delete();
                }

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('All requests have been denied with comment: "$comment"')),
                );
                _commentController.clear();
              },
              child: Text('Submit'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _acceptBook(BuildContext context, String requestId, Map<String, dynamic> book) async {
    final bookTitle = book['title'];
    final bookId = book['bookId']; // Use bookId for identifying the book in the 'books' collection

    final admin = FirebaseAuth.instance.currentUser;
    if (admin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Admin user not logged in.')),
      );
      return;
    }
    final adminId = admin.uid; // Admin user ID

    try {
      // Fetch the userId from the request document
      final requestDoc = FirebaseFirestore.instance.collection('requests').doc(requestId);
      final requestSnapshot = await requestDoc.get();
      final userId = requestSnapshot['userId'];

      // Check if the book is already issued
      final issuedBooksSnapshot = await FirebaseFirestore.instance
          .collection('issuedbooks')
          .where('bookId', isEqualTo: bookId)
          .get();

      if (issuedBooksSnapshot.docs.isEmpty) {
        // Book is not already issued, proceed with issuing and updating copies
        // Add the book to the issuedbooks collection with complete details
        await FirebaseFirestore.instance.collection('issuedbooks').add({
          'title': book['title'],
          'writer': book['writer'],
          'imageUrl': book['imageUrl'],
          'course': book['course'],
          'summary': book['summary'],
          'bookId': bookId,
          'userId': userId, // Add the userId of the requester
          'adminId': adminId, // Optionally add the adminId
          'issuedAt': FieldValue.serverTimestamp(),
        });

        // Proceed with decreasing the number of copies in the books collection
        final bookDoc = FirebaseFirestore.instance.collection('books').doc(bookId);
        final bookSnapshot = await bookDoc.get();

        if (bookSnapshot.exists) {
          final numberOfCopies = bookSnapshot.data()?['numberOfCopies'] ?? 0;

          if (numberOfCopies > 0) {
            // Decrease the number of copies by 1
            await bookDoc.update({
              'numberOfCopies': numberOfCopies - 1,
            });
          }
        }

        // Update or delete the request document
        final books = List<Map<String, dynamic>>.from(requestSnapshot['books']);
        books.removeWhere((b) => b['title'] == bookTitle);

        if (books.isEmpty) {
          await requestDoc.delete();
        } else {
          await requestDoc.update({'books': books});
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Book "$bookTitle" has been accepted and updated.')),
        );
      } else {
        // Book is already issued
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('The book "$bookTitle" is already issued.')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept book: $error')),
      );
    }
  }

  Future<void> _denyBook(BuildContext context, String requestId, Map<String, dynamic> book, String comment) async {
    final deniedBook = {
      'book': book,
      'comment': comment,
      'timestamp': Timestamp.now(),
    };

    await FirebaseFirestore.instance.collection('deniedbooks').add(deniedBook);

    final requestDoc = FirebaseFirestore.instance.collection('requests').doc(requestId);
    final requestSnapshot = await requestDoc.get();
    final books = List<Map<String, dynamic>>.from(requestSnapshot['books']);

    books.removeWhere((b) => b['title'] == book['title']);

    if (books.isEmpty) {
      await requestDoc.delete();
    } else {
      await requestDoc.update({'books': books});
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return Scaffold(
        appBar: TAppBar(
          title: const Text('Requested Books'),
          showBackArrow: true,
        ),
        body: const Center(child: Text('User not logged in.')),
      );
    }
    final userId = user.uid;

    return Scaffold(
      appBar: TAppBar(
        title: const Text('Requested Books'),
        showBackArrow: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('requests')
                  .where('userId', isEqualTo: userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No requests found.'));
                }

                final requests = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    final books = List<Map<String, dynamic>>.from(request['books']);

                    return ExpansionTile(
                      title: Text(
                        'Request ${index + 1}',
                        style: TextStyle(color: Colors.blueGrey[700]),
                      ),
                      children: books.map((book) {
                        return ListTile(
                          title: Text(book['title']),
                          subtitle: Text('Author: ${book['writer']}'),
                          leading: book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                              ? Image.network(
                            book['imageUrl'],
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.book);
                            },
                          )
                              : const Icon(Icons.book),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check, color: Colors.green),
                                onPressed: () => _acceptBook(context, request.id, book),
                              ),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('Provide a comment'),
                                        content: TextField(
                                          controller: _commentController,
                                          decoration: InputDecoration(
                                            hintText: 'Enter reason for denial',
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                              _denyBook(context, request.id, book, _commentController.text);
                                              _commentController.clear();
                                            },
                                            child: Text('Submit'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () => _acceptAllRequests(context),
                  child: const Text('Accept All'),
                ),
                ElevatedButton(
                  onPressed: () => _denyAllRequests(context),
                  child: const Text('Deny All'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}