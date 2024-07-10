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
      body: ListView.builder(
        itemCount: searchHistory.history.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(searchHistory.history[index]),
            onTap: () async {
              final recommendations = await bookService.getRecommendations(searchHistory.history[index]);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecommendationsScreen(recommendations: recommendations),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class RecommendationsScreen extends StatelessWidget {
  final List<Book> recommendations;

  RecommendationsScreen({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recommendations'),
      ),
      body: ListView.builder(
        itemCount: recommendations.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: recommendations[index].thumbnail != null
                ? Image.network(recommendations[index].thumbnail!)
                : null,
            title: Text(recommendations[index].title),
            subtitle: Text(recommendations[index].authors),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BookDetailsScreen(book: recommendations[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
