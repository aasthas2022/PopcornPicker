// widgets/movie_card.dart

import 'package:flutter/material.dart';
import '../widgets/image.dart';
import '../models/movie.dart';

class MovieCardWidget extends StatelessWidget {
  final Movie movie;
  final void Function(bool) onFavoriteToggle;
  MovieCardWidget({required this.movie, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          'https://image.tmdb.org/t/p/w500${movie.posterPath}',
          fit: BoxFit.cover,
          width: 100,
          errorBuilder: (context, error, stackTrace) => Icon(Icons.error),
        ),
        title: Text(movie.title),
        subtitle: Text("Rating: ${movie.rating}"),
        trailing: IconButton(
          icon: Icon(
            movie.isFavorite ? Icons.favorite : Icons.favorite_border,
            color: movie.isFavorite ? Colors.red : Colors.grey,
          ),
          onPressed: () => onFavoriteToggle(!movie.isFavorite),
        ),
      ),
    );
  }
}