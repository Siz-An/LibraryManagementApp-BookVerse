import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import '../books/books.dart';// Import the Book class definition

class Bookmarks with ChangeNotifier {
  late GetStorage _box;
  List<Book> bookmarks = [];

  Bookmarks() {
    _box = GetStorage('bookmarks');
    loadBookmarks();
  }

  void loadBookmarks() {
    bookmarks = (_box.read('bookmarks') ?? []).map<Book>((e) => Book.fromJson(e)).toList();
    notifyListeners();
  }

  void saveBookmarks() {
    _box.write('bookmarks', bookmarks.map((e) => e.toJson()).toList());
  }

  void addBookmark(Book book) {
    bookmarks.add(book);
    saveBookmarks();
    notifyListeners();
  }

  void removeBookmark(Book book) {
    bookmarks.remove(book);
    saveBookmarks();
    notifyListeners();
  }
}
