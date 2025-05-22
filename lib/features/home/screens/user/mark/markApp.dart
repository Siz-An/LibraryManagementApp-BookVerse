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
      child: const BookmarkScreen(),
        );
      }
    }

    class BookmarkScreen extends StatelessWidget {
      const BookmarkScreen({super.key});

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
      backgroundColor: const Color(0xFFF5F7FA),
      // Modern AppBar with gradient and rounded corners
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
          child: const SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 18.0, vertical: 16),
          child: Row(
            children: [
          
          SizedBox(width: 10),
          Icon(Icons.bookmark, color: Colors.white, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Text(
              'Bookmarks & Requests',
              style: TextStyle(
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
            ],
          ),
        ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
        child: ListView(
          children: [
        const SizedBox(height: 12),
        Text(
          'Your Bookmarks',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF22223B),
          ),
        ),
        const SizedBox(height: 10),
        _ModernBookmarkList(
          bookCounts: bookCounts,
          filteredBookmarks: filteredBookmarks,
          onRemove: (book) => _removeBookmark(context, book),
        ),
        const SizedBox(height: 28),
        Text(
          'Requested Books',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF4A4E69),
          ),
        ),
        const SizedBox(height: 10),
        _ModernRequestButton(
          onTap: () {
            Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const RequestedListScreen(),
          ),
            );
          },
        ),
        const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: _ModernFAB(
        onPressed: () => _saveBookmarksToRequests(context),
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

        // Fetch issued books
        final issuedBooksSnapshot = await FirebaseFirestore.instance
        .collection('issuedBooks')
        .where('userId', isEqualTo: user.uid)
        .get();

        final issuedBooksTitles = issuedBooksSnapshot.docs
        .map((doc) => doc.data()['title'] as String)
        .toSet();

        // Fetch existing requests
        final existingRequestsSnapshot = await FirebaseFirestore.instance
        .collection('requests')
        .where('userId', isEqualTo: user.uid)
        .get();

        final existingRequests = existingRequestsSnapshot.docs
        .expand((doc) => (doc.data()['books'] as List)
        .map((book) => (book as Map<String, dynamic>)['title'] as String))
        .toSet();

        // Combine issued and requested books
        final totalEngagedBooks = issuedBooksTitles.union(existingRequests);

        // Determine non-engaged bookmarks
        final nonEngagedBooks = uniqueBookmarks
        .where((book) => !totalEngagedBooks.contains(book['title'] ?? ''))
        .toList();

        // Check if the total books would exceed the limit
        if (totalEngagedBooks.length + nonEngagedBooks.length > 7) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You can only have up to 7 books issued or requested in total.')),
      );
      return;
        }

        final issuedMessage = issuedBooksTitles.isNotEmpty
        ? 'The following books are already issued:\n${issuedBooksTitles.join(', ')}\n'
        : '';
        final requestsMessage = existingRequests.isNotEmpty
        ? 'The following books are already in your requests:\n${existingRequests.join(', ')}\n'
        : '';
        final addedMessage = nonEngagedBooks.isNotEmpty
        ? 'The following books have been added to your requests:\n${nonEngagedBooks.map((book) => book['title']).join(', ')}\n'
        : 'No new books were added to your requests.';

        showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Books Status'),
        content: SingleChildScrollView(
          child: ListBody(
        children: <Widget>[
          if (issuedMessage.isNotEmpty)
            Text(issuedMessage, style: const TextStyle(color: Colors.redAccent)),
          if (requestsMessage.isNotEmpty)
            Text(requestsMessage, style: const TextStyle(color: Colors.orange)),
          if (addedMessage.isNotEmpty)
            Text(addedMessage, style: const TextStyle(color: Colors.green)),
        ],
          ),
        ),
        actions: [
          TextButton(
        onPressed: () async {
          Navigator.of(context).pop();
          if (nonEngagedBooks.isNotEmpty) {
            try {
          await FirebaseFirestore.instance.collection('requests').add({
            'userId': user.uid,
            'books': nonEngagedBooks,
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

    class _ModernBookmarkList extends StatelessWidget {
      final Map<String, int> bookCounts;
      final List<Map<String, dynamic>> filteredBookmarks;
      final Function(Map<String, dynamic>) onRemove;

      const _ModernBookmarkList({
        required this.bookCounts,
        required this.filteredBookmarks,
        required this.onRemove,
      });

      @override
      Widget build(BuildContext context) {
        if (bookCounts.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Center(
          child: Column(
        children: [
          Icon(Icons.bookmark_border, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'No bookmarks yet.',
            style: TextStyle(
          color: Colors.grey[500],
          fontSize: 18,
          fontWeight: FontWeight.w500,
            ),
          ),
        ],
          ),
        ),
      );
        }
        return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookCounts.keys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
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

        return GestureDetector(
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
          child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          leading: Hero(
            tag: book['imageUrl'] ?? title,
            child: ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: (book['imageUrl'] ?? '').isNotEmpty
              ? Image.network(
              book['imageUrl']!,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
              width: 54,
              height: 54,
              color: Colors.grey[200],
              child: const Icon(Icons.book, color: Colors.grey),
                );
              },
            )
              : Container(
              width: 54,
              height: 54,
              color: Colors.grey[200],
              child: const Icon(Icons.book, color: Colors.grey),
            ),
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 17,
          color: Color(0xFF22223B),
            ),
          ),
          subtitle: Text(
            book['writer'] ?? '',
            style: const TextStyle(
          color: Color(0xFF4A4E69),
          fontSize: 14,
            ),
          ),
          trailing: SizedBox(
            height: 54, // Prevent overflow by constraining height
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
            color: const Color(0xFF9A8C98).withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
            'Copies: $count',
            style: const TextStyle(
              color: Color(0xFF9A8C98),
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => onRemove(book),
              child: const Icon(Icons.delete_outline, color: Color(0xFFE63946), size: 26),
            ),
          ],
            ),
          ),
        ),
          ),
        );
      },
        );
      }
    }

    class _ModernRequestButton extends StatelessWidget {
      final VoidCallback onTap;
      const _ModernRequestButton({required this.onTap});

      @override
      Widget build(BuildContext context) {
        return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF4A4E69), Color(0xFF9A8C98)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.13),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
          ),
          height: 54,
          child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.library_books, color: Colors.white, size: 26),
          SizedBox(width: 12),
          Text(
            'View Requested Books',
            style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 17,
          letterSpacing: 0.5,
            ),
          ),
        ],
          ),
        ),
      ),
        );
      }
    }

    class _ModernFAB extends StatelessWidget {
      final VoidCallback onPressed;
      const _ModernFAB({required this.onPressed});

      @override
      Widget build(BuildContext context) {
        return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: const Color(0xFF4A4E69),
      icon: const Icon(Icons.save_alt, color: Colors.white),
      label: const Text(
        'Request Books',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 6,
        );
      }
    }
