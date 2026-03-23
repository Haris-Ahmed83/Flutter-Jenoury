import 'package:flutter/material.dart';

class NewsCategory {
  final String id;
  final String name;
  final String displayName;
  final IconData icon;
  final Color color;

  const NewsCategory({
    required this.id,
    required this.name,
    required this.displayName,
    required this.icon,
    required this.color,
  });

  static const List<NewsCategory> defaultCategories = [
    NewsCategory(
      id: 'general',
      name: 'general',
      displayName: 'Top Stories',
      icon: Icons.public,
      color: Color(0xFF2196F3),
    ),
    NewsCategory(
      id: 'business',
      name: 'business',
      displayName: 'Business',
      icon: Icons.business_center,
      color: Color(0xFF4CAF50),
    ),
    NewsCategory(
      id: 'technology',
      name: 'technology',
      displayName: 'Technology',
      icon: Icons.computer,
      color: Color(0xFF9C27B0),
    ),
    NewsCategory(
      id: 'science',
      name: 'science',
      displayName: 'Science',
      icon: Icons.science,
      color: Color(0xFFFF9800),
    ),
    NewsCategory(
      id: 'health',
      name: 'health',
      displayName: 'Health',
      icon: Icons.health_and_safety,
      color: Color(0xFFE91E63),
    ),
    NewsCategory(
      id: 'sports',
      name: 'sports',
      displayName: 'Sports',
      icon: Icons.sports_soccer,
      color: Color(0xFF00BCD4),
    ),
    NewsCategory(
      id: 'entertainment',
      name: 'entertainment',
      displayName: 'Entertainment',
      icon: Icons.movie,
      color: Color(0xFFFF5722),
    ),
  ];

  static NewsCategory fromId(String id) {
    return defaultCategories.firstWhere(
      (cat) => cat.id == id,
      orElse: () => defaultCategories.first,
    );
  }
}
