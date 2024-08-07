import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class RequestedListScreen extends StatelessWidget {
  const RequestedListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return const Center(child: Text('User not logged in'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Requested Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
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
              final requestId = request.id; // Get the request document ID
              final books = List<Map<String, dynamic>>.from(request['books']);

              return ExpansionTile(
                title: Text('Request ${index + 1}'),
                children: [
                  Column(
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
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteBookFromRequest(context, requestId, book['title']),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _deleteBookFromRequest(BuildContext context, String requestId, String bookTitle) async {
    try {
      final requestRef = FirebaseFirestore.instance.collection('requests').doc(requestId);

      // Fetch the request document to update it
      final requestDoc = await requestRef.get();
      final books = List<Map<String, dynamic>>.from(requestDoc['books']);

      // Remove the book from the list
      books.removeWhere((book) => book['title'] == bookTitle);

      if (books.isEmpty) {
        // If there are no books left in the request, delete the entire request
        await requestRef.delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request deleted as no books remain')),
        );
      } else {
        // Otherwise, update the request document
        await requestRef.update({'books': books});
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book removed from request')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to remove book: $error')),
      );
    }
  }
}
