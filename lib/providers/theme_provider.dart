import 'package:flutter/material.dart';

import '../services/storage_service.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage) : _darkMode = _storage.loadDarkMode();

  final StorageService _storage;
  bool _darkMode;

  bool get darkMode => _darkMode;

  ThemeMode get themeMode => _darkMode ? ThemeMode.dark : ThemeMode.light;

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _storage.saveDarkMode(value);
  }
}
