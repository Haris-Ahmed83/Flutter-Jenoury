import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/recipe_controller.dart';
import '../controllers/favorites_controller.dart';
import '../widgets/search_widget.dart';
import '../widgets/recipe_card.dart';
import '../constants/theme_constants.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<String> _selectedIngredients = [];
  String? _selectedCuisine;
  String? _selectedMealType;
  double? _maxCookingTime;
  String? _selectedDiet;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget>[
            SliverAppBar(
              floating: true,
              snap: true,
              elevation: 0,
              backgroundColor: AppColors.white,
              title: const Text(
                'Recipe AI Search',
                style: AppTextStyles.heading3,
              ),
              bottom: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMedium,
                indicatorColor: AppColors.primary,
                tabs: const [
                  Tab(text: 'Discover'),
                  Tab(text: 'Favorites'),
                ],
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildDiscoverTab(),
            _buildFavoritesTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDiscoverTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchWidget(
            onSearchTriggered: _handleSearch,
            onIngredientsChanged: (ingredients) {
              setState(() => _selectedIngredients.clear());
              _selectedIngredients.addAll(ingredients);
            },
            onCuisineChanged: (cuisine) {
              setState(() => _selectedCuisine = cuisine);
            },
            onMealTypeChanged: (mealType) {
              setState(() => _selectedMealType = mealType);
            },
            onCookingTimeChanged: (time) {
              setState(() => _maxCookingTime = time);
            },
            onDietChanged: (diet) {
              setState(() => _selectedDiet = diet);
            },
          ),
          const SizedBox(height: AppSpacing.xl),
          Consumer<RecipeController>(
            builder: (context, controller, _) {
              if (controller.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        controller.error!,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      ElevatedButton.icon(
                        onPressed: () => controller.clearError(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              if (controller.searchResults.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off,
                        size: 64,
                        color: AppColors.textLight,
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text(
                        'Start by selecting ingredients',
                        style: AppTextStyles.bodyLarge,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Search for delicious recipes based on what you have',
                        style: AppTextStyles.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.85,
                  crossAxisSpacing: AppSpacing.lg,
                  mainAxisSpacing: AppSpacing.lg,
                ),
                itemCount: controller.searchResults.length,
                itemBuilder: (context, index) {
                  final recipe = controller.searchResults[index];
                  return RecipeCard(recipe: recipe);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<FavoritesController>(
      builder: (context, favoritesController, _) {
        if (favoritesController.favorites.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: AppColors.textLight,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'No favorites yet',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Add recipes to your favorites to see them here',
                  style: AppTextStyles.bodySmall,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: AppSpacing.lg,
            mainAxisSpacing: AppSpacing.lg,
          ),
          itemCount: favoritesController.favorites.length,
          itemBuilder: (context, index) {
            final recipe = favoritesController.favorites[index];
            return RecipeCard(recipe: recipe);
          },
        );
      },
    );
  }

  void _handleSearch() {
    if (_selectedIngredients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one ingredient'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    context.read<RecipeController>().searchByIngredients(
          ingredients: _selectedIngredients,
          cuisine: _selectedCuisine,
          mealType: _selectedMealType,
          maxCookingTime: _maxCookingTime,
          dietaryRestriction: _selectedDiet,
        );
  }
}
