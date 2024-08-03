import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../books/course_book_detail_screen.dart';

class BookListScreen extends StatelessWidget {
  final bool isCourseBook;
  final String? filter; // Allow filter to be nullable

  const BookListScreen({
    Key? key,
    required this.isCourseBook,
    this.filter, // Make filter optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isCourseBook ? 'Course Books' : 'Books'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('books')
            .where('isCourseBook', isEqualTo: isCourseBook)
            .where(
          isCourseBook ? 'course' : 'genre',
          isEqualTo: filter?.isNotEmpty == true ? filter : null, // Handle nullable filter
        )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No books found for the selected ${isCourseBook ? 'course' : 'genre'}.'));
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
