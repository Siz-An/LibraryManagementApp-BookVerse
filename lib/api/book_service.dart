import 'dart:convert';
import 'package:http/http.dart' as http;

import 'book.dart';

class BookService {
  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const String _apiKey = 'AIzaSyA0LQk5XjSXBeOAGYYnI6An_PzVXQgFDec';

  Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(Uri.parse('$_baseUrl?q=$query&key=$_apiKey'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Book> books = (data['items'] as List).map((item) => Book.fromJson(item)).toList();
      return books;
    } else {
      throw Exception('Failed to load books');
    }
  }
}
