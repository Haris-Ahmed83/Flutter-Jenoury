import 'package:google_generative_ai/google_generative_ai.dart';
import '../models/recipe_model.dart';
import 'dart:convert';

class AIService {
  static const String _apiKey = 'YOUR_GOOGLE_API_KEY_HERE';
  late final GenerativeModel _model;

  AIService() {
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: _apiKey,
    );
  }

  Future<List<Recipe>> searchRecipes(RecipeSearchQuery query) async {
    try {
      final prompt = _buildSearchPrompt(query);
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      final recipes = _parseRecipesFromResponse(response.text ?? '');
      return recipes;
    } catch (e) {
      throw Exception('Failed to search recipes: $e');
    }
  }

  String _buildSearchPrompt(RecipeSearchQuery query) {
    return '''
    Find 5 delicious recipes using these ingredients: ${query.ingredients.join(', ')}.
    ${query.cuisine != null ? 'Cuisine preference: ${query.cuisine}' : ''}
    ${query.mealType != null ? 'Meal type: ${query.mealType}' : ''}
    ${query.maxCookingTime != null ? 'Max cooking time: ${query.maxCookingTime?.toInt()} minutes' : ''}
    ${query.dietaryRestriction != null ? 'Dietary restriction: ${query.dietaryRestriction}' : ''}

    For each recipe, provide:
    1. Recipe name
    2. Brief description (1-2 sentences)
    3. Ingredients list
    4. Step-by-step cooking instructions
    5. Prep time (minutes)
    6. Cooking time (minutes)
    7. Servings
    8. Nutrition info (calories, protein, carbs, fat, fiber, sodium per serving)
    9. Recipe categories/tags

    Format response as JSON array with these exact fields for each recipe:
    {
      "id": "unique_id",
      "name": "recipe name",
      "description": "description",
      "ingredients": ["ingredient1", "ingredient2"],
      "instructions": ["step1", "step2"],
      "prepTime": 15,
      "cookingTime": 30,
      "servings": 4,
      "rating": 4.5,
      "reviewCount": 100,
      "nutritionInfo": {
        "calories": 300,
        "protein": 20,
        "carbs": 40,
        "fat": 10,
        "fiber": 5,
        "sodium": 500,
        "vitamins": {}
      },
      "categories": ["category1"],
      "imageUrl": "placeholder"
    }
    ''';
  }

  List<Recipe> _parseRecipesFromResponse(String response) {
    try {
      final jsonStr = response.replaceAll('```json', '').replaceAll('```', '').trim();
      final jsonData = jsonDecode(jsonStr) as List;
      return jsonData
          .map((recipe) => Recipe.fromJson(recipe as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return _generateMockRecipes();
    }
  }

  List<Recipe> _generateMockRecipes() {
    return [
      Recipe(
        id: '1',
        name: 'Vegetable Stir Fry',
        description: 'A quick and healthy vegetable stir fry with vibrant colors and delicious flavors.',
        ingredients: ['carrots', 'broccoli', 'bell peppers', 'soy sauce', 'garlic', 'ginger'],
        instructions: [
          'Chop all vegetables into bite-sized pieces',
          'Heat oil in a wok or large pan',
          'Add garlic and ginger, stir for 30 seconds',
          'Add vegetables and stir-fry for 5-7 minutes',
          'Add soy sauce and serve hot'
        ],
        cookingTime: 10,
        prepTime: 15,
        servings: 4,
        rating: 4.5,
        reviewCount: 245,
        nutritionInfo: NutritionInfo(
          calories: 150,
          protein: 5,
          carbs: 25,
          fat: 5,
          fiber: 4,
          sodium: 400,
        ),
        categories: ['vegetarian', 'quick', 'healthy'],
        imageUrl: 'assets/images/stir_fry.jpg',
      ),
      Recipe(
        id: '2',
        name: 'Pasta Primavera',
        description: 'A light and fresh pasta dish with seasonal vegetables.',
        ingredients: ['pasta', 'zucchini', 'cherry tomatoes', 'basil', 'olive oil', 'garlic'],
        instructions: [
          'Cook pasta according to package directions',
          'Sauté vegetables in olive oil',
          'Toss pasta with vegetables and basil',
          'Season with salt and pepper'
        ],
        cookingTime: 15,
        prepTime: 10,
        servings: 4,
        rating: 4.3,
        reviewCount: 189,
        nutritionInfo: NutritionInfo(
          calories: 280,
          protein: 10,
          carbs: 45,
          fat: 8,
          fiber: 5,
          sodium: 200,
        ),
        categories: ['vegetarian', 'pasta', 'italian'],
        imageUrl: 'assets/images/pasta_primavera.jpg',
      ),
    ];
  }
}
