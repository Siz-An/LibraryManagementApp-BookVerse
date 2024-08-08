import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class BookmarkProvider extends ChangeNotifier {
  List<Map<String, dynamic>> _bookmarks = [];

  List<Map<String, dynamic>> get bookmarks => _bookmarks;

  BookmarkProvider() {
    _fetchBookmarks();
  }

  Future<void> _fetchBookmarks() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      _bookmarks = [];
      notifyListeners();
      return;
    }
    final userId = user.uid;

    FirebaseFirestore.instance
        .collection('bookmarks')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .listen((snapshot) {
      _bookmarks = snapshot.docs.map((doc) => {
        ...doc.data() as Map<String, dynamic>,
        'id': doc.id // Store document ID for deletion
      }).toList();
      notifyListeners();
    });
  }

  void addBookmark(Map<String, dynamic> bookmark) {
    _bookmarks.add(bookmark);
    notifyListeners();
  }

  void removeBookmark(Map<String, dynamic> bookmark) {
    final bookmarkId = bookmark['id'];
    if (bookmarkId != null) {
      FirebaseFirestore.instance
          .collection('bookmarks')
          .doc(bookmarkId)
          .delete()
          .then((_) {
        _bookmarks.removeWhere((item) => item['id'] == bookmarkId);
        notifyListeners();
      })
          .catchError((error) {
        // Handle errors if necessary
        print('Failed to remove bookmark: $error');
      });
    }
  }
}