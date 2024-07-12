import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/search_history.dart';
import '../services/book_service.dart';
import 'BookDetailsPage.dart';
import 'books.dart';

class SearchHistoryScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final searchHistory = Provider.of<SearchHistory>(context);
    final bookService = BookService();

    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendations'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              searchHistory.clearHistory();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<List<Book>>>(
        future: Future.wait(searchHistory.history.map((term) => bookService.searchBooks(term)).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching search history'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No search history found'));
          }

          final searchResults = snapshot.data!;

          return ListView.builder(
            itemCount: searchResults.length,
            itemBuilder: (context, index) {
              final books = searchResults[index];
              if (books.isEmpty) {
                return ListTile(title: Text('No books found for "${searchHistory.history[index]}"'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10), // Add some spacing between search result groups
                  FutureBuilder<List<Book>>(
                    future: bookService.getBooksByAuthor(books[0].authors), // Assuming books[0] represents the first book in the list
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error fetching books by author'));
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return SizedBox(); // Hide if no books by the author
                      }

                      final booksByAuthor = snapshot.data!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(), // Add a divider for separation
                          ListTile(title: Text('More books by ${books[0].authors}')),
                          ...booksByAuthor.map((book) {
                            return ListTile(
                              leading: book.thumbnail != null ? Image.network(book.thumbnail!) : null,
                              title: Text(book.title),
                              subtitle: Text(book.authors),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BookDetailsScreen(book: book),
                                  ),
                                );
                              },
                            );
                          }).toList(),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
