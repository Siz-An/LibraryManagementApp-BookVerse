import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../books/BookDetailsPage.dart';
import '../books/books.dart';

class RecommendationsScreen extends StatelessWidget {
  final List<Book> recommendations;

  RecommendationsScreen({required this.recommendations});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Random Books'),
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
