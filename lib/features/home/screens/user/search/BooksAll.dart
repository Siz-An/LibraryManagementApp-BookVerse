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
      appBar: AppBar(
        title: const Text('All Books'),
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

          return ListView(
            children: filteredAlphabet.map((letter) {
              final books = groupedBooks[letter]!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Alphabet Header
                  Container(
                    color: Colors.blueGrey.shade50,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      letter,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
                  const Divider(thickness: 1),

                  // Book Tiles
                  ...books.map((book) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 2,
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8.0),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              book['imageUrl'],
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.broken_image, size: 50);
                              },
                            ),
                          ),
                          title: Text(
                            book['title'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(book['writer']),
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
          );
        },
      ),
    );
  }
}
