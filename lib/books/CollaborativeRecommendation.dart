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

      // Create a feature vector for the current user
      List<double> currentUserVector = _createUserVector(currentUserBookmarks);

      // Fetch all bookmarks to find similar users
      final allBookmarksSnapshot = await _firestore.collection('bookmarks').get();
      final allBookmarks = allBookmarksSnapshot.docs.map((doc) => doc.data()).toList();

      // Group bookmarks by userId
      Map<String, List<Map<String, dynamic>>> userBookmarks = {};
      for (var bookmark in allBookmarks) {
        final userId = bookmark['userId'] as String?;
        if (userId != null) {
          userBookmarks.putIfAbsent(userId, () => []);
          userBookmarks[userId]!.add(bookmark);
        }
      }

      // Calculate similarity scores for all other users
      Map<String, double> userSimilarityScores = {};
      for (var entry in userBookmarks.entries) {
        final userId = entry.key;
        final bookmarks = entry.value;

        // Skip current user
        if (userId == currentUserId) continue;

        // Create feature vector for other user
        List<double> otherUserVector = _createUserVector(bookmarks);

        // Calculate cosine similarity
        double similarity = _cosineSimilarity(currentUserVector, otherUserVector);
        userSimilarityScores[userId] = similarity;
      }

      // Find top similar users (threshold: similarity > 0.2 for stricter matching)
      final topSimilarUsers = userSimilarityScores.entries
          .where((entry) => entry.value > 0.2)
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

      // Collect recommended books from similar users based on writers
      Map<String, Map<String, dynamic>> recommendedBooksMap = {};
      Map<String, double> bookScores = {};

      // Get writers from current user's bookmarks
      Set<String> currentUserWriters = {};
      for (var bookmark in currentUserBookmarks) {
        final writer = (bookmark['writer'] as String?)?.trim().toLowerCase();
        if (writer != null && writer.isNotEmpty) {
          currentUserWriters.add(writer);
        }
      }

      for (var similarUser in topSimilarUsers) {
        final userId = similarUser.key;
        final similarity = similarUser.value;

        for (var bookmark in userBookmarks[userId]!) {
          final bookId = bookmark['bookId'] as String?;
          final writer = (bookmark['writer'] as String?)?.trim().toLowerCase();
          
          // Skip if user already bookmarked this book
          if (currentUserBookmarks.any((b) => b['bookId'] == bookId)) {
            continue;
          }

          // Only recommend books by writers the current user has bookmarked (writer-based filtering)
          if (writer != null && currentUserWriters.contains(writer)) {
            // Add or update book score (weighted by user similarity)
            if (bookId != null) {
              recommendedBooksMap[bookId] = bookmark;
              bookScores[bookId] = (bookScores[bookId] ?? 0) + similarity;
            }
          }
        }
      }

      // Sort by score and take top 10
      final sortedBooks = bookScores.entries
          .toList()
          ..sort((a, b) => b.value.compareTo(a.value));

      _randomBooks = sortedBooks.take(10).map((entry) {
        return recommendedBooksMap[entry.key]!;
      }).toList();

    } catch (e) {
      print('Error fetching books with collaborative filtering: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Create a feature vector based on writers in user's bookmarks
  List<double> _createUserVector(List<Map<String, dynamic>> bookmarks) {
    // Extract all writers and count their occurrences
    Map<String, int> writerCounts = {};
    
    for (var bookmark in bookmarks) {
      final writer = bookmark['writer'] as String?;
      
      if (writer != null && writer.isNotEmpty) {
        final normalizedWriter = writer.trim().toLowerCase();
        writerCounts[normalizedWriter] = (writerCounts[normalizedWriter] ?? 0) + 1;
      }
    }
    
    // Create a sorted list of writers by frequency (most common first)
    final sortedWriters = writerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    // Create a limited feature space (top 20 writers)
    List<String> featureSpace = sortedWriters.take(20).map((e) => e.key).toList();
    
    // Create frequency vector based on writer counts
    List<double> vector = [];
    for (var writer in featureSpace) {
      vector.add(writerCounts[writer]!.toDouble());
    }
    
    // Handle case where user has no valid writers
    return vector.isEmpty ? [0.0] : vector;
  }

  // Helper method to compute cosine similarity between two vectors
  double _cosineSimilarity(List<double> vectorA, List<double> vectorB) {
    // Pad vectors to same length
    int maxLen = max(vectorA.length, vectorB.length);
    List<double> a = List<double>.from(vectorA)..addAll(List.filled(max(0, maxLen - vectorA.length), 0.0));
    List<double> b = List<double>.from(vectorB)..addAll(List.filled(max(0, maxLen - vectorB.length), 0.0));

    // Calculate dot product
    double dotProduct = 0.0;
    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
    }

    // Calculate magnitudes
    double magnitudeA = 0.0;
    double magnitudeB = 0.0;
    
    for (int i = 0; i < a.length; i++) {
      magnitudeA += a[i] * a[i];
      magnitudeB += b[i] * b[i];
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
          title: '| Recommended for You',
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
                      'Bookmark books by your favorite writers to see personalized recommendations!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'We\'ll recommend books by the same writers that readers with similar tastes have enjoyed',
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
          height: 300,
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