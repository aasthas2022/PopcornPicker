// bloc/movie_event.dart

abstract class MovieEvent {}

class FetchMovies extends MovieEvent {}
class FetchTopRatedMovies extends MovieEvent {}
class FetchNowPlayingMovies extends MovieEvent {}
class FetchPopularMovies extends MovieEvent {}

class SearchMovies extends MovieEvent {
  final String query;

  SearchMovies(this.query);
}

class DeleteMovie extends MovieEvent {
  final int movieId;

  DeleteMovie(this.movieId);
}
