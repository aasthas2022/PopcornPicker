// utils/movie_api.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/movie.dart';

class MovieApi {
  final String baseUrl = 'https://api.themoviedb.org/3';
  final String bearerToken = "eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI0NDdmYjAxZDU0OTk4NTZmZDE2NTViY2MzM2ZjYmQxYyIsInN1YiI6IjY1ZGZhNmYwYjE4ZjMyMDE3YjQ4NWU4YiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.J2STaW45cxZRQxWFY8H8wbkGaZf_MFUVzBZFFYZWbWo";

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
}