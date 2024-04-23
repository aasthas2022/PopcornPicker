// screens/main_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie_list/screens/profile_edit_screen.dart';
import '../bloc/movie_bloc.dart';
import '../bloc/movie_event.dart';
import '../widgets/search.dart';
import '../services/auth_service.dart';
import 'movie_category_screen.dart';

class MovieListScreen extends StatefulWidget {
  @override
  _MovieListScreenState createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _onSearchChanged() {
    context.read<MovieBloc>().add(SearchMovies(_searchController.text));
  }

  int _currentIndex = 0;
  final List<Widget> _children = [
    MovieCategoryScreen(category: 'upcoming'),
    MovieCategoryScreen(category: 'top_rated'),
    MovieCategoryScreen(category: 'now_playing'),
    MovieCategoryScreen(category: 'popular'),
    MovieCategoryScreen(category: 'favorites'),
  ];

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
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
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService().signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
          _buildProfileIcon(),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.movie_filter),
            label: 'Upcoming',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Top Rated',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            label: 'Now Playing',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Popular',
          ),
          BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favorites'),
        ],
      ),
    );
  }

  Widget _buildProfileIcon() {
    return PopupMenuButton<int>(
      onSelected: (item) => _select(item, context),
      itemBuilder: (context) => [
        PopupMenuItem<int>(
          value: 0,
          child: Row(
            children: [
              SizedBox(width: 8),
              Text('View and Edit Profile'),
            ],
          ),
        ),
      ],
      icon: Icon(Icons.account_circle),
    );
  }

  void _select(int item, BuildContext context) {
    switch (item) {
      case 0:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => ProfileEditScreen()),
        );
        break;
    }
  }
}

