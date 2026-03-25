import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/recipe_model.dart';

class FavoritesController extends ChangeNotifier {
  List<Recipe> _favorites = [];
  late SharedPreferences _prefs;
  bool _initialized = false;

  List<Recipe> get favorites => _favorites;
  bool get isInitialized => _initialized;

  FavoritesController() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadFavorites();
      _initialized = true;
      notifyListeners();
    } catch (e) {
      print('Error initializing FavoritesController: $e');
    }
  }

  Future<void> _loadFavorites() async {
    try {
      final favoritesJson = _prefs.getString('favorites');
      if (favoritesJson != null) {
        final List<dynamic> decoded = jsonDecode(favoritesJson);
        _favorites = decoded
            .map((item) => Recipe.fromJson(item as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      print('Error loading favorites: $e');
      _favorites = [];
    }
  }

  Future<void> addFavorite(Recipe recipe) async {
    if (!_favorites.any((r) => r.id == recipe.id)) {
      _favorites.add(recipe);
      await _saveFavorites();
      notifyListeners();
    }
  }

  Future<void> removeFavorite(String recipeId) async {
    _favorites.removeWhere((r) => r.id == recipeId);
    await _saveFavorites();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    try {
      final favoritesJson = jsonEncode(
        _favorites.map((r) => r.toJson()).toList(),
      );
      await _prefs.setString('favorites', favoritesJson);
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  bool isFavorite(String recipeId) {
    return _favorites.any((r) => r.id == recipeId);
  }

  void clearAll() {
    _favorites.clear();
    _saveFavorites();
    notifyListeners();
  }
}
