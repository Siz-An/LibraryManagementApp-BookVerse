import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booksEditing/editBooks.dart';

class AllBooksScreenAdmin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Books'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('books').orderBy('title').get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('Something went wrong'));
          }

          final books = snapshot.data?.docs ?? [];
          if (books.isEmpty) {
            return const Center(child: Text('No books found'));
          }

          // Group books by initial letter
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
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: Colors.green,
                      ),
                    ),
                  ),
                  ...bookList.map((book) {
                    final bookData = book['data'];
                    final bookId = book['id'];

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10.0),
                        title: Text(
                          bookData['title'] ?? 'No Title',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text('Author: ${bookData['writer'] ?? 'N/A'}'),
                        leading: bookData['imageUrl'] != null && bookData['imageUrl'].isNotEmpty
                            ? ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(
                            bookData['imageUrl'],
                            width: 60,
                            height: 90,
                            fit: BoxFit.cover,
                          ),
                        )
                            : const Icon(
                          Icons.book,
                          size: 50,
                          color: Colors.deepPurpleAccent,
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.deepPurpleAccent),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Edit Book?'),
                                content: const Text('Are you sure you want to edit this book?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => EditBookScreen(bookId: bookId),
                                        ),
                                      );
                                    },
                                    child: const Text('Edit'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  }).toList(),
                  const Divider(thickness: 1, indent: 16, endIndent: 16), // Divider between groups
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
