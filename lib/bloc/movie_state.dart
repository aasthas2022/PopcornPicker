// bloc/movie_state.dart

import '../models/movie.dart';

abstract class MovieState {}

class MoviesInitial extends MovieState {}

class MoviesLoading extends MovieState {}

class MoviesLoaded extends MovieState {
  final List<Movie> movies;

  MoviesLoaded({required this.movies});
}

class MoviesError extends MovieState {
  final String message;

  MoviesError({required this.message});
}
