import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../common/widgets/texts/section_heading.dart';
import 'detailScreen/course_book_detail_screen.dart';

class TPopularBooks extends StatefulWidget {
  const TPopularBooks({super.key});

  @override
  _TPopularBooksState createState() => _TPopularBooksState();
}

class _TPopularBooksState extends State<TPopularBooks> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _recommendedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRecommendedBooks();
  }

  Future<void> _fetchRecommendedBooks() async {
    try {
      // Fetch the user's bookmarked books for collaborative filtering
      final userId = "currentUserId"; // Replace with the actual user ID
      final bookmarkedBooks = await _firestore
          .collection('bookmarks')
          .where('userId', isEqualTo: userId)
          .get();

      Set<String> userBookIds = {}; // Collect all book IDs that the user has bookmarked
      for (var doc in bookmarkedBooks.docs) {
        userBookIds.add(doc['bookId']);
      }

      // Perform collaborative filtering to find similar users
      final collaborativeRecommendations = await _fetchCollaborativeRecommendations(userId, userBookIds);

      // Perform content-based filtering to recommend books based on user's preferences
      final contentBasedRecommendations = await _fetchContentBasedRecommendations(userBookIds);

      // Combine both recommendations (hybrid approach)
      final hybridRecommendations = _combineRecommendations(
        collaborativeRecommendations,
        contentBasedRecommendations,
      );

      setState(() {
        _recommendedBooks = hybridRecommendations;
      });
    } catch (e) {
      print('Error fetching recommendations: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchCollaborativeRecommendations(String userId, Set<String> userBookIds) async {
    final allBookmarksSnapshot = await _firestore.collection('bookmarks').get();
    Map<String, Set<String>> userToBookMap = {};

    for (var doc in allBookmarksSnapshot.docs) {
      final data = doc.data();
      final otherUserId = data['userId'];
      final bookId = data['bookId'];
      if (!userToBookMap.containsKey(otherUserId)) {
        userToBookMap[otherUserId] = {};
      }
      userToBookMap[otherUserId]!.add(bookId);
    }

    // Compute similarity with other users
    Map<String, double> similarityScores = {};
    for (var otherUserId in userToBookMap.keys) {
      if (otherUserId == userId) continue;

      final otherUserBooks = userToBookMap[otherUserId]!;
      final commonBooks = userBookIds.intersection(otherUserBooks).length;
      final totalBooks = userBookIds.union(otherUserBooks).length;
      double similarity = commonBooks / totalBooks;

      if (similarity > 0.2) {
        similarityScores[otherUserId] = similarity;
      }
    }

    // Get books liked by similar users but not by the current user
    Set<String> recommendedBookIds = {};
    for (var similarUserId in similarityScores.keys) {
      final similarUserBooks = userToBookMap[similarUserId]!;
      for (var bookId in similarUserBooks) {
        if (!userBookIds.contains(bookId)) {
          recommendedBookIds.add(bookId);
        }
      }
    }

    // Fetch book details for the recommended books
    final List<Map<String, dynamic>> recommendedBooks = await Future.wait(
      recommendedBookIds.map((bookId) async {
        final bookDoc = await _firestore.collection('books').doc(bookId).get();
        return bookDoc.data()!;
      }),
    );

    return recommendedBooks;
  }

  Future<List<Map<String, dynamic>>> _fetchContentBasedRecommendations(Set<String> userBookIds) async {
    // Extract features of user's liked books (genre, tags)
    Set<String> userGenres = {};
    Set<String> userTags = {};

    for (var bookId in userBookIds) {
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      final bookData = bookDoc.data();
      userGenres.addAll(List<String>.from(bookData!['genre'] ?? []));
      userTags.addAll(List<String>.from(bookData['tags'] ?? []));
    }

    // Fetch all books
    final booksSnapshot = await _firestore.collection('books').get();

    // Compute similarity between user's preferences and each book
    List<Map<String, dynamic>> contentBasedBooks = [];
    for (var book in booksSnapshot.docs) {
      final bookData = book.data();
      final genreSimilarity = _computeJaccardSimilarity(userGenres, Set<String>.from(bookData['genre'] ?? []));
      final tagSimilarity = _computeJaccardSimilarity(userTags, Set<String>.from(bookData['tags'] ?? []));

      if (genreSimilarity > 0.3 || tagSimilarity > 0.3) {
        bookData['score'] = (genreSimilarity + tagSimilarity) / 2;
        contentBasedBooks.add(bookData);
      }
    }

    // Sort by similarity score
    contentBasedBooks.sort((a, b) => b['score'].compareTo(a['score']));

    return contentBasedBooks;
  }

  double _computeJaccardSimilarity(Set<String> set1, Set<String> set2) {
    final intersection = set1.intersection(set2).length;
    final union = set1.union(set2).length;
    return union == 0 ? 0 : intersection / union;
  }

  List<Map<String, dynamic>> _combineRecommendations(
      List<Map<String, dynamic>> collaborativeRecommendations,
      List<Map<String, dynamic>> contentBasedRecommendations,
      ) {
    // Assign weights to collaborative and content-based recommendations
    const collaborativeWeight = 0.5;
    const contentBasedWeight = 0.5;

    Map<String, double> hybridScores = {};

    // Process content-based recommendations
    for (var book in contentBasedRecommendations) {
      hybridScores[book['bookId']] = (book['score'] ?? 0) * contentBasedWeight;
    }

    // Process collaborative recommendations
    for (var book in collaborativeRecommendations) {
      if (hybridScores.containsKey(book['bookId'])) {
        hybridScores[book['bookId']] = hybridScores[book['bookId']]! + collaborativeWeight;
      } else {
        hybridScores[book['bookId']] = collaborativeWeight;
      }
    }

    // Sort books by the hybrid score
    List<Map<String, dynamic>> hybridRecommendations = [];
    for (var bookId in hybridScores.keys) {
      final bookDoc = _recommendedBooks.firstWhere((book) => book['bookId'] == bookId);
      bookDoc['score'] = hybridScores[bookId];
      hybridRecommendations.add(bookDoc);
    }

    hybridRecommendations.sort((a, b) => b['score'].compareTo(a['score']));
    return hybridRecommendations;
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
          title: 'Recommended Books',
          onPressed: () {
            // Handle view all button press
          },
        ),
        SizedBox(height: 10),
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _recommendedBooks.isEmpty
            ? Center(child: Text('No recommended books found.'))
            : SizedBox(
          height: 300, // Set a fixed height for the carousel
          child: CarouselSlider.builder(
            itemCount: _recommendedBooks.length,
            itemBuilder: (context, index, realIndex) {
              final book = _recommendedBooks[index];
              final imageUrl = book['imageUrl'] ?? 'https://example.com/placeholder.jpg';
              final title = book['title'] ?? 'Unknown Title';
              final writer = book['writer'] ?? 'Unknown Writer';

              return GestureDetector(
                onTap: () => _navigateToDetailPage(book),
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 5),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Make Column size flexible
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          imageUrl,
                          width: 150,
                          height: 220,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Text(
                                'Image not available',
                                style: TextStyle(color: Colors.red),
                              ),
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 5),
                      Text(
                        writer,
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
            options: CarouselOptions(
              height: 300,
              viewportFraction: 0.5,
              enlargeCenterPage: false,
              autoPlay: false,
              enableInfiniteScroll: true,
            ),
          ),
        ),
      ],
    );
  }
}
