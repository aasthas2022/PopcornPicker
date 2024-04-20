// main.dart

import 'package:flutter/material.dart';
import 'bloc/movie_bloc.dart';
import 'utils/dark_or_light_theme.dart';
import 'screens/main_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'utils/movie_api.dart';

void main() {
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  final MovieApi movieApi = MovieApi();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AppStateCubit>(
          create: (context) => AppStateCubit(),
        ),
        BlocProvider<MovieBloc>(
          create: (context) => MovieBloc(movieApi: movieApi),
        ),
      ],
      child: BlocBuilder<AppStateCubit, AppState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'Movie List App',
            theme: state.themeData,
            home: MovieListScreen(),
          );
        },
      ),
    );
  }
}
