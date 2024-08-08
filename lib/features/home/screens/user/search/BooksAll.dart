import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../books/detailScreen/course_book_detail_screen.dart'; // Import the detail screen

class AllBooksScreen extends StatelessWidget {
  const AllBooksScreen({super.key});

  Future<Map<String, List<Map<String, dynamic>>>> _fetchAndSortBooks() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('books').get();

    final List<Map<String, dynamic>> books = snapshot.docs.map((doc) {
      return {
        'title': doc['title'] as String? ?? 'Unknown Title', // Provide a default value
        'writer': doc['writer'] as String? ?? 'Unknown Writer', // Provide a default value
        'imageUrl': doc['imageUrl'] as String? ?? '', // Provide a default empty string
        'course': doc['course'] as String? ?? 'Unknown Course', // Provide a default value
        'summary': doc['summary'] as String? ?? 'No Summary Available', // Provide a default value
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      letter,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  ...books.map((book) {
                    return ListTile(
                      leading: Image.network(
                        book['imageUrl'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.broken_image);
                        },
                      ),
                      title: Text(book['title']),
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
