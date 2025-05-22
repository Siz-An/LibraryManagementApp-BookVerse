import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../books/detailScreen/course_book_detail_screen.dart';

class AllBooksScreen extends StatelessWidget {
  const AllBooksScreen({super.key});

  Future<Map<String, List<Map<String, dynamic>>>> _fetchAndSortBooks() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();

    final List<Map<String, dynamic>> books = snapshot.docs.map((doc) {
      return {
        'title': doc['title'] as String? ?? 'Unknown Title',
        'writer': doc['writer'] as String? ?? 'Unknown Writer',
        'imageUrl': doc['imageUrl'] as String? ?? '',
        'course': doc['course'] as String? ?? 'Unknown Course',
        'summary': doc['summary'] as String? ?? 'No Summary Available',
      };
    }).toList();

    books.sort((a, b) => (a['title'] as String).compareTo(b['title'] as String));

    final Map<String, List<Map<String, dynamic>>> groupedBooks = {};
    for (var book in books) {
      final String firstLetter = (book['title'] as String)[0].toUpperCase();
      if (!groupedBooks.containsKey(firstLetter)) {
        groupedBooks[firstLetter] = [];
      }
      groupedBooks[firstLetter]!.add(book);
    }

    return groupedBooks;
  }

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'All Books',
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
      body: FutureBuilder<Map<String, List<Map<String, dynamic>>>>(
        future: _fetchAndSortBooks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No books available.'));
          }

          final groupedBooks = snapshot.data!;
          final List<String> alphabet = List.generate(26, (i) => String.fromCharCode('A'.codeUnitAt(0) + i));
          final filteredAlphabet = alphabet.where((letter) => groupedBooks.containsKey(letter)).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
            child: ListView(
              children: [
                const SizedBox(height: 12),
                Text(
                  'Browse by Alphabet',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF22223B),
                      ),
                ),
                const SizedBox(height: 10),
                ...filteredAlphabet.map((letter) {
                  final books = groupedBooks[letter]!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Alphabet Header
                      Container(
                        margin: const EdgeInsets.only(top: 18, bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                        decoration: BoxDecoration(
                          color: const Color(0xFF9A8C98).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          letter,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF4A4E69),
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      ...books.map((book) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            elevation: 4,
                            shadowColor: const Color(0xFF4A4E69).withOpacity(0.18),
                            color: Colors.white,
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12.0),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10.0),
                                child: book['imageUrl'].isNotEmpty
                                    ? Image.network(
                                        book['imageUrl'],
                                        width: 50,
                                        height: 70,
                                        fit: BoxFit.cover,
                                        errorBuilder: (context, error, stackTrace) {
                                          return Container(
                                            width: 50,
                                            height: 70,
                                            color: Colors.grey.shade200,
                                            child: const Icon(Icons.broken_image, size: 32, color: Colors.grey),
                                          );
                                        },
                                      )
                                    : Container(
                                        width: 50,
                                        height: 70,
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.menu_book, size: 32, color: Colors.grey),
                                      ),
                              ),
                              title: Text(
                                book['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF22223B),
                                ),
                              ),
                              subtitle: Text(
                                book['writer'],
                                style: const TextStyle(
                                  color: Color(0xFF4A4E69),
                                  fontSize: 14,
                                ),
                              ),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF4A4E69), size: 20),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CourseBookDetailScreen(
                                      title: book['title'],
                                      writer: book['writer'],
                                      imageUrl: book['imageUrl'],
                                      course: book['course'],
                                      summary: book['summary'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      }).toList(),
                    ],
                  );
                }).toList(),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}
