import 'package:book_Verse/books/detailScreen/pdflistscreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import '../../features/home/screens/user/mark/provider.dart';

class CourseBookDetailScreen extends StatefulWidget {
  final String title;
  final String writer;
  final String imageUrl;
  final String course;
  final String summary;

  const CourseBookDetailScreen({
    Key? key,
    required this.title,
    required this.writer,
    required this.imageUrl,
    required this.course,
    required this.summary,
  }) : super(key: key);

  @override
  _CourseBookDetailScreenState createState() => _CourseBookDetailScreenState();
}

class _CourseBookDetailScreenState extends State<CourseBookDetailScreen> {
  bool isBookmarked = false;
  bool isOutOfStock = false;
  late String userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid;
      await _checkIfBookmarked();
      await _checkAvailability();
    }
  }

  Future<void> _checkIfBookmarked() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookmarks')
        .where('title', isEqualTo: widget.title)
        .where('userId', isEqualTo: userId)
        .get();

    setState(() {
      isBookmarked = snapshot.docs.isNotEmpty;
    });
  }

  Future<void> _checkAvailability() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: widget.title)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final bookData = snapshot.docs.first.data();
      setState(() {
        isOutOfStock = (bookData['numberOfCopies'] ?? 0) <= 0;
      });
    }
  }

  void _toggleBookmark() {
    if (isOutOfStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('This book is out of stock and cannot be added.')),
      );
      return;
    }

    final bookData = {
      'title': widget.title,
      'writer': widget.writer,
      'imageUrl': widget.imageUrl,
      'course': widget.course,
      'summary': widget.summary,
      'userId': userId,
    };

    if (isBookmarked) {
      _removeBookmark(bookData);
    } else {
      _addBookmark(bookData);
    }
  }

  Future<void> _addBookmark(Map<String, dynamic> bookData) async {
    try {
      final bookSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isEqualTo: widget.title)
          .limit(1)
          .get();

      if (bookSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book not found')));
        return;
      }

      final bookId = bookSnapshot.docs.first.id;

      final bookDataWithId = {
        ...bookData,
        'bookId': bookId,
        'timestamp': FieldValue.serverTimestamp(),
      };

      final docRef = await FirebaseFirestore.instance.collection('bookmarks').add(bookDataWithId);
      Provider.of<BookmarkProvider>(context, listen: false).addBookmark({
        ...bookDataWithId,
        'id': docRef.id,
      });
      setState(() {
        isBookmarked = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.title} Added')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to Add: $error')));
    }
  }

  Future<void> _removeBookmark(Map<String, dynamic> bookData) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('bookmarks')
        .where('title', isEqualTo: widget.title)
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final docId = snapshot.docs.first.id;
      try {
        await FirebaseFirestore.instance.collection('bookmarks').doc(docId).delete();
        Provider.of<BookmarkProvider>(context, listen: false).removeBookmark({
          ...bookData,
          'id': docId,
        });
        setState(() {
          isBookmarked = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${widget.title} removed')));
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove: $error')));
      }
    }
  }

  Future<void> _viewPDFs() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('books')
        .where('title', isEqualTo: widget.title)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty || snapshot.docs.first.data()['pdfs'] == null) {
      _showNoPDFsDialog();
      return;
    }

    final pdfs = List<Map<String, dynamic>>.from(snapshot.docs.first.data()['pdfs']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFListScreen2(pdfs: pdfs),
      ),
    );
  }

  void _showNoPDFsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('No PDFs Found'),
        content: Text('No PDFs are available for this book.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        letterSpacing: 1.2,
                        shadows: [
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
                    icon: Icon(
                      isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.white,
                      size: 28,
                    ),
                    onPressed: _toggleBookmark,
                  ),
                  IconButton(
                    icon: const Icon(Icons.picture_as_pdf, color: Colors.white, size: 28),
                    onPressed: _viewPDFs,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 18),
        child: ListView(
          children: [
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 16,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    widget.imageUrl,
                    width: 200,
                    height: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 200,
                        height: 300,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text('Image not available', style: TextStyle(color: Colors.red)),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Title', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF4A4E69),
                      fontWeight: FontWeight.bold,
                    )),
                    Text(widget.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22223B),
                    )),
                    const SizedBox(height: 10),
                    Text('Writer', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF4A4E69),
                      fontWeight: FontWeight.bold,
                    )),
                    Text(widget.writer, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 10),
                    Text('Course', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF4A4E69),
                      fontWeight: FontWeight.bold,
                    )),
                    Text(widget.course, style: Theme.of(context).textTheme.bodyLarge),
                    const SizedBox(height: 18),
                    Text('Summary', style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: const Color(0xFF4A4E69),
                      fontWeight: FontWeight.bold,
                    )),
                    Text(widget.summary, style: Theme.of(context).textTheme.bodyMedium),
                    if (isOutOfStock) ...[
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            'This book is currently out of stock.',
                            style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isBookmarked ? const Color(0xFF4A4E69) : const Color(0xFF9A8C98),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
                  label: Text(isBookmarked ? 'Bookmarked' : 'Bookmark'),
                  onPressed: _toggleBookmark,
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A4E69),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('View PDFs'),
                  onPressed: _viewPDFs,
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
