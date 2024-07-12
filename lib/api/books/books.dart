
class Book {
  final String title;
  final String authors;
  final String? description;
  final String? thumbnail;
  final List<String>? genres;

  Book({
    required this.title,
    required this.authors,
    this.description,
    this.thumbnail,
    this.genres,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'authors': authors,
      'description': description,
      'thumbnail': thumbnail,
      'genres': genres,
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title'] ?? '',
      authors: (json['authors'] as List<dynamic>?)?.join(', ') ?? 'Unknown Author',
      description: json['description'],
      thumbnail: json['imageLinks'] != null ? json['imageLinks']['thumbnail'] : null,
      genres: json['categories'] != null ? List<String>.from(json['categories']) : null,
    );
  }
}
