// widgets/movie_card.dart

import 'package:flutter/material.dart';
import '../widgets/image.dart';
import '../models/movie.dart';

class MovieCardWidget extends StatelessWidget {
  final Movie movie;

  MovieCardWidget({required this.movie});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column
        (
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image.network(
            'https://image.tmdb.org/t/p/w500${movie.posterPath}',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
            errorBuilder: (context, error, stackTrace) => PlaceholderImageWidget(),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  movie.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.fade,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}