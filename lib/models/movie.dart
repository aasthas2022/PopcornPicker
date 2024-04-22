// models/movie.dart

class Movie {
  final int id;
  final String title;
  final String description;
  final String posterPath;
  final double rating;
  bool isFavorite;

  Movie({
    required this.id,
    required this.title,
    required this.description,
    required this.posterPath,
    required this.rating,
    this.isFavorite = false,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      id: json['id'],
      title: json['title'],
      description: json['overview'],
      posterPath: json['poster_path'],
      rating: json['vote_average'].toDouble(),
      isFavorite: json['is_favorite'] ?? false,
    );
  }
}
