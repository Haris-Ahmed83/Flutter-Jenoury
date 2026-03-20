import 'package:flutter/foundation.dart';
import '../models/product.dart';
import '../services/api_service.dart';

class ProductProvider with ChangeNotifier {
  final ApiService _apiService;

  List<Product> _products = [];
  List<Product> _filteredProducts = [];
  List<String> _categories = [];
  String _selectedCategory = 'All';
  String _searchQuery = '';
  bool _isLoading = false;
  String? _error;
  SortOption _sortOption = SortOption.none;

  ProductProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters
  List<Product> get products => _filteredProducts;
  List<Product> get allProducts => _products;
  List<String> get categories => ['All', ..._categories];
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get error => _error;
  SortOption get sortOption => _sortOption;

  Future<void> loadProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _apiService.fetchProducts(),
        _apiService.fetchCategories(),
      ]);

      _products = results[0] as List<Product>;
      _categories = (results[1] as List<String>);
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setSortOption(SortOption option) {
    _sortOption = option;
    _applyFilters();
    notifyListeners();
  }

  void clearFilters() {
    _selectedCategory = 'All';
    _searchQuery = '';
    _sortOption = SortOption.none;
    _filteredProducts = List.from(_products);
    notifyListeners();
  }

  Product? getProductById(int id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  void _applyFilters() {
    _filteredProducts = List.from(_products);

    // Category filter
    if (_selectedCategory != 'All') {
      _filteredProducts = _filteredProducts
          .where((p) => p.category == _selectedCategory)
          .toList();
    }

    // Search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      _filteredProducts = _filteredProducts
          .where((p) =>
              p.title.toLowerCase().contains(query) ||
              p.description.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query))
          .toList();
    }

    // Sort
    switch (_sortOption) {
      case SortOption.priceLowToHigh:
        _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceHighToLow:
        _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.rating:
        _filteredProducts
            .sort((a, b) => b.rating.rate.compareTo(a.rating.rate));
        break;
      case SortOption.nameAZ:
        _filteredProducts.sort((a, b) => a.title.compareTo(b.title));
        break;
      case SortOption.nameZA:
        _filteredProducts.sort((a, b) => b.title.compareTo(a.title));
        break;
      case SortOption.none:
        break;
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}

enum SortOption {
  none,
  priceLowToHigh,
  priceHighToLow,
  rating,
  nameAZ,
  nameZA;

  String get displayName {
    switch (this) {
      case SortOption.none:
        return 'Default';
      case SortOption.priceLowToHigh:
        return 'Price: Low to High';
      case SortOption.priceHighToLow:
        return 'Price: High to Low';
      case SortOption.rating:
        return 'Highest Rated';
      case SortOption.nameAZ:
        return 'Name: A-Z';
      case SortOption.nameZA:
        return 'Name: Z-A';
    }
  }
}
