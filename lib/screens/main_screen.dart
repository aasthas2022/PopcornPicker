import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../bloc/movie_state.dart';
import '../utils/dark_or_light_theme.dart';
import '../widgets/search.dart';
import '../widgets/movie_card.dart';
import 'detail_screen.dart';
import '../services/auth_service.dart';

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<MovieBloc>().add(FetchMovies());
  }

  void _onSearchChanged() {
    context.read<MovieBloc>().add(SearchMovies(_searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double cardWidth = screenWidth * 0.9;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Movie List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepOrange,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: MovieSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.lightbulb_outline),
            onPressed: () => context.read<AppStateCubit>().toggleTheme(),
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
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
                    child: SizedBox(
                      width: cardWidth,
                      child: MovieCardWidget(movie: movie),
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
      ),
    );
  }
}
