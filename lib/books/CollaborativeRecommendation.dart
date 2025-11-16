import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
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
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
    });

    // Obtain the current user's ID (replace with actual logic)
    final currentUser = await FirebaseAuth.instance.currentUser;
    final currentUserId = currentUser?.uid;

    if (currentUserId != null) {
      await _fetchCollaborativeFiltering(currentUserId);
    } else {
      print('Error: User not logged in.');
      setState(() {
        _isLoading = false;
      });
    }
  }



  Future<void> _fetchCollaborativeFiltering(String currentUserId) async {
    try {
      // Fetch books from 'searchedBooks' and 'bookmarks' collections
      final searchedBooksSnapshot = await _firestore.collection('searchedBooks').get();
      final bookmarksSnapshot = await _firestore.collection('bookmarks').get();

      // Fetch user-specific data
      final currentUserSearchedBooksSnapshot = await _firestore
          .collection('searchedBooks')
          .where('userId', isEqualTo: currentUserId)
          .get();
      final currentUserBookmarksSnapshot = await _firestore
          .collection('bookmarks')
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Convert snapshots to lists
      final searchedBooks = searchedBooksSnapshot.docs.map((doc) => doc.data()).toList();
      final bookmarks = bookmarksSnapshot.docs.map((doc) => doc.data()).toList();
      final currentUserSearchedBooks = currentUserSearchedBooksSnapshot.docs.map((doc) => doc.data()).toList();
      final currentUserBookmarks = currentUserBookmarksSnapshot.docs.map((doc) => doc.data()).toList();

      // Step 1: Compute user similarity
      Map<String, int> userSimilarityScores = {};
      for (var book in currentUserSearchedBooks) {
        for (var searchedBook in searchedBooks) {
          if (searchedBook['bookId'] == book['bookId'] && searchedBook['userId'] != currentUserId) {
            userSimilarityScores[searchedBook['userId']] =
                (userSimilarityScores[searchedBook['userId']] ?? 0) + 1;
          }
        }
      }
      for (var book in currentUserBookmarks) {
        for (var bookmark in bookmarks) {
          if (bookmark['bookId'] == book['bookId'] && bookmark['userId'] != currentUserId) {
            userSimilarityScores[bookmark['userId']] =
                (userSimilarityScores[bookmark['userId']] ?? 0) + 1;
          }
        }
      }

      // Step 2: Find top similar users
      final similarUsers = userSimilarityScores.keys.toList()
        ..sort((a, b) => userSimilarityScores[b]!.compareTo(userSimilarityScores[a]!));

      // Step 3: Collect books from similar users
      List<Map<String, dynamic>> recommendedBooks = [];
      for (var userId in similarUsers.take(5)) {
        final userBookmarksSnapshot = await _firestore
            .collection('bookmarks')
            .where('userId', isEqualTo: userId)
            .get();
        final userSearchedBooksSnapshot = await _firestore
            .collection('searchedBooks')
            .where('userId', isEqualTo: userId)
            .get();

        recommendedBooks.addAll(userBookmarksSnapshot.docs.map((doc) => doc.data()).toList());
        recommendedBooks.addAll(userSearchedBooksSnapshot.docs.map((doc) => doc.data()).toList());
      }

      // Remove duplicates and already interacted books
      recommendedBooks = recommendedBooks.toSet().toList();
      recommendedBooks.removeWhere((book) => currentUserSearchedBooks.any((b) => b['bookId'] == book['bookId']));
      recommendedBooks.removeWhere((book) => currentUserBookmarks.any((b) => b['bookId'] == book['bookId']));

      // Step 4: Final selection with weighted hybrid
      List<Map<String, dynamic>> selectedBooks = [];
      int numRecommended = 5; // e.g., favor 3 recommended books
      int numRandom = 5;      // and 3 random books from global pool

      // Randomly select from recommended books
      recommendedBooks.shuffle();
      selectedBooks.addAll(recommendedBooks.take(numRecommended));

      // Randomly select from global pool
      searchedBooks.shuffle();
      bookmarks.shuffle();
      selectedBooks.addAll(searchedBooks.take(numRandom ~/ 2));
      selectedBooks.addAll(bookmarks.take(numRandom ~/ 2));

      // Shuffle final selection for random order display
      selectedBooks.shuffle();
      _randomBooks = selectedBooks;
    } catch (e) {
      print('Error fetching books with collaborative filtering: $e');
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
          title: '| Trendy Books',
          fontSize: 25,
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
                                // Fallback to a default book icon if image fails to load
                                return Container(
                                  width: 150,
                                  height: 220,
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.menu_book,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                );
                              },
                              loadingBuilder: (context, child, loadingProgress) {
                                // Show a loading indicator while the image is loading
                                if (loadingProgress == null) return child;
                                return Container(
                                  width: 150,
                                  height: 220,
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                                    ),
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
