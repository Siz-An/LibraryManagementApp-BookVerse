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
  bool isOutOfStock = false; // Track if the book is out of stock
  late String userId;

  @override
  void initState() {
    super.initState();
    _initializeUserId();
  }

  Future<void> _initializeUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userId = user.uid; // Get the user ID from Firebase Auth
      await _checkIfBookmarked();
      await _checkAvailability();
    } else {
      // Handle the case where the user is not logged in
      // e.g., navigate to the login screen
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
        .collection('books') // Adjust the collection name as needed
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
        SnackBar(content: Text('This book is out of stock and cannot be Added.')),
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
      // Fetch the bookId from the 'books' collection based on the book's title
      final bookSnapshot = await FirebaseFirestore.instance
          .collection('books')
          .where('title', isEqualTo: widget.title) // Use an appropriate field to find the book
          .limit(1)
          .get();

      if (bookSnapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Book not found')));
        return;
      }

      final bookId = bookSnapshot.docs.first.id;

      // Include 'bookId' in the bookData
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
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove : $error')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                widget.imageUrl,
                width: 190,
                height: 250,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(child: Text('Image not available', style: TextStyle(color: Colors.red)));
                },
              ),
            ),
            const SizedBox(height: 16),
            Text('Title: ${widget.title}', style: Theme.of(context).textTheme.bodySmall),
            Text('Writer: ${widget.writer}', style: Theme.of(context).textTheme.bodySmall),
            Text('Course: ${widget.course}', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 16),
            Text('Summary:', style: Theme.of(context).textTheme.bodySmall),
            Text(widget.summary),
            if (isOutOfStock) ...[
              const SizedBox(height: 16),
              Text('This book is currently out of stock.', style: TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}
