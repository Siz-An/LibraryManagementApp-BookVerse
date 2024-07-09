import 'package:flutter/material.dart';
import '../../../../api/BookDetailsPage.dart';
import '../../../../api/book.dart';
import '../../../../api/book_service.dart';
import '../../../../common/widgets/appbar/appbar.dart';
import '../../../../utils/constants/sizes.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final BookService _bookService = BookService();
  final TextEditingController _controller = TextEditingController();
  List<Book> _books = [];
  List<Book> _popularBooks = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchPopularBooks();
  }

  Future<void> _fetchPopularBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final popularBooks = await _bookService.searchBooks('popular');
      setState(() {
        _popularBooks = popularBooks;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _searchBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _bookService.searchBooks(_controller.text);
      setState(() {
        _books = books;
      });
    } catch (e) {
      // Handle error
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showBookDetails(Book book) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BookDetailsPage(book: book)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: TAppBar(
          title: Text(
            'Book Verse',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  labelText: 'Search',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchBooks,
                  ),
                ),
                onSubmitted: (value) => _searchBooks(),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_books.isNotEmpty)
                _buildBookList(_books)
              else
                _buildBookList(_popularBooks, title: 'Popular Books'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookList(List<Book> books, {String? title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16.0),
        ],
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: books.length,
          itemBuilder: (context, index) {
            final book = books[index];
            return ListTile(
              leading: book.thumbnail.isNotEmpty
                  ? Image.network(book.thumbnail)
                  : null,
              title: Text(book.title),
              subtitle: Text(book.authors.join(', ')),
              onTap: () => _showBookDetails(book),
            );
          },
        ),
      ],
    );
  }
}
