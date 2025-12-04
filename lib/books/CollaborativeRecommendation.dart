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
      // Check if user has bookmarked any books
      final currentUserBookmarksSnapshot = await _firestore
          .collection('bookmarks')
          .where('userId', isEqualTo: currentUserId)
          .limit(1) // Just check if any bookmarks exist
          .get();

      // If user hasn't bookmarked any books, show empty state
      if (currentUserBookmarksSnapshot.docs.isEmpty) {
        setState(() {
          _randomBooks = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch user-specific bookmarks
      final currentUserBookmarks = currentUserBookmarksSnapshot.docs.map((doc) => doc.data()).toList();

      // Extract writers from user's bookmarked books
      final Set<String> userWriters = {};
      for (var bookmark in currentUserBookmarks) {
        final writer = bookmark['writer'] as String?;
        if (writer != null && writer.isNotEmpty) {
          userWriters.add(writer.trim());
        }
      }

      // If no writers found in user's bookmarks, show empty state
      if (userWriters.isEmpty) {
        setState(() {
          _randomBooks = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch all bookmarks to find books by the same writers
      final allBookmarksSnapshot = await _firestore.collection('bookmarks').get();
      final allBookmarks = allBookmarksSnapshot.docs.map((doc) => doc.data()).toList();

      // Find books by the same writers (excluding user's own bookmarks)
      List<Map<String, dynamic>> recommendedBooks = [];
      for (var bookmark in allBookmarks) {
        final writer = bookmark['writer'] as String?;
        final userId = bookmark['userId'] as String?;
        
        // Check if book is by same writer but not bookmarked by current user
        if (writer != null && 
            writer.isNotEmpty && 
            userWriters.contains(writer.trim()) && 
            userId != currentUserId) {
          recommendedBooks.add(bookmark);
        }
      }

      // Remove duplicates based on bookId
      final Set<String> seenBookIds = {};
      recommendedBooks = recommendedBooks.where((book) {
        final bookId = book['bookId'] as String?;
        if (bookId != null && !seenBookIds.contains(bookId)) {
          seenBookIds.add(bookId);
          return true;
        }
        return false;
      }).toList();

      // Limit to 10 recommendations
      recommendedBooks.shuffle();
      _randomBooks = recommendedBooks.take(10).toList();
    } catch (e) {
      print('Error fetching books with collaborative filtering: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Helper method to compute cosine similarity between two vectors
  double _cosineSimilarity(List<double> vectorA, List<double> vectorB) {
    // Calculate dot product
    double dotProduct = 0.0;
    for (int i = 0; i < vectorA.length; i++) {
      dotProduct += vectorA[i] * vectorB[i];
    }

    // Calculate magnitudes
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;
    
    for (int i = 0; i < vectorA.length; i++) {
      magnitudeA += vectorA[i] * vectorA[i];
      magnitudeB += vectorB[i] * vectorB[i];
    }
    
    magnitudeA = sqrt(magnitudeA);
    magnitudeB = sqrt(magnitudeB);

    // Avoid division by zero
    if (magnitudeA == 0 || magnitudeB == 0) {
      return 0.0;
    }

    return dotProduct / (magnitudeA * magnitudeB);
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
            ? Center(
                child: Column(
                  children: [
                    Text(
                      'Bookmark some books to see personalized recommendations!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Books you bookmark will appear here as recommendations',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              )
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