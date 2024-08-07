import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:book_Verse/features/home/screens/user/mark/provider.dart';
import 'package:book_Verse/features/home/screens/user/mark/requestssss.dart'; // Update this import
import '../../../../../books/course_book_detail_screen.dart'; // Import the CourseBookDetailScreen

class MarkApp extends StatelessWidget {
  const MarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookmarkProvider(),
      child: BookmarkScreen(),
    );
  }
}

class BookmarkScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bookmarks = Provider.of<BookmarkProvider>(context).bookmarks;

    // Group bookmarks by title and count the number of copies
    final bookCounts = <String, int>{};
    for (var book in bookmarks) {
      final title = book['title'];
      bookCounts[title] = (bookCounts[title] ?? 0) + 1;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bookmarks & Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Bookmarks',
              style: Theme.of(context).textTheme.headlineMedium, // Adjust the style as needed
            ),
            const SizedBox(height: 16),
            Expanded(
              child: bookCounts.isEmpty
                  ? const Center(child: Text('No bookmarks yet.'))
                  : ListView.builder(
                itemCount: bookCounts.keys.length,
                itemBuilder: (context, index) {
                  final title = bookCounts.keys.elementAt(index);
                  final count = bookCounts[title]!;

                  // Find the book details for this title (assuming there's only one unique book with that title in the list)
                  final book = bookmarks.firstWhere((b) => b['title'] == title);

                  return ListTile(
                    title: Text('$title (Copies: $count)'),
                    subtitle: Text(book['writer']),
                    leading: book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                        ? Image.network(
                      book['imageUrl'],
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.book);
                      },
                    )
                        : const Icon(Icons.book),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _removeBookmark(context, book);
                      },
                    ),
                    onTap: () {
                      // Navigate to the CourseBookDetailScreen when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CourseBookDetailScreen(
                            title: book['title'],
                            writer: book['writer'],
                            imageUrl: book['imageUrl'] ?? '', // Handle possible null values
                            course: book['course'] ?? '', // Handle possible null values
                            summary: book['summary'] ?? '', // Handle possible null values
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Requested Books',
              style: Theme.of(context).textTheme.headlineMedium, // Adjust the style as needed
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestedListScreen(), // Ensure you have the correct screen
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green, // Button color
                minimumSize: Size(double.infinity, 50), // Resize the button
              ),
              child: const Text('View Requested Books'),
            ),
            const SizedBox(height: 80), // Add space for the FloatingActionButton
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _saveBookmarksToRequests(context),
        child: const Icon(Icons.save),
      ),
    );
  }

  Future<void> _removeBookmark(BuildContext context, Map<String, dynamic> book) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }
    final userId = user.uid;
    final docId = book['id'];

    try {
      // Remove from Firestore
      await FirebaseFirestore.instance.collection('bookmarks').doc(docId).delete();
      // Update BookmarkProvider
      Provider.of<BookmarkProvider>(context, listen: false).removeBookmark(book);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${book['title']} removed from bookmarks')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to remove bookmark: $error')));
    }
  }

  Future<void> _saveBookmarksToRequests(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in')));
      return;
    }
    final userId = user.uid;
    final bookmarks = Provider.of<BookmarkProvider>(context, listen: false).bookmarks;

    try {
      await FirebaseFirestore.instance.collection('requests').add({
        'userId': userId,
        'books': bookmarks,
        'requestedAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmarked books saved to requests')));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save bookmarks: $error')));
    }
  }
}
