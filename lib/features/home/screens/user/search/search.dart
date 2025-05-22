import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../../books/detailScreen/course_book_detail_screen.dart';
import '../pdfView/pdflist.dart';
import 'BooksAll.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String query = '';
  List<DocumentSnapshot> searchResults = [];
  bool isLoading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _deleteSearchedBooks(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('searchedBooks')
          .where('userId', isEqualTo: userId)
          .get();
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (_) {}
  }

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }
    setState(() {
      isLoading = true;
    });

    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await _deleteSearchedBooks(userId);
        final uppercaseQuery = query.toUpperCase();
        final snapshot = await FirebaseFirestore.instance.collection('books').get();
        final results = snapshot.docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final bookTitle = (data['title'] as String?)?.toUpperCase() ?? '';
          final bookWriter = (data['writer'] as String?)?.toUpperCase() ?? '';
          return bookTitle.contains(uppercaseQuery) || bookWriter.contains(uppercaseQuery);
        }).toList();
        if (results.isNotEmpty) {
          await _saveSearchedBooks(query, userId, results);
        }
        setState(() {
          searchResults = results;
        });
      } else {
        setState(() {
          searchResults = [];
        });
      }
    } catch (_) {
      setState(() {
        searchResults = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _saveSearchedBooks(String searchQuery, String userId, List<QueryDocumentSnapshot> results) async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      for (var doc in results) {
        final bookId = doc.id;
        final book = doc.data() as Map<String, dynamic>;
        final title = book['title']?.toString() ?? 'No title';
        final writer = book['writer']?.toString() ?? 'Unknown author';
        final imageUrl = book['imageUrl']?.toString() ?? '';
        final course = book['course']?.toString() ?? '';
        final summary = book['summary']?.toString() ?? 'No summary available';
        if (title.trim().toLowerCase() == searchQuery.trim().toLowerCase()) {
          final existingBookSnapshot = await FirebaseFirestore.instance
              .collection('searchedBooks')
              .where('userId', isEqualTo: userId)
              .where('bookId', isEqualTo: bookId)
              .get();
          if (existingBookSnapshot.docs.isEmpty) {
            final docRef = FirebaseFirestore.instance.collection('searchedBooks').doc();
            batch.set(docRef, {
              'userId': userId,
              'bookId': bookId,
              'title': title,
              'writer': writer,
              'imageUrl': imageUrl,
              'course': course,
              'summary': summary,
              'searchedAt': FieldValue.serverTimestamp(),
            });
          }
        }
      }
      await batch.commit();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(90),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28),
              bottomRight: Radius.circular(28),
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
              child: Row(
                children: [
                  const SizedBox(width: 10),
                  const Icon(Icons.search, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      'Discover Books',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                        shadows: const [
                          Shadow(
                            color: Colors.black26,
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white),
                    tooltip: 'All PDFs',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllPDFsScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu_book, color: Colors.white),
                    tooltip: 'All Books',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AllBooksScreen()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: Column(
          children: [
            // Modern Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 18),
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(30),
                child: TextField(
                  onChanged: (value) {
                    setState(() {
                      query = value;
                    });
                    _searchBooks(value);
                  },
                  style: const TextStyle(fontSize: 18),
                  decoration: InputDecoration(
                    hintText: 'Search by title or author...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Color(0xFF4F8FFF)),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            // Results
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : searchResults.isEmpty
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/empty_search.png',
                              width: 160,
                              height: 160,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(Icons.search_off, size: 80, color: Colors.grey),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No results found',
                              style: TextStyle(fontSize: 20, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: searchResults.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final book = searchResults[index].data() as Map<String, dynamic>;
                            final title = book['title'] ?? 'No title';
                            final writer = book['writer'] ?? 'Unknown author';
                            final imageUrl = book['imageUrl'] ?? '';
                            final course = book['course'] ?? '';
                            final summary = book['summary'] ?? 'No summary available';

                            return GestureDetector(
                              onTap: () {
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
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.10),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    // Book Image
                                    Container(
                                      margin: const EdgeInsets.all(12),
                                      width: 60,
                                      height: 90,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: const Color(0xFFF0F4FA),
                                        image: imageUrl.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(imageUrl),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                      ),
                                      child: imageUrl.isEmpty
                                          ? const Icon(Icons.book, size: 40, color: Color(0xFF4F8FFF))
                                          : null,
                                    ),
                                    // Book Info
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xFF222B45),
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 6),
                                            Row(
                                              children: [
                                                const Icon(Icons.person, size: 16, color: Color(0xFF4F8FFF)),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    writer,
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                      color: Color(0xFF6B7A8F),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (course.isNotEmpty) ...[
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  const Icon(Icons.school, size: 15, color: Color(0xFF38C8FF)),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    course,
                                                    style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Color(0xFF38C8FF),
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Arrow Icon
                                    Container(
                                      margin: const EdgeInsets.only(right: 16),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4F8FFF).withOpacity(0.08),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF4F8FFF), size: 22),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
