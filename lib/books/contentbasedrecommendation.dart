import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../common/widgets/texts/section_heading.dart';
import 'detailScreen/course_book_detail_screen.dart';

class ContentBasedAlgorithm extends StatefulWidget {
  const ContentBasedAlgorithm({super.key});

  @override
  _ContentBasedAlgorithm createState() => _ContentBasedAlgorithm();
}

class _ContentBasedAlgorithm extends State<ContentBasedAlgorithm> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _popularBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedBooks();
  }

  Future<void> _fetchRecommendedBooks() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('No user logged in.');
        setState(() {
          _isLoading = false;
          _popularBooks = [];
        });
        return;
      }

      // Step 1: Fetch the most recent searched book by the user
      final searchedBooksSnapshot = await _firestore
          .collection('searchedBooks')
          .where('userId', isEqualTo: userId) // Filter by current user
          .orderBy('searchedAt', descending: true)
          .limit(7)
          .get();

      if (searchedBooksSnapshot.docs.isEmpty) {
        print('No searched books found.');
        setState(() {
          _isLoading = false;
          _popularBooks = [];
        });
        return;
      }

      final searchedBook = searchedBooksSnapshot.docs.first.data();
      final searchedAuthor = searchedBook['writer']?.trim();

      if (searchedAuthor == null || searchedAuthor.isEmpty) {
        print('No author found for the searched book.');
        setState(() {
          _isLoading = false;
          _popularBooks = [];
        });
        return;
      }

      // Step 2: Fetch all bookmarks by the same author for this user
      final bookmarksByAuthorSnapshot = await _firestore
          .collection('bookmarks')// Filter by current user
          .where('writer', isEqualTo: searchedAuthor)
          .get();

      final bookmarkedBookIds = bookmarksByAuthorSnapshot.docs
          .map((doc) => doc.data()['bookId'] as String?)
          .where((bookId) => bookId != null)
          .toSet();

      if (bookmarkedBookIds.isEmpty) {
        print('No bookmarked book IDs found.');
        setState(() {
          _isLoading = false;
          _popularBooks = [];
        });
        return;
      }

      // Step 3: Fetch book details for the bookmarked IDs
      final recommendedBooks = await Future.wait(
        bookmarkedBookIds.map((bookId) async {
          final bookDoc = await _firestore.collection('books').doc(bookId).get();
          return bookDoc.exists ? bookDoc.data() as Map<String, dynamic> : null;
        }),
      );

      setState(() {
        _popularBooks = recommendedBooks.whereType<Map<String, dynamic>>().toList();
      });
    } catch (e) {
      print('Error fetching recommended books: $e');
      setState(() {
        _popularBooks = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }



  void _navigateToDetailPage(Map<String, dynamic> book) {
    final title = book['title'] ?? 'Unknown Title';
    final writer = book['writer'] ?? 'Unknown Writer';
    final imageUrl = book['imageUrl'] ?? 'https://example.com/placeholder.jpg'; // Placeholder
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
          title: '| Popular Books',
          fontSize: 25,
          onPressed: () {
            // Handle view all button press
          },
        ),
        SizedBox(height: 10),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _popularBooks.isEmpty
            ? Center(child: Text('No popular books found.'))
            : SizedBox(
          height: 300, // Set a fixed height for the carousel
          child: CarouselSlider.builder(
            itemCount: _popularBooks.length,
            itemBuilder: (context, index, realIndex) {
              final book = _popularBooks[index];
              final imageUrl = book['imageUrl'] ?? 'https://example.com/placeholder.jpg';
              final title = book['title'] ?? 'Unknown Title';
              final writer = book['writer'] ?? 'Unknown Writer';

              return GestureDetector(
                onTap: () => _navigateToDetailPage(book),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Make Column size flexible
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20), // Increased border radius
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
                        SizedBox(height: 5),
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
              viewportFraction: 0.5, // Show two items side by side
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
