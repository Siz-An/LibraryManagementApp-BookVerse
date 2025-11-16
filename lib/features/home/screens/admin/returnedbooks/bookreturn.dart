import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AcceptReturnedBooksScreen extends StatelessWidget {
  final String userId;

  const AcceptReturnedBooksScreen({required this.userId, super.key});

  Future<void> _acceptReturn(String docId, String bookId, Map<String, dynamic> bookData) async {
    final toBeReturnedBooksCollection = FirebaseFirestore.instance.collection('toBeReturnedBooks');
    final booksCollection = FirebaseFirestore.instance.collection('books');
    final usersCollection = FirebaseFirestore.instance.collection('Users');
    final dataCollection = FirebaseFirestore.instance.collection('DATA');

    try {
      await toBeReturnedBooksCollection.doc(docId).delete();

      final bookDoc = booksCollection.doc(bookId);
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final snapshot = await transaction.get(bookDoc);
        if (snapshot.exists) {
          final currentCopies = snapshot.get('numberOfCopies') as int;
          transaction.update(bookDoc, {'numberOfCopies': currentCopies + 1});
        }
      });

      final userDoc = await usersCollection.doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final acceptedDate = DateTime.now();
        await dataCollection.add({
          'UserId': userId,
          'UserName': userData['UserName'],
          'Email': userData['Email'],
          'PhoneNumber': userData['PhoneNumber'],
          'Image': bookData['imageUrl'],
          'BookName': bookData['title'],
          'IssueDate': bookData['issueDate'],
          'AcceptedDate': acceptedDate,
        });
      }
    } catch (e) {
      print("Error accepting return and updating copies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final DateFormat dateFormat = DateFormat('dd MMMM yyyy');

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
                  const Icon(Icons.assignment_turned_in, color: Colors.white, size: 32),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text(
                      'Returned Bookssss',
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
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('toBeReturnedBooks')
              .where('userId', isEqualTo: userId)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text(
                  'No books to accept for return.',
                  style: TextStyle(fontSize: 18, color: Color(0xFF4A4E69)),
                ),
              );
            }

            final books = snapshot.data!.docs;

            return ListView.separated(
              itemCount: books.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final data = books[index].data() as Map<String, dynamic>;
                final docId = books[index].id;
                final bookId = data['bookId'] as String;

                final issueDate = data["issueDate"] != null
                    ? (data["issueDate"] as Timestamp).toDate()
                    : null;
                final requestedReturnDate = data["requestedReturnDate"] != null
                    ? (data["requestedReturnDate"] as Timestamp).toDate()
                    : null;
                final returnDate = data["returnDate"] != null
                    ? (data["returnDate"] as Timestamp).toDate()
                    : null;

                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: data["imageUrl"] != null
                              ? Image.network(
                                  data["imageUrl"] as String,
                                  width: 70,
                                  height: 100,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to a default book icon if image fails to load
                                    return Container(
                                      width: 70,
                                      height: 100,
                                      color: const Color(0xFFE0E0E0),
                                      child: const Icon(
                                        Icons.book,
                                        size: 36,
                                        color: Color(0xFF9A8C98),
                                      ),
                                    );
                                  },
                                  loadingBuilder: (context, child, loadingProgress) {
                                    // Show a loading indicator while the image is loading
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      width: 70,
                                      height: 100,
                                      color: const Color(0xFFE0E0E0),
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress.expectedTotalBytes != null
                                              ? loadingProgress.cumulativeBytesLoaded /
                                                  loadingProgress.expectedTotalBytes!
                                              : null,
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF9A8C98)),
                                        ),
                                      ),
                                    );
                                  },
                                )
                              : Container(
                                  width: 70,
                                  height: 100,
                                  color: const Color(0xFFE0E0E0),
                                  child: const Icon(Icons.book, size: 36, color: Color(0xFF9A8C98)),
                                ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data['title'] as String,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF22223B),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Writer: ${data["writer"] as String}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Color(0xFF4A4E69),
                                ),
                              ),
                              const SizedBox(height: 6),
                              if (issueDate != null)
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today, size: 14, color: Color(0xFF9A8C98)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Issued: ${dateFormat.format(issueDate)}',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF6C6C80)),
                                    ),
                                  ],
                                ),
                              if (requestedReturnDate != null)
                                Row(
                                  children: [
                                    const Icon(Icons.event, size: 14, color: Color(0xFF9A8C98)),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Requested: ${dateFormat.format(requestedReturnDate)}',
                                      style: const TextStyle(fontSize: 13, color: Color(0xFF6C6C80)),
                                    ),
                                  ],
                                ),
                              if (returnDate != null)
                                Row(
                                  children: [
                                    const Icon(Icons.assignment_turned_in, size: 14, color: Colors.green),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Returned: ${dateFormat.format(returnDate)}',
                                      style: const TextStyle(fontSize: 13, color: Colors.green),
                                    ),
                                  ],
                                )
                              else
                                Row(
                                  children: const [
                                    Icon(Icons.assignment_late, size: 14, color: Colors.redAccent),
                                    SizedBox(width: 4),
                                    Text(
                                      'Return Date: Not yet returned',
                                      style: TextStyle(fontSize: 13, color: Colors.redAccent),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(24),
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                                  title: const Text('Accept Book Return'),
                                  content: const Text('Are you sure you want to accept this returned book?'),
                                  actions: [
                                    TextButton(
                                      child: const Text('Cancel'),
                                      onPressed: () => Navigator.of(context).pop(),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF4A4E69),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                      ),
                                      child: const Text('Accept'),
                                      onPressed: () {
                                        _acceptReturn(docId, bookId, data);
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(Icons.check_circle, color: Colors.green, size: 32),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
