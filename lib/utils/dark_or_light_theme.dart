// utils/dark_or_light_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppState {
  final ThemeData themeData;

  AppState({required this.themeData});

  AppState copyWith({ThemeData? themeData}) {
    return AppState(themeData: themeData ?? this.themeData);
  }
}

class AppStateCubit extends Cubit<AppState> {
  AppStateCubit() : super(AppState(themeData: ThemeData.light())) {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkMode = prefs.getBool('isDarkMode') ?? false;
    emit(AppState(themeData: isDarkMode ? ThemeData.dark() : ThemeData.light()));
  }

  void toggleTheme() async {
    final isDarkMode = state.themeData.brightness == Brightness.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', !isDarkMode);
    emit(AppState(themeData: !isDarkMode ? ThemeData.dark() : ThemeData.light()));
  }
}
