import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'editBooks.dart';

class ListBooksScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('books').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No books available'));
          }

          final books = snapshot.data!.docs;

          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              final bookId = book.id; // Get the book ID
              final title = book['title'] ?? 'Untitled';

              return ListTile(
                title: Text(title),
                trailing: IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditBookScreen(bookId: bookId),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
