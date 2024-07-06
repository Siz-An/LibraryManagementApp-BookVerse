class Book {
  final String title;
  final List<String> authors;
  final String thumbnail;
  final String description;

  Book({
    required this.title,
    required this.authors,
    required this.thumbnail,
    required this.description,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['volumeInfo']['title'],
      authors: (json['volumeInfo']['authors'] as List<dynamic>)
          .map((author) => author as String)
          .toList(),
      thumbnail: json['volumeInfo']['imageLinks']?['thumbnail'] ?? '',
      description: json['volumeInfo']['description'] ?? 'No description available',
    );
  }
}
