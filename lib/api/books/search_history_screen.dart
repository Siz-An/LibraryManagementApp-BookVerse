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
        title: Text('Search History'),
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
        future: Future.wait(searchHistory.history.map((term) => bookService.getRecommendations(term)).toList()),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error fetching recommendations'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No recommendations found'));
          }

          final recommendations = snapshot.data!;

          return ListView.builder(
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final books = recommendations[index];
              if (books.isEmpty) {
                return ListTile(title: Text('No recommendations found for "${searchHistory.history[index]}"'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(title: Text('Recommendations for "${searchHistory.history[index]}"')),
                  ...books.map((book) {
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
          );
        },
      ),
    );
  }
}
