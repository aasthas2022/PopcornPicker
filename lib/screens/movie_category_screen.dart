// screens/movie_category_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../widgets/movie_card.dart';
import 'detail_screen.dart';

class MovieCategoryScreen extends StatelessWidget {
  final String category;

  MovieCategoryScreen({required this.category});

  @override
  Widget build(BuildContext context) {
    if (category == 'favorites') {
      context.read<MovieBloc>().add(FetchFavorites());
    } else {
      context.read<MovieBloc>().add(
          category == 'upcoming' ? FetchMovies() :
          category == 'top_rated' ? FetchTopRatedMovies() :
          category == 'now_playing' ? FetchNowPlayingMovies() :
          FetchPopularMovies()
      );
    }

    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        if (state is MoviesLoading) {
          return Center(child: CircularProgressIndicator());
        } else if (state is MoviesLoaded) {
          return ListView.builder(
            itemCount: state.movies.length,
            itemBuilder: (context, index) {
              final movie = state.movies[index];
              return Dismissible(
                key: Key(movie.id.toString()),
                background: Container(color: Colors.red),
                onDismissed: (direction) {
                  context.read<MovieBloc>().add(DeleteMovie(movie.id));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("${movie.title} deleted")),
                  );
                },
                child: InkWell(
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => MovieDetailScreen(movie: movie),
                    ),
                  ),
                  child:  MovieCardWidget(
                      movie: movie,
                      onFavoriteToggle: (isFavorite) {
                        context.read<MovieBloc>().add(ToggleFavorite(movie.id, isFavorite));
                      }
                  ),
                ),
              );

            },
          );
        } else if (state is MoviesError) {
          return Center(child: Text('Failed to load movies: ${state.message}'));
        }
        return SizedBox.shrink();
      },
    );
  }
}
