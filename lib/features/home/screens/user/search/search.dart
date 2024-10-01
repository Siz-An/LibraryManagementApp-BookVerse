import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../../books/detailScreen/course_book_detail_screen.dart';
import 'BooksAll.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<DocumentSnapshot> searchResults = [];

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    // Convert the search query to uppercase
    final uppercaseQuery = query.toUpperCase();

    // Fetch all books first
    final snapshot = await FirebaseFirestore.instance.collection('books').get();

    // Filter the results to make the title comparison case-insensitive
    setState(() {
      searchResults = snapshot.docs.where((doc) {
        final bookTitle = (doc.data() as Map<String, dynamic>)['title'] as String;
        return bookTitle.contains(uppercaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Books'),

        actions: [
          IconButton(
            icon: const Icon(Icons.menu_book),
            color: Colors.green,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AllBooksScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  query = value;
                });
                _searchBooks(value);
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: searchResults.isEmpty
                ? const Center(child: Text('No results found'))
                : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final book = searchResults[index].data() as Map<String, dynamic>;

                final title = book['title'] ?? 'No title';
                final writer = book['writer'] ?? 'Unknown author';
                final imageUrl = book['imageUrl'] ?? '';
                final course = book['course'] ?? '';
                final summary = book['summary'] ?? 'No summary available';

                return ListTile(
                  leading: imageUrl.isEmpty
                      ? const Icon(Icons.book, size: 50)
                      : Image.network(
                    imageUrl,
                    width: 50,
                    height: 70,
                    fit: BoxFit.fitHeight,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.book, size: 50);
                    },
                  ),
                  title: Text(title),
                  subtitle: Text(writer),
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
            ),
          ),
        ],
      ),
    );
  }
}
