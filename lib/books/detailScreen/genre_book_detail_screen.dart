import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'course_book_detail_screen.dart'; // Adjust the import path accordingly

class GenreBookDetailScreen extends StatelessWidget {
  final String genre;

  const GenreBookDetailScreen({
    Key? key,
    required this.genre,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books in Genre: $genre'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('genre', arrayContains: genre) // Updated to use arrayContains for genres
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No books found for genre: $genre.'));
          }

          final books = snapshot.data!.docs;

          // Group books by title and sum the number of copies
          final Map<String, Map<String, dynamic>> groupedBooks = {};
          for (var book in books) {
            final bookData = book.data() as Map<String, dynamic>;
            final title = bookData['title'] ?? 'No Title';
            final numberOfCopies = bookData['numberOfCopies'] ?? 0;

            if (!groupedBooks.containsKey(title)) {
              groupedBooks[title] = {
                'title': title,
                'writer': bookData['writer'] ?? 'Unknown Writer',
                'imageUrl': bookData['imageUrl'] ?? '',
                'course': bookData['course'] ?? '',
                'summary': bookData['summary'] ?? '',
                'totalCopies': 0,
              };
            }
            groupedBooks[title]!['totalCopies'] = groupedBooks[title]!['totalCopies'] + numberOfCopies;
          }

          return ListView.builder(
            itemCount: groupedBooks.length,
            itemBuilder: (context, index) {
              final bookData = groupedBooks.values.elementAt(index);
              final title = bookData['title'] as String;
              final writer = bookData['writer'] as String;
              final imageUrl = bookData['imageUrl'] as String;
              final course = bookData['course'] as String;
              final summary = bookData['summary'] as String;
              final totalCopies = bookData['totalCopies'] as int;

              return ListTile(
                title: Text('$title (Available copies: $totalCopies)'),
                subtitle: Text(writer),
                leading: imageUrl.isNotEmpty
                    ? Image.network(
                  imageUrl,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                )
                    : null,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CourseBookDetailScreen(
                        title: title,
                        writer: writer,
                        imageUrl: imageUrl,
                        course: course,
                        summary: summary,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
