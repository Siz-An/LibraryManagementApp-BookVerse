import 'dart:convert';
import 'package:http/http.dart' as http;

class BookService {
  static const String apiUrl = 'https://www.googleapis.com/books/v1/volumes?q=';

  Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(Uri.parse('$apiUrl$query'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Book> books = (data['items'] as List).map((item) => Book.fromJson(item)).toList();
      return books;
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<List<Book>> getRecommendations(String query) async {
    final recommendationQuery = '$query+recommended';
    final response = await http.get(Uri.parse('$apiUrl$recommendationQuery'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      List<Book> books = (data['items'] as List).map((item) => Book.fromJson(item)).toList();
      return books;
    } else {
      throw Exception('Failed to load recommendations');
    }
  }
}

class Book {
  final String title;
  final String authors;
  final String? description;
  final String? thumbnail;

  Book({
    required this.title,
    required this.authors,
    this.description,
    this.thumbnail,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['volumeInfo']['title'],
      authors: (json['volumeInfo']['authors'] as List?)?.join(', ') ?? 'Unknown Author',
      description: json['volumeInfo']['description'],
      thumbnail: json['volumeInfo']['imageLinks']?['thumbnail'],
    );
  }
}
