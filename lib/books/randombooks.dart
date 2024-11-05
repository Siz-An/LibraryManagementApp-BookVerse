import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../common/widgets/texts/section_heading.dart';
import 'detailScreen/course_book_detail_screen.dart';

class TRandomBooks extends StatefulWidget {
  const TRandomBooks({Key? key}) : super(key: key);

  @override
  _RandomBooksState createState() => _RandomBooksState();
}

class _RandomBooksState extends State<TRandomBooks> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _randomBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRandomBooks();
  }

  Future<void> _fetchRandomBooks() async {
    try {
      // Fetch books from 'searchedBooks' collection
      final searchedBooksSnapshot = await _firestore.collection('searchedBooks').get();
      final searchedBooks = searchedBooksSnapshot.docs.map((doc) => doc.data()).toList();

      // Fetch books from 'bookmarks' collection
      final bookmarksSnapshot = await _firestore.collection('bookmarks').get();
      final bookmarks = bookmarksSnapshot.docs.map((doc) => doc.data()).toList();

      // Combine both lists
      final allBooks = [...searchedBooks, ...bookmarks];

      // Shuffle the combined list
      allBooks.shuffle();

      // Take the first 5 books from the shuffled list
      _randomBooks = allBooks.take(5).cast<Map<String, dynamic>>().toList();
    } catch (e) {
      print('Error fetching books: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _navigateToDetailPage(Map<String, dynamic> book) {
    final title = book['title'] ?? 'Unknown Title';
    final writer = book['writer'] ?? 'Unknown Writer';
    final imageUrl = book['imageUrl'] ?? 'https://example.com/placeholder.jpg';
    final course = book['course'] ?? 'No course info available';
    final summary = book['summary'] ?? 'No summary available';

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseBookDetailScreen(
          title: title,
          writer: writer,
          imageUrl: imageUrl,
          course: course,
          summary: summary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TSectionHeading(
          title: 'Trendy Books',
          onPressed: () {
            // Handle view all button press
          },
        ),
        SizedBox(height: 10),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _randomBooks.isEmpty
            ? Center(child: Text('No random books found.'))
            : SizedBox(
          height: 300, // Set a fixed height for the carousel
          child: CarouselSlider.builder(
            itemCount: _randomBooks.length,
            itemBuilder: (context, index, realIndex) {
              final book = _randomBooks[index];
              final imageUrl = book['imageUrl'] ?? 'https://example.com/placeholder.jpg';
              final title = book['title'] ?? 'Unknown Title';
              final writer = book['writer'] ?? 'Unknown Writer';

              return GestureDetector(
                onTap: () => _navigateToDetailPage(book),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: const BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8,
                                  spreadRadius: 1,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Image.network(
                              imageUrl,
                              width: 150,
                              height: 220,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Text(
                                    'Image not available',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          writer,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 300,
              viewportFraction: 0.5,
              enlargeCenterPage: false,
              aspectRatio: 2.0,
              autoPlay: false,
              enableInfiniteScroll: true,
            ),
          ),
        ),
      ],
    );
  }
}
