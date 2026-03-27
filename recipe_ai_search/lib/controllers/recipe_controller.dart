import 'package:flutter/material.dart';
import '../models/recipe_model.dart';
import '../services/ai_service.dart';

class RecipeController extends ChangeNotifier {
  final AIService _aiService = AIService();

  List<Recipe> _recipes = [];
  List<Recipe> _searchResults = [];
  bool _isLoading = false;
  String? _error;

  List<Recipe> get recipes => _recipes;
  List<Recipe> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> searchByIngredients({
    required List<String> ingredients,
    String? cuisine,
    String? mealType,
    double? maxCookingTime,
    String? dietaryRestriction,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final query = RecipeSearchQuery(
        ingredients: ingredients,
        cuisine: cuisine,
        mealType: mealType,
        maxCookingTime: maxCookingTime,
        dietaryRestriction: dietaryRestriction,
      );

      final results = await _aiService.searchRecipes(query);
      _searchResults = results;
    } catch (e) {
      _error = 'Error searching recipes: ${e.toString()}';
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getRecipeDetails(String recipeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final recipe = _searchResults.firstWhere(
        (r) => r.id == recipeId,
        orElse: () => _recipes.firstWhere(
          (r) => r.id == recipeId,
          orElse: () => Recipe(
            id: recipeId,
            name: 'Unknown',
            description: '',
            ingredients: [],
            instructions: [],
            cookingTime: 0,
            prepTime: 0,
            servings: 1,
            rating: 0,
            reviewCount: 0,
            nutritionInfo: NutritionInfo(
              calories: 0,
              protein: 0,
              carbs: 0,
              fat: 0,
              fiber: 0,
              sodium: 0,
            ),
            categories: [],
            imageUrl: '',
          ),
        ),
      );

      if (!_recipes.any((r) => r.id == recipeId)) {
        _recipes.add(recipe);
      }
    } catch (e) {
      _error = 'Error fetching recipe details: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _searchResults = [];
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
