import 'package:flutter/material.dart';
import '../constants/theme_constants.dart';

class SearchWidget extends StatefulWidget {
  final VoidCallback onSearchTriggered;
  final Function(List<String>) onIngredientsChanged;
  final Function(String?) onCuisineChanged;
  final Function(String?) onMealTypeChanged;
  final Function(double?) onCookingTimeChanged;
  final Function(String?) onDietChanged;

  const SearchWidget({
    Key? key,
    required this.onSearchTriggered,
    required this.onIngredientsChanged,
    required this.onCuisineChanged,
    required this.onMealTypeChanged,
    required this.onCookingTimeChanged,
    required this.onDietChanged,
  }) : super(key: key);

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController _ingredientController = TextEditingController();
  List<String> _ingredients = [];
  String? _selectedCuisine;
  String? _selectedMealType;
  String? _selectedDiet;

  final List<String> _cuisines = [
    'Italian',
    'Asian',
    'Mexican',
    'Indian',
    'Mediterranean',
    'American',
  ];

  final List<String> _mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack'];
  final List<String> _diets = ['Vegetarian', 'Vegan', 'Gluten-Free', 'Keto', 'Paleo'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Search Recipes',
          style: AppTextStyles.heading2,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildIngredientInput(),
        const SizedBox(height: AppSpacing.lg),
        if (_ingredients.isNotEmpty) _buildIngredientChips(),
        const SizedBox(height: AppSpacing.lg),
        _buildFilterRow(),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: widget.onSearchTriggered,
            icon: const Icon(Icons.search),
            label: const Text('Search Recipes'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIngredientInput() {
    return TextField(
      controller: _ingredientController,
      decoration: InputDecoration(
        hintText: 'Add an ingredient (e.g., tomato, chicken)',
        prefixIcon: const Icon(Icons.add_circle_outline),
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: _addIngredient,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
      onSubmitted: (_) => _addIngredient(),
    );
  }

  Widget _buildIngredientChips() {
    return Wrap(
      spacing: AppSpacing.md,
      runSpacing: AppSpacing.md,
      children: _ingredients.map((ingredient) {
        return Chip(
          label: Text(ingredient),
          onDeleted: () => _removeIngredient(ingredient),
          backgroundColor: AppColors.primaryLight,
          labelStyle: const TextStyle(color: AppColors.primary),
        );
      }).toList(),
    );
  }

  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildDropdown(
            label: 'Cuisine',
            value: _selectedCuisine,
            items: _cuisines,
            onChanged: (value) {
              setState(() => _selectedCuisine = value);
              widget.onCuisineChanged(value);
            },
          ),
          const SizedBox(width: AppSpacing.md),
          _buildDropdown(
            label: 'Meal Type',
            value: _selectedMealType,
            items: _mealTypes,
            onChanged: (value) {
              setState(() => _selectedMealType = value);
              widget.onMealTypeChanged(value);
            },
          ),
          const SizedBox(width: AppSpacing.md),
          _buildDropdown(
            label: 'Diet',
            value: _selectedDiet,
            items: _diets,
            onChanged: (value) {
              setState(() => _selectedDiet = value);
              widget.onDietChanged(value);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.borderColor),
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: DropdownButton<String>(
        hint: Text(label),
        value: value,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _addIngredient() {
    if (_ingredientController.text.isNotEmpty) {
      setState(() {
        if (!_ingredients.contains(_ingredientController.text)) {
          _ingredients.add(_ingredientController.text);
          widget.onIngredientsChanged(_ingredients);
        }
        _ingredientController.clear();
      });
    }
  }

  void _removeIngredient(String ingredient) {
    setState(() {
      _ingredients.remove(ingredient);
      widget.onIngredientsChanged(_ingredients);
    });
  }

  @override
  void dispose() {
    _ingredientController.dispose();
    super.dispose();
  }
}
