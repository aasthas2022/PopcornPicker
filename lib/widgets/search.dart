// widgets/search.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../models/movie.dart';
import '../screens/detail_screen.dart';

class MovieSearchDelegate extends SearchDelegate<Movie?> {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        query = '';
        context.read<MovieBloc>().add(FetchMovies());
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Center(
      child: Text(query),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    context.read<MovieBloc>().add(SearchMovies(query));

    return BlocBuilder<MovieBloc, MovieState>(
      builder: (context, state) {
        return _buildStateWidget(state, context);
      },
    );
  }

  Widget _buildStateWidget(MovieState state, BuildContext context) {
    if (state is MoviesLoading) {
      return _buildLoadingState();
    } else if (state is MoviesLoaded) {
      return _buildLoadedState(state.movies, context);
    } else if (state is MoviesError) {
      return _buildErrorState(state.message);
    } else {
      return SizedBox.shrink(); // Placeholder for initial state
    }
  }

  Widget _buildLoadingState() {
    return Center(child: CircularProgressIndicator());
  }

  Widget _buildLoadedState(List<Movie> movies, BuildContext context) {
    return ListView.builder(
      itemCount: movies.length,
      itemBuilder: (context, index) {
        final movie = movies[index];
        return ListTile(
          title: Text(movie.title),
          leading: Icon(Icons.movie),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MovieDetailScreen(movie: movie),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(String message) {
    return Center(child: Text('Failed to load movies: $message'));
  }
}
