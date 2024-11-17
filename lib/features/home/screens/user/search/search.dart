import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../books/detailScreen/course_book_detail_screen.dart';
import 'BooksAll.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<DocumentSnapshot> searchResults = [];
  bool isLoading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _deleteSearchedBooks() async {
    if (userId == null) return;

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('searchedBooks')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      print('All previous searched books deleted successfully.');
    } catch (e) {
      print('Failed to delete searched books: $e');
    }
  }

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    setState(() {
      isLoading = true;
    });

    await _deleteSearchedBooks(); // Delete previous searches before fetching new ones

    final uppercaseQuery = query.toUpperCase();
    final snapshot = await FirebaseFirestore.instance.collection('books').get();

    setState(() {
      searchResults = snapshot.docs.where((doc) {
        final bookTitle = (doc.data() as Map<String, dynamic>)['title'] as String;
        return bookTitle.toUpperCase().contains(uppercaseQuery);
      }).toList();
      isLoading = false;
    });

    if (userId != null) {
      await _saveSearchedBooks(uppercaseQuery, userId!);
    }
  }

  Future<void> _saveSearchedBooks(String searchQuery, String userId) async {
    try {
      for (var doc in searchResults) {
        final bookId = doc.id;
        final book = doc.data() as Map<String, dynamic>;
        final title = book['title']?.toString() ?? 'No title';
        final writer = book['writer']?.toString() ?? 'Unknown author';
        final imageUrl = book['imageUrl']?.toString() ?? '';
        final course = book['course']?.toString() ?? '';
        final summary = book['summary']?.toString() ?? 'No summary available';

        print('Checking book: $title against search query: $searchQuery');

        if (title.trim().toLowerCase() == searchQuery.trim().toLowerCase()) {
          final existingBook = await FirebaseFirestore.instance
              .collection('searchedBooks')
              .where('userId', isEqualTo: userId)
              .where('bookId', isEqualTo: bookId)
              .get();

          if (existingBook.docs.isEmpty) {
            await FirebaseFirestore.instance.collection('searchedBooks').add({
              'userId': userId,
              'bookId': bookId,
              'title': title,
              'writer': writer,
              'imageUrl': imageUrl,
              'course': course,
              'summary': summary,
              'searchedAt': FieldValue.serverTimestamp(),
            });
            print('Book saved: $title');
          } else {
            print('Book with bookId: $bookId already exists for userId: $userId');
          }
        }
      }
    } catch (e) {
      print('Failed to save searched books: $e');
    }
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
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
            child: searchResults.isEmpty
                ? const Center(
              child: Text(
                'No results found',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
                : ListView.builder(
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final book = searchResults[index].data() as Map<String, dynamic>;

                final title = book['title'] ?? 'No title';
                final writer = book['writer'] ?? 'Unknown author';
                final imageUrl = book['imageUrl'] ?? '';
                final course = book['course'] ?? '';
                final summary = book['summary'] ?? 'No summary available';

                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: imageUrl.isEmpty
                          ? const Icon(Icons.book, size: 50)
                          : Image.network(
                        imageUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.book, size: 50);
                        },
                      ),
                    ),
                    title: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
