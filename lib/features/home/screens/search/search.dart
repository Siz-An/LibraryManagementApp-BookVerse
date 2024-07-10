import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_Verse/api/services/book_service.dart'; // Ensure this import is consistent
import '../../../../api/books/BookDetailsPage.dart';
import '../../../../api/books/books.dart';
import '../../../../api/books/search_history_screen.dart';
import '../../../../api/models/search_history.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final BookService _bookService = BookService();
  List<Book> _books = [];
  List<Book> _recommendedBooks = [];
  bool _isLoading = false;

  void _searchBooks(String term) async {
    setState(() {
      _isLoading = true;
    });

    final books = await _bookService.searchBooks(term);

    if (books.isNotEmpty && books.first.genres != null) {
      final genre = books.first.genres!.first;
      final recommendations = await _bookService.getRecommendations(genre);

      // Filter out the searched books from the recommendations
      final filteredRecommendations = recommendations.where((recBook) {
        return !books.any((searchedBook) => searchedBook.title == recBook.title);
      }).toList();

      setState(() {
        _books = books;
        _recommendedBooks = filteredRecommendations;
        _isLoading = false;
      });
    } else {
      setState(() {
        _books = books;
        _recommendedBooks = [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final searchHistory = Provider.of<SearchHistory>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Book Api'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchHistoryScreen()),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: 'Search for books',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (term) {
                  searchHistory.addSearchTerm(term);
                  _searchBooks(term);
                },
              ),
            ),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
              child: ListView(
                children: <Widget>[
                  _buildSectionTitle('Search Results'),
                  _buildBookList(_books),
                  _buildSectionTitle('Recommended Books'),
                  _buildBookList(_recommendedBooks),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildBookList(List<Book> books) {
    return Column(
      children: books.map((book) {
        return ListTile(
          leading: book.thumbnail != null
              ? Image.network(book.thumbnail!)
              : null,
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
    );
  }
}
