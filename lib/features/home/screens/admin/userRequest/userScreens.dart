import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRequestedBooksScreen extends StatelessWidget {
  final String userId;
  final String adminId;

  const UserRequestedBooksScreen({required this.userId, required this.adminId, Key? key}) : super(key: key);

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 26),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.menu_book_rounded, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Requested Books',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('userId', isEqualTo: userId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return _emptyState(context);
          }

          final requests = snapshot.data!.docs;
          List<Map<String, dynamic>> books = [];
          for (var request in requests) {
            List<Map<String, dynamic>> requestBooks = List<Map<String, dynamic>>.from(request['books']);
            books.addAll(requestBooks);
          }

          if (books.isEmpty) {
            return _emptyState(context);
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            child: ListView.separated(
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 22),
              itemBuilder: (context, index) {
                final book = books[index];
                return _modernBookCard(
                  context: context,
                  book: book,
                  onAccept: () => acceptBook(context, book, requests, adminId),
                  onReject: () => rejectBook(context, book, requests, adminId),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.purple.shade100, Colors.purple.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            padding: const EdgeInsets.all(24),
            child: Icon(Icons.menu_book_rounded, size: 64, color: Colors.purple.shade400),
          ),
          const SizedBox(height: 20),
          Text(
            'No requested books found.',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modernBookCard({
    required BuildContext context,
    required Map<String, dynamic> book,
    required VoidCallback onAccept,
    required VoidCallback onReject,
  }) {
    final theme = Theme.of(context);
    return Material(
      elevation: 6,
      borderRadius: BorderRadius.circular(22),
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.10),
              theme.colorScheme.secondary.withOpacity(0.07),
              Colors.white,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.10),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          leading: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: book['imageUrl'] != null && book['imageUrl'].isNotEmpty
                ? Image.network(
                    book['imageUrl'],
                    width: 56,
                    height: 80,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      // Fallback to a default book icon if image fails to load
                      return Container(
                        width: 56,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.book, size: 34, color: Colors.grey),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      // Show a loading indicator while the image is loading
                      if (loadingProgress == null) return child;
                      return Container(
                        width: 56,
                        height: 80,
                        color: Colors.grey.shade200,
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                          ),
                        ),
                      );
                    },
                  )
                : Container(
                    width: 56,
                    height: 80,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.book, size: 34, color: Colors.grey),
                  ),
          ),
          title: Text(
            book['title'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 19,
              color: Color(0xFF22223B),
              letterSpacing: 0.2,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Text(
              'by ${book['writer']}',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          trailing: Wrap(
            spacing: 10,
            children: [
              Tooltip(
                message: 'Accept',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    elevation: 2,
                  ),
                  onPressed: onAccept,
                  child: const Icon(Icons.check, color: Colors.white, size: 22),
                ),
              ),
              Tooltip(
                message: 'Reject',
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
                    elevation: 2,
                  ),
                  onPressed: onReject,
                  child: const Icon(Icons.close, color: Colors.white, size: 22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void acceptBook(BuildContext context, Map<String, dynamic> book, List<DocumentSnapshot> requests, String adminId) async {
    final bookId = book['bookId'];
    final specificUserId = userId;

    final bookDoc = await FirebaseFirestore.instance.collection('books').doc(bookId).get();
    if (bookDoc.exists) {
      final bookData = bookDoc.data() as Map<String, dynamic>;
      final int numberOfCopies = bookData['numberOfCopies'];

      if (numberOfCopies > 0) {
        await FirebaseFirestore.instance.collection('issuedBooks').add({
          'userId': specificUserId,
          'adminId': adminId,
          'bookId': bookId,
          'title': book['title'],
          'writer': book['writer'],
          'imageUrl': book['imageUrl'],
          'issueDate': Timestamp.now(),
          'isRead': false,
        });

        await FirebaseFirestore.instance.collection('books').doc(bookId).update({
          'numberOfCopies': numberOfCopies - 1,
        });

        await removeBookFromRequests(book, requests);

        _showSnackBar(context, 'Book accepted, issued, and number of copies updated!', Colors.green);
      } else {
        _showSnackBar(context, 'No more copies available for this book.', Colors.orange);
      }
    } else {
      _showSnackBar(context, 'Book not found in the database.', Colors.red);
    }
  }

  void rejectBook(BuildContext context, Map<String, dynamic> book, List<DocumentSnapshot> requests, String adminId) {
    TextEditingController reasonController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.close, color: Colors.redAccent, size: 36),
              const SizedBox(height: 12),
              const Text(
                'Reject Book',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: reasonController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Reason for rejection',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        side: BorderSide(color: Colors.grey.shade400),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        if (reasonController.text.isNotEmpty) {
                          await FirebaseFirestore.instance.collection('rejectedBooks').add({
                            'userId': userId,
                            'adminId': adminId,
                            'bookId': book['bookId'],
                            'title': book['title'],
                            'writer': book['writer'],
                            'imageUrl': book['imageUrl'],
                            'rejectionReason': reasonController.text,
                            'rejectionDate': Timestamp.now(),
                          });

                          await removeBookFromRequests(book, requests);

                          Navigator.pop(context);
                          _showSnackBar(context, 'Book rejected and reason saved!', Colors.redAccent);
                        } else {
                          _showSnackBar(context, 'Please provide a rejection reason.', Colors.orange);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent.shade700,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Reject', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> removeBookFromRequests(Map<String, dynamic> book, List<DocumentSnapshot> requests) async {
    for (var request in requests) {
      List<Map<String, dynamic>> requestBooks = List<Map<String, dynamic>>.from(request['books']);
      requestBooks.removeWhere((b) => b['bookId'] == book['bookId']);
      if (requestBooks.isEmpty) {
        await FirebaseFirestore.instance.collection('requests').doc(request.id).delete();
      } else {
        await FirebaseFirestore.instance.collection('requests').doc(request.id).update({
          'books': requestBooks,
        });
      }
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontWeight: FontWeight.w500)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      ),
    );
  }

  void markBookAsRead(BuildContext context, String issuedBookId) async {
    final issuedBookRef = FirebaseFirestore.instance.collection('issuedBooks').doc(issuedBookId);

    await issuedBookRef.update({
      'isRead': true,
    });

    _showSnackBar(context, 'Book marked as read!', Colors.blueAccent);
  }
}
