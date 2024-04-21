import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'bloc/movie_bloc.dart';
import 'screens/main_screen.dart';
import 'screens/login_screen.dart';
import 'screens/profile_edit_screen.dart';
import 'utils/dark_or_light_theme.dart';
import 'utils/movie_api.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MovieApp());
}

class MovieApp extends StatelessWidget {
  final MovieApi movieApi = MovieApi();
  final AuthService authService = AuthService();

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
      child: MaterialApp(
        title: 'Movie List App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: StreamBuilder(
          stream: authService.userChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.active) {
              if (snapshot.hasData) {
                return MovieListScreen();
              }
              return LoginScreen();
            }
            return Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          },
        ),
        routes: {
          '/main': (context) => MovieListScreen(),
          '/login': (context) => LoginScreen(),
          '/profile_edit': (context) => ProfileEditScreen(),
        },
      ),
    );
  }
}
