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
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
              child: Row(
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.category, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Genre: $genre',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('books')
              .where('genre', arrayContains: genre)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No books found for genre: $genre.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4A4E69),
                        fontWeight: FontWeight.w600,
                      ),
                ),
              );
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
              groupedBooks[title]!['totalCopies'] =
                  groupedBooks[title]!['totalCopies'] + numberOfCopies;
            }

            return ListView.separated(
              itemCount: groupedBooks.length,
              separatorBuilder: (context, index) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final bookData = groupedBooks.values.elementAt(index);
                final title = bookData['title'] as String;
                final writer = bookData['writer'] as String;
                final imageUrl = bookData['imageUrl'] as String;
                final course = bookData['course'] as String;
                final summary = bookData['summary'] as String;
                final totalCopies = bookData['totalCopies'] as int;

                return GestureDetector(
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.10),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(18),
                            bottomLeft: Radius.circular(18),
                          ),
                          child: imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  width: 80,
                                  height: 110,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 80,
                                  height: 110,
                                  color: const Color(0xFF9A8C98).withOpacity(0.15),
                                  child: const Icon(Icons.book, size: 40, color: Color(0xFF4A4E69)),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF22223B),
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  writer,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: const Color(0xFF4A4E69),
                                        fontWeight: FontWeight.w500,
                                      ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  summary,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF6C567B),
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    const Icon(Icons.library_books, size: 18, color: Color(0xFF9A8C98)),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Available: $totalCopies',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: const Color(0xFF9A8C98),
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    if (course.isNotEmpty) ...[
                                      const SizedBox(width: 14),
                                      const Icon(Icons.school, size: 16, color: Color(0xFF4A4E69)),
                                      const SizedBox(width: 4),
                                      Text(
                                        course,
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: const Color(0xFF4A4E69),
                                            ),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
