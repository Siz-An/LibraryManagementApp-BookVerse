import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:book_Verse/features/home/screens/user/mark/provider.dart';
import 'package:book_Verse/features/home/screens/user/mark/requestssss.dart';
import '../../../../../books/detailScreen/course_book_detail_screen.dart';

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

    final filteredBookmarks = bookmarks.where((book) {
      final title = book['title'];
      return title != null && title.isNotEmpty;
    }).toList();

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
              style: Theme.of(context).textTheme.headlineLarge,
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
                  final book = filteredBookmarks.firstWhere(
                        (b) => b['title'] == title,
                    orElse: () => {
                      'title': '',
                      'writer': '',
                      'imageUrl': '',
                      'course': '',
                      'summary': '',
                      'bookId': '',
                    },
                  );

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(8.0),
                      title: Text('$title (Copies: $count)'),
                      subtitle: Text(book['writer'] ?? ''),
                      leading: (book['imageUrl'] ?? '').isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: Image.network(
                          book['imageUrl']!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.book);
                          },
                        ),
                      )
                          : const Icon(Icons.book),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _removeBookmark(context, book);
                        },
                      ),
                      onTap: () {
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
                      },
                    ),
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
                minimumSize: const Size(double.infinity, 50),
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
    final docId = book['id'];
    try {
      await FirebaseFirestore.instance.collection('bookmarks').doc(docId).delete();
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
    final bookmarks = Provider.of<BookmarkProvider>(context, listen: false).bookmarks;
    final uniqueBookmarks = <Map<String, dynamic>>[];
    final seenTitles = <String>{};

    for (var book in bookmarks) {
      final title = book['title'] ?? '';
      if (title.isNotEmpty && !seenTitles.contains(title)) {
        uniqueBookmarks.add(book);
        seenTitles.add(title);
      }
    }

    final issuedBooksSnapshot = await FirebaseFirestore.instance
        .collection('issuedBooks')
        .where('userId', isEqualTo: user.uid)
        .get();
    final issuedBooksTitles = issuedBooksSnapshot.docs
        .map((doc) => doc.data()['title'] as String)
        .toSet();

    final nonIssuedBooks = uniqueBookmarks
        .where((book) => !issuedBooksTitles.contains(book['title'] ?? ''))
        .toList();

    final existingRequestsSnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: user.uid)
        .get();
    final existingRequests = existingRequestsSnapshot.docs
        .expand((doc) => (doc.data()['books'] as List)
        .map((book) => book['title'] ?? ''))
        .toSet();

    final alreadyRequestedBooks = nonIssuedBooks
        .where((book) => existingRequests.contains(book['title'] ?? ''))
        .map((book) => book['title'] ?? '')
        .toSet();

    final newlyAddedBooks = nonIssuedBooks
        .where((book) => !existingRequests.contains(book['title'] ?? ''))
        .toList();

    final issuedMessage = issuedBooksTitles.isNotEmpty
        ? 'The following books are already issued:\n${issuedBooksTitles.join(', ')}\n'
        : '';
    final requestsMessage = alreadyRequestedBooks.isNotEmpty
        ? 'The following books are already in your requests:\n${alreadyRequestedBooks.join(', ')}\n'
        : '';
    final addedMessage = newlyAddedBooks.isNotEmpty
        ? 'The following books have been added to your requests:\n${newlyAddedBooks.map((book) => book['title']).join(', ')}\n'
        : 'No new books were added to your requests.';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Books Status'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              if (issuedMessage.isNotEmpty) Text(issuedMessage),
              if (requestsMessage.isNotEmpty) Text(requestsMessage),
              if (addedMessage.isNotEmpty) Text(addedMessage),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (newlyAddedBooks.isNotEmpty) {
                try {
                  await FirebaseFirestore.instance.collection('requests').add({
                    'userId': user.uid,
                    'books': newlyAddedBooks,
                    'requestedAt': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Selected books added to your requests')),
                  );
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to add requests: $error')),
                  );
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
