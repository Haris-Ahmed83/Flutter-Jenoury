
class Recipe {
  final String id;
  final String name;
  final String description;
  final List<String> ingredients;
  final List<String> instructions;
  final int cookingTime; // in minutes
  final int prepTime; // in minutes
  final int servings;
  final double rating;
  final int reviewCount;
  final NutritionInfo nutritionInfo;
  final List<String> categories;
  final String imageUrl;
  final String? source;
  final DateTime createdAt;

  Recipe({
    required this.id,
    required this.name,
    required this.description,
    required this.ingredients,
    required this.instructions,
    required this.cookingTime,
    required this.prepTime,
    required this.servings,
    required this.rating,
    required this.reviewCount,
    required this.nutritionInfo,
    required this.categories,
    required this.imageUrl,
    this.source,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get totalTime => cookingTime + prepTime;

  String get formattedRating => rating.toStringAsFixed(1);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'ingredients': ingredients,
      'instructions': instructions,
      'cookingTime': cookingTime,
      'prepTime': prepTime,
      'servings': servings,
      'rating': rating,
      'reviewCount': reviewCount,
      'nutritionInfo': nutritionInfo.toJson(),
      'categories': categories,
      'imageUrl': imageUrl,
      'source': source,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Unknown Recipe',
      description: json['description'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
      instructions: List<String>.from(json['instructions'] ?? []),
      cookingTime: json['cookingTime'] ?? 0,
      prepTime: json['prepTime'] ?? 0,
      servings: json['servings'] ?? 1,
      rating: (json['rating'] ?? 0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      nutritionInfo: NutritionInfo.fromJson(json['nutritionInfo'] ?? {}),
      categories: List<String>.from(json['categories'] ?? []),
      imageUrl: json['imageUrl'] ?? '',
      source: json['source'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

class NutritionInfo {
  final double calories;
  final double protein; // in grams
  final double carbs; // in grams
  final double fat; // in grams
  final double fiber; // in grams
  final double sodium; // in mg
  final Map<String, double> vitamins;

  NutritionInfo({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.fiber,
    required this.sodium,
    this.vitamins = const {},
  });

  String get caloriesPerServing => calories.toStringAsFixed(0);

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'fiber': fiber,
      'sodium': sodium,
      'vitamins': vitamins,
    };
  }

  factory NutritionInfo.fromJson(Map<String, dynamic> json) {
    return NutritionInfo(
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      fiber: (json['fiber'] ?? 0).toDouble(),
      sodium: (json['sodium'] ?? 0).toDouble(),
      vitamins: Map<String, double>.from(
        (json['vitamins'] as Map?)?.map(
              (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
            ) ??
            {},
      ),
    );
  }
}

class RecipeSearchQuery {
  final List<String> ingredients;
  final String? cuisine;
  final String? mealType;
  final double? maxCookingTime;
  final String? dietaryRestriction;

  RecipeSearchQuery({
    required this.ingredients,
    this.cuisine,
    this.mealType,
    this.maxCookingTime,
    this.dietaryRestriction,
  });

  String buildPrompt() {
    final prompt = StringBuffer();
    prompt.write('Find recipes using these ingredients: ${ingredients.join(", ")}');

    if (cuisine != null) prompt.write(', cuisine: $cuisine');
    if (mealType != null) prompt.write(', meal type: $mealType');
    if (maxCookingTime != null) prompt.write(', max cooking time: ${maxCookingTime!.toInt()} minutes');
    if (dietaryRestriction != null) prompt.write(', dietary: $dietaryRestriction');

    return prompt.toString();
  }
}
