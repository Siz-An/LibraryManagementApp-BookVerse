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
  State<TRandomBooks> createState() => _RandomBooksState();
}

class _RandomBooksState extends State<TRandomBooks> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _randomBooks = [];
  bool _isLoading = true;
  List<String> _globalWriters = [];

  static const double _similarityThreshold = 0.2;
  static const int _maxRecommendations = 10;
  static const int _topWritersLimit = 50;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() => _isLoading = true);

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      print('Error: User not logged in.');
      setState(() => _isLoading = false);
      return;
    }

    await _fetchCollaborativeFiltering(currentUser.uid);
  }

  Future<void> _fetchCollaborativeFiltering(String currentUserId) async {
    try {
      final allBookmarksSnapshot =
          await _firestore.collection('bookmarks').get();
      final allBookmarks =
          allBookmarksSnapshot.docs.map((doc) => doc.data()).toList();

      if (allBookmarks.isEmpty) {
        _setRandomBooks([]);
        return;
      }

      // Build global feature space (limit to top writers for performance)
      _buildGlobalWriters(allBookmarks);

      // Group bookmarks by userId
      final userBookmarks = _groupBookmarksByUser(allBookmarks);

      final currentUserBookmarks = userBookmarks[currentUserId] ?? [];
      if (currentUserBookmarks.isEmpty) {
        _setRandomBooks([]);
        return;
      }

      // Create vectors and compute similarity
      final currentUserVector = _createUserVector(currentUserBookmarks);
      final similarityScores =
          _computeSimilarityScores(currentUserId, userBookmarks, currentUserVector);

      // Find top similar users
      final topUsers = similarityScores.entries
          .where((e) => e.value > _similarityThreshold)
          .toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      if (topUsers.isEmpty) {
        _setRandomBooks([]);
        return;
      }

      // Get recommendations
      final recommendations = _generateRecommendations(
        currentUserId,
        currentUserBookmarks,
        topUsers,
        userBookmarks,
      );

      _setRandomBooks(recommendations);
    } catch (e) {
      print('Error fetching recommended books: $e');
      _setRandomBooks([]);
    }
  }

  void _buildGlobalWriters(List<Map<String, dynamic>> allBookmarks) {
    final writerCounts = <String, int>{};

    for (var b in allBookmarks) {
      final writer = (b['writer'] as String?)?.trim().toLowerCase();
      if (writer != null && writer.isNotEmpty) {
        writerCounts[writer] = (writerCounts[writer] ?? 0) + 1;
      }
    }

    // Get top writers by frequency
    final sortedEntries = writerCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    _globalWriters = sortedEntries.take(_topWritersLimit).map((e) => e.key).toList();
  }  Map<String, List<Map<String, dynamic>>> _groupBookmarksByUser(
    List<Map<String, dynamic>> allBookmarks,
  ) {
    final userBookmarks = <String, List<Map<String, dynamic>>>{};

    for (var b in allBookmarks) {
      final uid = b['userId'] as String?;
      if (uid == null) continue;
      userBookmarks.putIfAbsent(uid, () => []);
      userBookmarks[uid]!.add(b);
    }

    return userBookmarks;
  }

  Map<String, double> _computeSimilarityScores(
    String currentUserId,
    Map<String, List<Map<String, dynamic>>> userBookmarks,
    List<double> currentUserVector,
  ) {
    final similarityScores = <String, double>{};

    userBookmarks.forEach((uid, bookmarks) {
      if (uid == currentUserId) return;
      similarityScores[uid] = _cosineSimilarity(
        currentUserVector,
        _createUserVector(bookmarks),
      );
    });

    return similarityScores;
  }

  List<Map<String, dynamic>> _generateRecommendations(
    String currentUserId,
    List<Map<String, dynamic>> currentUserBookmarks,
    List<MapEntry<String, double>> topUsers,
    Map<String, List<Map<String, dynamic>>> userBookmarks,
  ) {
    final currentUserWriters = currentUserBookmarks
        .map((b) => (b['writer'] as String?)?.trim().toLowerCase())
        .whereType<String>()
        .toSet();

    final recommendedBooksMap = <String, Map<String, dynamic>>{};
    final bookScores = <String, double>{};
    final currentUserBookIds = currentUserBookmarks
        .map((b) => b['bookId'] as String?)
        .whereType<String>()
        .toSet();

    for (var entry in topUsers) {
      final userId = entry.key;
      final similarity = entry.value;

      for (var book in userBookmarks[userId]!) {
        final bookId = book['bookId'] as String?;
        final writer = (book['writer'] as String?)?.trim().toLowerCase();

        // Validation checks
        if (bookId == null || writer == null) continue;
        if (currentUserBookIds.contains(bookId)) continue;
        if (!currentUserWriters.contains(writer)) continue;

        // Update recommendation
        recommendedBooksMap[bookId] = book;
        bookScores[bookId] = (bookScores[bookId] ?? 0) + similarity;
      }
    }

    // Sort and return top recommendations
    final sortedBooks = bookScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedBooks
        .take(_maxRecommendations)
        .map((e) => recommendedBooksMap[e.key]!)
        .toList();
  }

  List<double> _createUserVector(List<Map<String, dynamic>> bookmarks) {
    final counts = <String, int>{};

    for (var b in bookmarks) {
      final w = (b['writer'] as String?)?.trim().toLowerCase();
      if (w != null && w.isNotEmpty) {
        counts[w] = (counts[w] ?? 0) + 1;
      }
    }

    return _globalWriters
        .map((w) => counts[w]?.toDouble() ?? 0.0)
        .toList();
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.isEmpty || b.isEmpty) return 0.0;

    double dot = 0.0, magA = 0.0, magB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      magA += a[i] * a[i];
      magB += b[i] * b[i];
    }

    magA = sqrt(magA);
    magB = sqrt(magB);

    if (magA == 0 || magB == 0) return 0.0;

    return dot / (magA * magB);
  }

  void _navigateToDetailPage(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseBookDetailScreen(
          title: book['title'] ?? 'Unknown Title',
          writer: book['writer'] ?? 'Unknown Writer',
          imageUrl: book['imageUrl'] ??
              'https://example.com/placeholder.jpg',
          course: book['course'] ?? 'No course info available',
          summary: book['summary'] ?? 'No summary available',
        ),
      ),
    );
  }

  void _setRandomBooks(List<Map<String, dynamic>> books) {
    setState(() {
      _randomBooks = books;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TSectionHeading(
          title: '| Recommended for You',
          fontSize: 25,
          onPressed: () {},
        ),
        const SizedBox(height: 10),
        _buildContent(),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_randomBooks.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCarousel();
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: const [
          Text(
            'Bookmark books by your favorite writers to see personalized recommendations!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 10),
          Text(
            "We'll recommend books by the same writers that readers with similar tastes have enjoyed",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildCarousel() {
    return SizedBox(
      height: 300,
      child: CarouselSlider.builder(
        itemCount: _randomBooks.length,
        itemBuilder: (context, index, realIndex) =>
            _buildBookCard(_randomBooks[index]),
        options: CarouselOptions(
          height: 300,
          viewportFraction: 0.5,
          enlargeCenterPage: false,
          autoPlay: false,
          enableInfiniteScroll: true,
        ),
      ),
    );
  }

  Widget _buildBookCard(Map<String, dynamic> book) {
    final imageUrl =
        book['imageUrl'] ?? 'https://example.com/placeholder.jpg';
    final title = book['title'] ?? 'Unknown Title';
    final writer = book['writer'] ?? 'Unknown Writer';

    return GestureDetector(
      onTap: () => _navigateToDetailPage(book),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: _buildBookImage(imageUrl),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 5),
            Text(
              writer,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookImage(String imageUrl) {
    return Image.network(
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
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return Container(
          width: 150,
          height: 220,
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              value: progress.expectedTotalBytes != null
                  ? progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          ),
        );
      },
    );
  }
}







