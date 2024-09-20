import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booksEditing/editBooks.dart'; // Adjust the import path if necessary

class AllBooksScreenadmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Books'),
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('books').orderBy('title').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          final books = snapshot.data?.docs ?? [];
          if (books.isEmpty) {
            return Center(child: Text('No books found'));
          }

          // Group books by their initial letter
          final Map<String, List<Map<String, dynamic>>> groupedBooks = {};
          for (var doc in books) {
            final bookData = doc.data() as Map<String, dynamic>;
            final title = bookData['title'] ?? 'No Title';
            final initial = title.isNotEmpty ? title[0].toUpperCase() : '';

            if (!groupedBooks.containsKey(initial)) {
              groupedBooks[initial] = [];
            }
            groupedBooks[initial]!.add({'data': bookData, 'id': doc.id});
          }

          return ListView(
            children: groupedBooks.entries.map((entry) {
              final initial = entry.key;
              final bookList = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: Text(
                      initial,
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ...bookList.map((book) {
                    final bookData = book['data'];
                    final bookId = book['id'];

                    return ListTile(
                      title: Text(bookData['title'] ?? 'No Title'),
                      subtitle: Text('Author: ${bookData['writer'] ?? 'N/A'}'),
                      leading: bookData['imageUrl'] != null
                          ? Image.network(
                        bookData['imageUrl'],
                        width: 50,
                        height: 75,
                        fit: BoxFit.scaleDown,
                      )
                          : const Icon(Icons.book, size: 50), // Default icon if image is not available
                      onTap: () {
                        // Show confirmation dialog before editing
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Edit Book?'),
                            content: const Text('Are you sure you want to edit this book?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                  // Navigate to the edit screen
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditBookScreen(bookId: bookId), // Pass the book ID
                                    ),
                                  );
                                },
                                child: const Text('Edit'),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }).toList(),
                  Divider(), // Add a divider after each group
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
