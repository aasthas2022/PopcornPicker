// bloc/movie_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/movie.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../utils/movie_api.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieApi movieApi;
  List<Movie> _movies = [];
  final List<int> _deletedMovieIds = [];

  MovieBloc({required this.movieApi}) : super(MoviesInitial()) {
    on<FetchMovies>(_fetchMovies);
    on<SearchMovies>(_searchMovies);
    on<DeleteMovie>(_deleteMovie);
    on<FetchTopRatedMovies>(_fetchTopRatedMovies);
    on<FetchNowPlayingMovies>(_fetchNowPlayingMovies);
    on<FetchPopularMovies>(_fetchPopularMovies);
    _loadDeletedMovies();
  }

  void _loadDeletedMovies() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _deletedMovieIds.addAll(prefs.getStringList('deletedMovies')?.map(int.parse) ?? []);
  }

  void _persistDeletion(int movieId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _deletedMovieIds.add(movieId);
    await prefs.setStringList('deletedMovies', _deletedMovieIds.map((id) => id.toString()).toList());
  }

  Future<void> _fetchTopRatedMovies(FetchTopRatedMovies event, Emitter<MovieState> emit) async {
    await _fetchMovieCategory('top_rated', emit);
  }

  Future<void> _fetchNowPlayingMovies(FetchNowPlayingMovies event, Emitter<MovieState> emit) async {
    await _fetchMovieCategory('now_playing', emit);
  }

  Future<void> _fetchMovieCategory(String category, Emitter<MovieState> emit) async {
    emit(MoviesLoading());
    try {
      _movies = await movieApi.getMovies(category);
      _movies.removeWhere((movie) => _deletedMovieIds.contains(movie.id));
      emit(MoviesLoaded(movies: _movies));
    } catch (e) {
      emit(MoviesError(message: e.toString()));
    }
  }


  Future<void> _fetchPopularMovies(FetchPopularMovies event, Emitter<MovieState> emit) async {
    await _fetchMovieCategory('popular', emit);
  }

  Future<void> _fetchMovies(FetchMovies event, Emitter<MovieState> emit) async {
    emit(MoviesLoading());
    try {
      _loadDeletedMovies();
      _movies = await movieApi.getMovies("upcoming");
      _movies.removeWhere((movie) => _deletedMovieIds.contains(movie.id));
      emit(MoviesLoaded(movies: _movies));
    } catch (e) {
      emit(MoviesError(message: e.toString()));
    }
  }

  Future<void> _searchMovies(SearchMovies event, Emitter<MovieState> emit) async {
    emit(MoviesLoading());
    try {
      final List<Movie> movies = await movieApi.searchMovies(event.query);
      movies.removeWhere((movie) => _deletedMovieIds.contains(movie.id));
      emit(MoviesLoaded(movies: movies));
    } catch (e) {
      emit(MoviesError(message: e.toString()));
    }
  }

  Future<void> _deleteMovie(DeleteMovie event, Emitter<MovieState> emit) async {
    _movies.removeWhere((movie) => movie.id == event.movieId);
    _persistDeletion(event.movieId);
    emit(MoviesLoaded(movies: List.from(_movies)));
  }
}
