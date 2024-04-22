// bloc/movie_event.dart

abstract class MovieEvent {}

class FetchMovies extends MovieEvent {}
class FetchTopRatedMovies extends MovieEvent {}
class FetchNowPlayingMovies extends MovieEvent {}
class FetchPopularMovies extends MovieEvent {}
class FetchFavorites extends MovieEvent {}

class SearchMovies extends MovieEvent {
  final String query;

  SearchMovies(this.query);
}

class DeleteMovie extends MovieEvent {
  final int movieId;

  DeleteMovie(this.movieId);
}

class ToggleFavorite extends MovieEvent {
  final int movieId;
  final bool isFavorite;

  ToggleFavorite(this.movieId, this.isFavorite);
}
