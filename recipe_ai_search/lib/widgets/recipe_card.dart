import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/recipe_model.dart';
import '../controllers/favorites_controller.dart';
import '../constants/theme_constants.dart';
import 'recipe_detail_sheet.dart';

class RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const RecipeCard({
    Key? key,
    required this.recipe,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<FavoritesController>(
      builder: (context, favoritesController, _) {
        final isFavorite = favoritesController.isFavorite(recipe.id);

        return GestureDetector(
          onTap: () => _showRecipeDetails(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              boxShadow: const [AppShadows.elevation1],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppRadius.lg),
                      topRight: Radius.circular(AppRadius.lg),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.restaurant,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                // Content Section
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Rating
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              size: 14,
                              color: AppColors.secondary,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              recipe.formattedRating,
                              style: AppTextStyles.bodySmall.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '(${recipe.reviewCount})',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Time & Servings
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: AppColors.textMedium,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${recipe.totalTime}min',
                              style: AppTextStyles.caption,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Icon(
                              Icons.people,
                              size: 12,
                              color: AppColors.textMedium,
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${recipe.servings} servings',
                              style: AppTextStyles.caption,
                            ),
                          ],
                        ),
                        const Spacer(),
                        // Favorite Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _toggleFavorite(
                              context,
                              favoritesController,
                              isFavorite,
                            ),
                            icon: Icon(
                              isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 16,
                            ),
                            label: Text(
                              isFavorite ? 'Saved' : 'Save',
                              style: const TextStyle(fontSize: 12),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isFavorite
                                  ? AppColors.primary
                                  : AppColors.borderColor,
                              foregroundColor: isFavorite
                                  ? AppColors.white
                                  : AppColors.textDark,
                              padding: const EdgeInsets.symmetric(
                                vertical: AppSpacing.sm,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRecipeDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppRadius.xl),
          topRight: Radius.circular(AppRadius.xl),
        ),
      ),
      builder: (context) => RecipeDetailSheet(recipe: recipe),
    );
  }

  void _toggleFavorite(
    BuildContext context,
    FavoritesController controller,
    bool isFavorite,
  ) {
    if (isFavorite) {
      controller.removeFavorite(recipe.id);
    } else {
      controller.addFavorite(recipe);
    }
  }
}
