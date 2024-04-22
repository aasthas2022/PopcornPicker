// bloc/movie_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/movie.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../utils/movie_api.dart';

class MovieBloc extends Bloc<MovieEvent, MovieState> {
  final MovieApi movieApi;
  List<Movie> _movies = [];
  final List<int> _deletedMovieIds = [];
  List<int> _favoriteMovieIds = [];

  MovieBloc({required this.movieApi}) : super(MoviesInitial()) {
    on<FetchMovies>(_fetchMovies);
    on<SearchMovies>(_searchMovies);
    on<DeleteMovie>(_deleteMovie);
    on<FetchTopRatedMovies>(_fetchTopRatedMovies);
    on<FetchNowPlayingMovies>(_fetchNowPlayingMovies);
    on<FetchPopularMovies>(_fetchPopularMovies);
    on<ToggleFavorite>(_toggleFavorite);
    on<FetchFavorites>(_fetchFavorites);
    _loadDeletedMovies();
  }

  Future<void> _fetchFavorites(FetchFavorites event, Emitter<MovieState> emit) async {
    emit(MoviesLoading());
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(MoviesError(message: "User not authenticated"));
      return;
    }

    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    try {
      var doc = await userRef.get();
      List<int> favoriteIds = [];
      if (doc.exists && doc.data()?['favorites'] != null) {
        favoriteIds = List<int>.from(doc.data()!['favorites']);
      }

      List<Movie> favoriteMovies = await movieApi.getMoviesByIds(favoriteIds);
      for (var movie in favoriteMovies) {
        movie.isFavorite = true; // Ensuring that isFavorite is set to true
      }

      emit(MoviesLoaded(movies: favoriteMovies));
    } catch (e) {
      emit(MoviesError(message: e.toString()));
    }
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

  Future<List<int>> _fetchFavoriteMovieIds() async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not authenticated");
    }

    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
    var doc = await userRef.get();
    if (doc.exists && doc.data()?['favorites'] != null) {
      return List<int>.from(doc.data()!['favorites']);
    }
    return [];
  }

  Future<void> _fetchMovieCategory(String category, Emitter<MovieState> emit) async {
    emit(MoviesLoading());
    try {
      List<int> favoriteIds = await _fetchFavoriteMovieIds();
      List<Movie> movies = await movieApi.getMovies(category);
      for (var movie in movies) {
        movie.isFavorite = favoriteIds.contains(movie.id);
      }
      emit(MoviesLoaded(movies: movies));
    } catch (e) {
      emit(MoviesError(message: e.toString()));
    }
  }

  Future<void> _fetchPopularMovies(FetchPopularMovies event, Emitter<MovieState> emit) async {
    await _fetchMovieCategory('popular', emit);
  }

  Future<void> _fetchTopRatedMovies(FetchTopRatedMovies event, Emitter<MovieState> emit) async {
    await _fetchMovieCategory('top_rated', emit);
  }

  Future<void> _fetchNowPlayingMovies(FetchNowPlayingMovies event, Emitter<MovieState> emit) async {
    await _fetchMovieCategory('now_playing', emit);
  }


  Future<void> _fetchMovies(FetchMovies event, Emitter<MovieState> emit) async {
    emit(MoviesLoading());
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);
        var doc = await userRef.get();
        List<int> favoriteIds = [];
        if (doc.exists && doc.data()?['favorites'] != null) {
          favoriteIds = List<int>.from(doc.data()!['favorites']);
        }

        List<Movie> movies = await movieApi.getMovies("upcoming");
        for (var movie in movies) {
          movie.isFavorite = favoriteIds.contains(movie.id);
        }

        emit(MoviesLoaded(movies: movies));
      } else {
        emit(MoviesError(message: "User not authenticated"));
      }
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

  Future<void> _toggleFavorite(ToggleFavorite event, Emitter<MovieState> emit) async {
    var user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      emit(MoviesError(message: "User not authenticated"));
      return;
    }

    var userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

    try {
      if (event.isFavorite) {
        await userRef.update({
          'favorites': FieldValue.arrayUnion([event.movieId])
        });
      } else {
        await userRef.update({
          'favorites': FieldValue.arrayRemove([event.movieId])
        });
      }

      // Re-emit MoviesLoaded with updated favorites
      if (state is MoviesLoaded) {
        List<Movie> updatedMovies = List<Movie>.from((state as MoviesLoaded).movies);
        var index = updatedMovies.indexWhere((m) => m.id == event.movieId);
        if (index != -1) {
          updatedMovies[index].isFavorite = event.isFavorite;
        }
        emit(MoviesLoaded(movies: updatedMovies)); // Emitting a new instance of MoviesLoaded
      }
    } catch (e) {
      emit(MoviesError(message: e.toString()));
    }
  }



}
