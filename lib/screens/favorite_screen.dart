// screens/favorite_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../widgets/movie_card.dart';

class FavoritesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Favorites'),
        backgroundColor: Colors.deepOrange,
      ),
      body: BlocBuilder<MovieBloc, MovieState>(
        builder: (context, state) {
          if (state is MoviesLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is MoviesLoaded) {
            return ListView.builder(
              itemCount: state.movies.length,
              itemBuilder: (context, index) {
                final movie = state.movies[index];
                return MovieCardWidget(
                  movie: movie,
                  onFavoriteToggle: (isFavorite) {
                    // Toggle favorite status
                    context.read<MovieBloc>().add(ToggleFavorite(movie.id, !isFavorite));
                  },
                );
              },
            );
          } else if (state is MoviesError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Center(child: Text('No favorites added.'));
        },
      ),
    );
  }
}
