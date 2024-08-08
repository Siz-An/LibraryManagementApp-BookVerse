import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:book_Verse/features/home/screens/user/mark/provider.dart';
import 'package:book_Verse/features/home/screens/user/mark/requestssss.dart'; // Update this import
import '../../../../../books/detailScreen/course_book_detail_screen.dart'; // Import the CourseBookDetailScreen

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

    // Filter out bookmarks with null or empty titles
    final filteredBookmarks = bookmarks.where((book) {
      final title = book['title'];
      return title != null && title.isNotEmpty;
    }).toList();

    // Group bookmarks by title and count the number of copies
    final bookCounts = <String, int>{};
    for (var book in filteredBookmarks) {
      final title = book['title']!;
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
              style: Theme.of(context).textTheme.headlineMedium,
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

                  // Find the book details for this title
                  final book = filteredBookmarks.firstWhere(
                        (b) => b['title'] == title,
                    orElse: () => {
                      'title': '', // This should never be used
                      'writer': '',
                      'imageUrl': '',
                      'course': '',
                      'summary': '',
                      'bookId': '', // Ensure this is included
                    },
                  );

                  return ListTile(
                    title: Text('$title (Copies: $count)'),
                    subtitle: Text(book['writer'] ?? ''),
                    leading: (book['imageUrl'] ?? '').isNotEmpty
                        ? Image.network(
                      book['imageUrl']!,
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
                      if (title.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CourseBookDetailScreen(
                              title: book['title'] ?? '',
                              writer: book['writer'] ?? '',
                              imageUrl: book['imageUrl'] ?? '',
                              course: book['course'] ?? '',
                              summary: book['summary'] ?? '',
                            ),
                          ),
                        );
                      }
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Requested Books',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RequestedListScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: Size(double.infinity, 50),
              ),
              child: const Text('View Requested Books'),
            ),
            const SizedBox(height: 80),
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

    // Get the list of book titles from the bookmarks
    final uniqueBookmarks = <Map<String, dynamic>>[];
    final seenTitles = <String>{};

    for (var book in bookmarks) {
      final title = book['title'] ?? '';
      if (title.isNotEmpty && !seenTitles.contains(title)) {
        uniqueBookmarks.add(book);
        seenTitles.add(title);
      }
    }

    // Check if any of the requested books are already issued
    final issuedBooksSnapshot = await FirebaseFirestore.instance
        .collection('issuedbooks')
        .where('userId', isEqualTo: userId)
        .get();

    final issuedBooksTitles = issuedBooksSnapshot.docs
        .map((doc) => doc.data()['title'] as String)
        .toSet();

    // Filter out books that are already issued
    final nonIssuedBooks = uniqueBookmarks
        .where((book) => !issuedBooksTitles.contains(book['title'] ?? ''))
        .toList();

    final alreadyIssuedBooks = uniqueBookmarks
        .where((book) => issuedBooksTitles.contains(book['title'] ?? ''))
        .map((book) => book['title'] ?? '')
        .toSet();

    // Check if any of the non-issued books are already in the requests collection
    final existingRequestsSnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: userId)
        .get();

    final existingRequests = existingRequestsSnapshot.docs
        .expand((doc) => (doc.data()['books'] as List)
        .map((book) => book['title'] ?? ''))
        .toSet();

    final alreadyRequestedBooks = nonIssuedBooks
        .where((book) => existingRequests.contains(book['title'] ?? ''))
        .map((book) => book['title'] ?? '')
        .toSet();

    // Prepare the messages
    final issuedMessage = alreadyIssuedBooks.isNotEmpty
        ? 'The following books are already issued:\n${alreadyIssuedBooks.join(', ')}\n'
        : '';
    final requestsMessage = alreadyRequestedBooks.isNotEmpty
        ? 'The following books are already in your requests:\n${alreadyRequestedBooks.join(', ')}'
        : '';

    String additionalMessage = '';
    if (nonIssuedBooks.isNotEmpty && alreadyRequestedBooks.isEmpty) {
      final nonIssuedTitles = nonIssuedBooks.map((book) => book['title'] ?? '').join(', ');
      additionalMessage = 'Only these books have been added to your requests:\n$nonIssuedTitles';
    }

    // Show a dialog with the messages
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Books Status'),
        content: Text('$issuedMessage$requestsMessage$additionalMessage'),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              // Proceed to save the non-issued books that are not already requested
              if (nonIssuedBooks.isNotEmpty && alreadyRequestedBooks.isEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('requests').add({
                    'userId': userId,
                    'books': nonIssuedBooks,
                    'requestedAt': FieldValue.serverTimestamp(),
                  });

                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bookmarked books saved to requests')));
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to save bookmarks: $error')));
                }
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }







}
