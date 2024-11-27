import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../addpdf/pdfadd.dart';
import '../allbooks.dart';
import '../booksEditing/editBooks.dart';

class SearchBookScreen extends StatefulWidget {
  @override
  _SearchBookScreenState createState() => _SearchBookScreenState();
}

class _SearchBookScreenState extends State<SearchBookScreen> {
  final _searchController = TextEditingController();
  List<DocumentSnapshot> searchResults = [];

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    try {
      // Fetch all books from Firestore
      final snapshot = await FirebaseFirestore.instance.collection('books').get();

      // Filter results (case-insensitive)
      setState(() {
        searchResults = snapshot.docs.where((doc) {
          final bookTitle = (doc.data() as Map<String, dynamic>)['title'] as String;
          return bookTitle.toLowerCase().contains(query.toLowerCase());
        }).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to search books: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Book'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.picture_as_pdf_outlined),
          //   onPressed: () => Get.to(() =>  AddPDFScreen()),
          // ),
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: () => Get.to(() =>  AllBooksScreenAdmin())
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
                suffixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                _searchBooks(value); // Call search method on every keystroke
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _searchController.text.isEmpty
                  ? const Center(child: Text('No results found'))
                  : searchResults.isEmpty
                  ? const Center(child: Text('No books match your search'))
                  : ListView.builder(
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final book = searchResults[index].data() as Map<String, dynamic>;
                  final bookId = searchResults[index].id;
                  final title = book['title'] ?? 'No title';
                  final writer = book['writer'] ?? 'Unknown author';
                  final imageUrl = book['imageUrl'] ?? '';

                  return ListTile(
                    leading: imageUrl.isEmpty
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
                    title: Text(title),
                    subtitle: Text(writer),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Edit Book'),
                          content: const Text('Do you want to edit this book?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditBookScreen(bookId: bookId),
                                  ),
                                );
                              },
                              child: const Text('Edit'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
