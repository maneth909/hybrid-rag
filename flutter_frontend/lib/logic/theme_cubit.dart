import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit() : super(ThemeMode.system);

  void toggleTheme(BuildContext context) {
    bool isCurrentlyDark = Theme.of(context).brightness == Brightness.dark;
    emit(isCurrentlyDark ? ThemeMode.light : ThemeMode.dark);
  }
}
