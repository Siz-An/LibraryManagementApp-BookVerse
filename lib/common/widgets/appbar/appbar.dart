import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../utils/constants/sizes.dart';
import '../../../../../books/detailScreen/course_book_detail_screen.dart';
import '../../../utils/device/device_utility.dart';

class TAppBar extends StatefulWidget implements PreferredSizeWidget {
  const TAppBar({
    super.key,
    this.title,
    this.leadingIcon,
    this.actions,
    this.leadingOnProgress,
    this.showBackArrow = false,
    this.showSearchBox = false,
  });

  final Widget? title;
  final bool showBackArrow;
  final IconData? leadingIcon;
  final List<Widget>? actions;
  final VoidCallback? leadingOnProgress;
  final bool showSearchBox;

  @override
  _TAppBarState createState() => _TAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(
    showSearchBox ? TDeviceUtils.getAppBarHeight() + 150 : TDeviceUtils.getAppBarHeight(),
  );
}

class _TAppBarState extends State<TAppBar> {
  String query = '';
  List<DocumentSnapshot> searchResults = [];
  FocusNode searchFocusNode = FocusNode();
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Get the currently logged-in user
    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus) {
        setState(() {
          searchResults = [];
          query = '';
        });
      }
    });
  }

  Future<void> _getCurrentUser() async {
    final user = FirebaseAuth.instance.currentUser;
    setState(() {
      currentUser = user;
    });
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

      print('All previous searched books deleted successfully.');
    } catch (e) {
      print('Failed to delete searched books: $e');
    }
  }

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    if (currentUser == null) {
      print('No user is logged in.');
      return;
    }

    final userId = currentUser!.uid;

    // Clear existing searched books for the user
    await _deleteSearchedBooks(userId);

    final uppercaseQuery = query.toUpperCase();
    final snapshot = await FirebaseFirestore.instance.collection('books').get();

    setState(() {
      searchResults = snapshot.docs.where((doc) {
        final bookData = doc.data() as Map<String, dynamic>;
        final bookTitle = (bookData['title'] ?? '').toUpperCase();
        final bookWriter = (bookData['writer'] ?? '').toUpperCase();

        return bookTitle.contains(uppercaseQuery) || bookWriter.contains(uppercaseQuery);
      }).toList();
    });

    // Save the new search results
    for (var doc in searchResults) {
      _saveSearchedBooks(doc, query, userId);
    }
  }

  Future<void> _saveSearchedBooks(DocumentSnapshot doc, String searchQuery, String userId) async {
    try {
      final bookId = doc.id;
      final book = doc.data() as Map<String, dynamic>;
      final title = book['title']?.toString() ?? 'No title';
      final writer = book['writer']?.toString() ?? 'Unknown author';
      final imageUrl = book['imageUrl']?.toString() ?? '';
      final course = book['course']?.toString() ?? '';
      final summary = book['summary']?.toString() ?? 'No summary available';

      if (title.trim().toLowerCase() == searchQuery.trim().toLowerCase()) {
        await FirebaseFirestore.instance.collection('searchedBooks').add({
          'userId': userId,
          'bookId': bookId,
          'title': title,
          'writer': writer,
          'imageUrl': imageUrl,
          'course': course,
          'summary': summary,
          'searchedAt': FieldValue.serverTimestamp(),
        });
        print('Book saved: $title');
      }
    } catch (e, stackTrace) {
      print('Failed to save searched book: $e');
      print('StackTrace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: TSizes.md),
      child: Column(
        children: [
          AppBar(
            automaticallyImplyLeading: false,
            leading: widget.showBackArrow
                ? IconButton(
              onPressed: () => Get.back(),
              icon: const Icon(Iconsax.arrow_left, color: Colors.purple),
            )
                : widget.leadingIcon != null
                ? IconButton(onPressed: widget.leadingOnProgress, icon: Icon(widget.leadingIcon))
                : null,
            title: widget.title,
            actions: widget.actions,
          ),
          if (widget.showSearchBox) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                focusNode: searchFocusNode,
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                  _searchBooks(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search...',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Iconsax.search_normal, color: Colors.grey),
                ),
                onTap: () {
                  searchFocusNode.requestFocus();
                },
              ),
            ),
            if (query.isNotEmpty && searchResults.isNotEmpty)
              Container(
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final book = searchResults[index].data() as Map<String, dynamic>;
                    final title = book['title'] ?? 'No title';
                    final writer = book['writer'] ?? 'Unknown author';
                    final imageUrl = book['imageUrl'] ?? '';
                    final course = book['course'] ?? '';
                    final summary = book['summary'] ?? 'No summary available';

                    return ListTile(
                      leading: imageUrl.isEmpty
                          ? const Icon(Icons.book, size: 50)
                          : Image.network(
                        imageUrl,
                        width: 50,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(Icons.book, size: 50);
                        },
                      ),
                      title: Text(title),
                      subtitle: Text(writer),
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
                    );
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchFocusNode.dispose();
    super.dispose();
  }
}
