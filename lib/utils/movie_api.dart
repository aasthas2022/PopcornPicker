// utils/movie_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieApi {
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String bearerToken = "INPUT YOUR BEARER TOKEN";

  Future<List<Movie>> getMovies(String category) async {
    final response = await http.get(
      Uri.parse('$baseUrl/movie/$category'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load movies');
    }
  }

  Future<List<Movie>> searchMovies(String query) async {
    final response = await http.get(Uri.parse('${baseUrl}/search/movie?&query=$query'),
      headers: {
        'Authorization': 'Bearer $bearerToken',
        'Content-Type': 'application/json',
      },);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final movies = (data['results'] as List).map((e) => Movie.fromJson(e)).toList();
      return movies;
    } else {
      throw Exception('Failed to load search results');
    }
  }

  Future<List<Movie>> getMoviesByIds(List<int> ids) async {
    List<Movie> movies = [];
    for (var id in ids) {
      final response = await http.get(
        Uri.parse('$baseUrl/movie/$id'),
        headers: {
          'Authorization': 'Bearer $bearerToken',
          'Content-Type': 'application/json',
        },
      );
      if (response.statusCode == 200) {
        movies.add(Movie.fromJson(json.decode(response.body)));
      } else {
        throw Exception('Failed to load movie with id $id');
      }
    }
    return movies;
  }
}