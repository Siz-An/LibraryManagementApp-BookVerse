import 'dart:convert';
import 'package:http/http.dart' as http;

import '../books/books.dart';

class BookService {
  Future<List<Book>> searchBooks(String term) async {
    try {
      final response = await http.get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=$term'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List).map((item) => Book.fromJson(item['volumeInfo'])).toList();
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print('Failed to load books: $e');
      return [];
    }
  }

  Future<List<Book>> getRecommendations(String genre) async {
    try {
      final response = await http.get(Uri.parse('https://www.googleapis.com/books/v1/volumes?q=subject:$genre'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['items'] as List).map((item) => Book.fromJson(item['volumeInfo'])).toList();
      } else {
        throw Exception('Failed to load recommendations');
      }
    } catch (e) {
      print('Failed to load recommendations: $e');
      return [];
    }
  }
}
