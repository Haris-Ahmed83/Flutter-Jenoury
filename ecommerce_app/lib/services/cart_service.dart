import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/cart_item.dart';

class CartService {
  static const String _cartKey = 'shopping_cart';

  Future<List<CartItem>> loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final cartData = prefs.getString(_cartKey);
    if (cartData != null) {
      final List<dynamic> jsonList = json.decode(cartData);
      return jsonList
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  Future<void> saveCart(List<CartItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = items.map((item) => item.toJson()).toList();
    await prefs.setString(_cartKey, json.encode(jsonList));
  }

  Future<void> clearCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cartKey);
  }
}
