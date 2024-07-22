// lib/screens/mark_app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../api/bookmark/bookMark_Provider.dart';
import '../../../../../api/books/BookDetailsPage.dart';
class MarkApp extends StatelessWidget {
  const MarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BookmarkScreen();
  }
}

class BookmarkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookmarks = Provider.of<Bookmarks>(context).bookmarks;

    return Scaffold(
      appBar: AppBar(
        title: Text('Bookmarks'),
      ),
      body: ListView.builder(
        itemCount: bookmarks.length,
        itemBuilder: (context, index) {
          final book = bookmarks[index];
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
        },
      ),
    );
  }
}
