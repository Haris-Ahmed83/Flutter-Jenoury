import 'package:flutter/foundation.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../services/cart_service.dart';
import '../config/app_config.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService;

  List<CartItem> _items = [];
  bool _isLoading = false;

  CartProvider({CartService? cartService})
      : _cartService = cartService ?? CartService();

  // Getters
  List<CartItem> get items => _items;
  bool get isLoading => _isLoading;
  bool get isEmpty => _items.isEmpty;
  int get itemCount => _items.length;
  int get totalQuantity =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  double get shipping =>
      subtotal >= AppConfig.freeShippingThreshold || _items.isEmpty
          ? 0.0
          : AppConfig.standardShippingCost;

  double get tax => subtotal * AppConfig.taxRate;
  double get total => subtotal + shipping + tax;

  bool get hasFreeShipping => subtotal >= AppConfig.freeShippingThreshold;
  double get amountUntilFreeShipping =>
      AppConfig.freeShippingThreshold - subtotal;

  Future<void> loadCart() async {
    _isLoading = true;
    notifyListeners();

    try {
      _items = await _cartService.loadCart();
    } catch (_) {
      _items = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Product product, {int quantity = 1}) async {
    final existingIndex =
        _items.indexWhere((item) => item.product.id == product.id);

    if (existingIndex >= 0) {
      _items[existingIndex].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }

    notifyListeners();
    await _cartService.saveCart(_items);
  }

  Future<void> removeFromCart(int productId) async {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
    await _cartService.saveCart(_items);
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await removeFromCart(productId);
      return;
    }

    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
      await _cartService.saveCart(_items);
    }
  }

  Future<void> incrementQuantity(int productId) async {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
      await _cartService.saveCart(_items);
    }
  }

  Future<void> decrementQuantity(int productId) async {
    final index =
        _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        notifyListeners();
        await _cartService.saveCart(_items);
      } else {
        await removeFromCart(productId);
      }
    }
  }

  bool isInCart(int productId) {
    return _items.any((item) => item.product.id == productId);
  }

  int getQuantity(int productId) {
    try {
      return _items
          .firstWhere((item) => item.product.id == productId)
          .quantity;
    } catch (_) {
      return 0;
    }
  }

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
    await _cartService.clearCart();
  }
}
