import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../../books/detailScreen/course_book_detail_screen.dart';

class BookListScreen extends StatelessWidget {
  final bool isCourseBook;
  final String? filter;

  const BookListScreen({
    Key? key,
    required this.isCourseBook,
    this.filter,
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
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    isCourseBook ? Icons.menu_book_rounded : Icons.book_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      isCourseBook ? 'Course Books' : 'Books',
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
              .where('isCourseBook', isEqualTo: isCourseBook)
              .where(
                isCourseBook ? 'course' : 'genre',
                isEqualTo: filter?.isNotEmpty == true ? filter : null,
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
              return Center(
                child: Text(
                  'No books found for the selected ${isCourseBook ? 'course' : 'genre'}.',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: const Color(0xFF4A4E69),
                        fontWeight: FontWeight.w600,
                      ),
                  textAlign: TextAlign.center,
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
                  'genre': bookData['genre'] ?? '',
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
                final genre = bookData['genre'] as String;
                final summary = bookData['summary'] as String;
                final totalCopies = bookData['totalCopies'] as int;

                return Material(
                  elevation: 3,
                  borderRadius: BorderRadius.circular(18),
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseBookDetailScreen(
                            title: title,
                            writer: writer,
                            imageUrl: imageUrl,
                            course: genre,
                            summary: summary,
                          ),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: imageUrl.isNotEmpty
                                ? Image.network(
                                    imageUrl,
                                    width: 70,
                                    height: 90,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    width: 70,
                                    height: 90,
                                    color: const Color(0xFF9A8C98).withOpacity(0.15),
                                    child: const Icon(Icons.menu_book_rounded, color: Color(0xFF4A4E69), size: 36),
                                  ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFF22223B),
                                        fontSize: 18,
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
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF9A8C98).withOpacity(0.13),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        genre,
                                        style: const TextStyle(
                                          color: Color(0xFF4A4E69),
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    const Spacer(),
                                    Row(
                                      children: [
                                        const Icon(Icons.library_books, color: Color(0xFF4A4E69), size: 18),
                                        const SizedBox(width: 4),
                                        Text(
                                          '$totalCopies available',
                                          style: const TextStyle(
                                            color: Color(0xFF4A4E69),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  summary,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: const Color(0xFF22223B).withOpacity(0.7),
                                      ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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
