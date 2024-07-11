import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../api/bookmark/bookMrk.dart';
import 'books.dart'; // Import the Book class definition

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  BookDetailsScreen({required this.book});

  @override
  Widget build(BuildContext context) {
    final bookmarks = Provider.of<Bookmarks>(context);
    final isBookmarked = bookmarks.bookmarks.contains(book);

    return Scaffold(
      appBar: AppBar(
        title: Text(book.title),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () {
              if (isBookmarked) {
                bookmarks.removeBookmark(book);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Book removed from bookmarks!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              } else {
                bookmarks.addBookmark(book);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Book saved to bookmarks!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (book.thumbnail != null)
              Center(
                child: Image.network(book.thumbnail!),
              ),
            SizedBox(height: 16.0),
            Text(
              book.title,
              style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              'Authors: ${book.authors}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Summary:',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Text(
              book.description ?? 'No description available.',
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
}
