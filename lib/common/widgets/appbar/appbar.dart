import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../../utils/constants/sizes.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final bool showSearchBox; // Controls whether a search box appears

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
  FocusNode searchFocusNode = FocusNode(); // FocusNode to manage the search box focus

  Future<void> _searchBooks(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
      });
      return;
    }

    // Convert the search query to uppercase
    final uppercaseQuery = query.toUpperCase();

    // Fetch all books first
    final snapshot = await FirebaseFirestore.instance.collection('books').get();

    // Filter the results to make the title comparison case-insensitive
    setState(() {
      searchResults = snapshot.docs.where((doc) {
        final bookTitle = (doc.data() as Map<String, dynamic>)['title'] as String;
        return bookTitle.contains(uppercaseQuery);
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    // Add listener to manage focus state
    searchFocusNode.addListener(() {
      if (!searchFocusNode.hasFocus) {
        // Clear search results when the search box loses focus
        setState(() {
          searchResults = [];
          query = '';
        });
      }
    });
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
          // Conditionally show search box and results if enabled
          if (widget.showSearchBox) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: TextField(
                focusNode: searchFocusNode, // Attach the FocusNode to the TextField
                onChanged: (value) {
                  setState(() {
                    query = value; // Update the query
                  });
                  _searchBooks(value); // Call the search function
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
                  // Explicitly request focus when the TextField is tapped
                  searchFocusNode.requestFocus();
                },
              ),
            ),
            // Only display search results when the query is not empty
            if (query.isNotEmpty && searchResults.isNotEmpty)
              Container(
                color: Colors.white,
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(), // Prevent scrolling
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final book = searchResults[index].data() as Map<String, dynamic>;

                    // Provide default values if fields are null
                    final title = book['title'] ?? 'No title';
                    final writer = book['writer'] ?? 'Unknown author';
                    final imageUrl = book['imageUrl'] ?? ''; // Use an empty string or a placeholder image URL
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
    searchFocusNode.dispose(); // Dispose of the FocusNode
    super.dispose();
  }
}
