// lib/providers/bookmarks_provider.dart

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../books/books.dart'; // Import the Book class definition

class Bookmarks with ChangeNotifier {
  late GetStorage _box;
  List<Book> bookmarks = [];

  Bookmarks() {
    _box = GetStorage('bookmarks');
    loadBookmarks();
  }

  void loadBookmarks() {
    print('Loading bookmarks...');
    final List<dynamic>? storedBookmarks = _box.read('bookmarks');
    if (storedBookmarks != null) {
      bookmarks = storedBookmarks.map<Book>((e) => Book.fromJson(e)).toList();
      print('Loaded bookmarks: $bookmarks');
    } else {
      bookmarks = [];
      print('No bookmarks found');
    }
    notifyListeners();
  }

  void saveBookmarks() {
    print('Saving bookmarks: $bookmarks');
    _box.write('bookmarks', bookmarks.map((e) => e.toJson()).toList());
  }

  void addBookmark(Book book) {
    bookmarks.add(book);
    print('Added bookmark: $book');
    saveBookmarks();
    notifyListeners();
  }

  void removeBookmark(Book book) {
    bookmarks.remove(book);
    print('Removed bookmark: $book');
    saveBookmarks();
    notifyListeners();
  }
}
