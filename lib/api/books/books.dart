class Book {
  final String title;
  final String authors;
  final String? description;
  final String? thumbnail;
  final List<String>? genres;  // Add genres field

  Book({
    required this.title,
    required this.authors,
    this.description,
    this.thumbnail,
    this.genres,  // Add genres to the constructor
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['volumeInfo']['title'],
      authors: (json['volumeInfo']['authors'] as List?)?.join(', ') ?? 'Unknown Author',
      description: json['volumeInfo']['description'],
      thumbnail: json['volumeInfo']['imageLinks']?['thumbnail'],
      genres: (json['volumeInfo']['categories'] as List?)?.map((category) => category.toString()).toList(),  // Parse genres
    );
  }
}
