import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booksEditing/editBooks.dart';

class SearchBookScreen extends StatefulWidget {
  @override
  _SearchBookScreenState createState() => _SearchBookScreenState();
}

class _SearchBookScreenState extends State<SearchBookScreen> {
  final _searchController = TextEditingController();
  String? _bookId;
  bool _bookFound = false;
  Map<String, dynamic>? _bookData;

  Future<void> _searchBook() async {
    setState(() {
      _bookFound = false;
    });

    final searchQuery = _searchController.text.trim();
    if (searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a book title or ID')),
      );
      return;
    }

    try {
      DocumentSnapshot doc;

      if (searchQuery.contains(RegExp(r'^[0-9a-fA-F]{24}$'))) {
        // Search by ID (assuming IDs are 24-character hex strings)
        doc = await FirebaseFirestore.instance.collection('books').doc(searchQuery).get();
      } else {
        // Search by title
        final snapshot = await FirebaseFirestore.instance.collection('books')
            .where('title', isEqualTo: searchQuery)
            .limit(1)
            .get();
        if (snapshot.docs.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No book found with that title')),
          );
          return;
        }
        doc = snapshot.docs.first;
      }

      if (doc.exists) {
        setState(() {
          _bookId = doc.id;
          _bookData = doc.data() as Map<String, dynamic>?;
          _bookFound = true;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No book found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search book: $e')),
      );
    }
  }

  Future<void> _deleteBook() async {
    if (_bookId != null) {
      try {
        await FirebaseFirestore.instance.collection('books').doc(_bookId).delete();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Book deleted successfully')),
        );
        setState(() {
          _bookFound = false;
          _bookData = null;
          _searchController.clear();
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete book: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Book'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _bookFound = false;
                _bookData = null;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Enter Book Title or ID',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchBook,
                ),
              ),
              onSubmitted: (_) => _searchBook(),
            ),
            const SizedBox(height: 16),
            if (_bookFound && _bookData != null)
              Expanded(
                child: ListView(
                  children: [
                    ListTile(
                      title: Text('Title: ${_bookData!['title']}'),
                    ),
                    ListTile(
                      title: Text('Writer: ${_bookData!['writer']}'),
                    ),
                    ListTile(
                      title: Text('Genre: ${_bookData!['genre'] ?? 'N/A'}'),
                    ),
                    ListTile(
                      title: Text('Course: ${_bookData!['course'] ?? 'N/A'}'),
                    ),
                    ListTile(
                      title: Text('Grade: ${_bookData!['grade'] ?? 'N/A'}'),
                    ),
                    ListTile(
                      title: Text('Summary: ${_bookData!['summary']}'),
                    ),
                    ListTile(
                      title: Text('Number of Copies: ${_bookData!['numberOfCopies'] ?? 'N/A'}'),
                    ),
                    if (_bookData!['imageUrl'] != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Image.network(
                          _bookData!['imageUrl'],
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            if (_bookId != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EditBookScreen(bookId: _bookId!),
                                ),
                              ).then((_) {
                                // Refresh the page when returning from the edit screen
                                setState(() {
                                  _bookFound = false;
                                  _bookData = null;
                                  _searchController.clear();
                                });
                              });
                            }
                          },
                          child: const Text('Edit Book'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.green, // Text color
                            minimumSize: Size(150, 50), // Button size
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_bookId != null) {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Confirm Deletion'),
                                  content: const Text('Are you sure you want to delete this book?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        Navigator.pop(context);
                                        await _deleteBook();
                                      },
                                      child: const Text('Delete'),
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                          child: const Text('Delete Book'),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white, backgroundColor: Colors.red, // Text color
                            minimumSize: Size(150, 50), // Button size
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (!_bookFound)
              const Expanded(
                child: Center(
                  child: Text('Search for a book to see details'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
