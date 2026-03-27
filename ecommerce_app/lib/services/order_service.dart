import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../config/app_config.dart';

class OrderService {
  static const String _ordersKey = 'user_orders';
  final Uuid _uuid = const Uuid();

  Future<Order> createOrder({
    required List<CartItem> items,
    required String paymentIntentId,
    required ShippingAddress shippingAddress,
  }) async {
    final subtotal = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );

    final shipping = subtotal >= AppConfig.freeShippingThreshold
        ? 0.0
        : AppConfig.standardShippingCost;

    final tax = subtotal * AppConfig.taxRate;
    final total = subtotal + shipping + tax;

    final order = Order(
      id: _uuid.v4(),
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      total: total,
      status: OrderStatus.processing,
      createdAt: DateTime.now(),
      paymentIntentId: paymentIntentId,
      shippingAddress: shippingAddress,
    );

    await _saveOrder(order);
    return order;
  }

  Future<List<Order>> getOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final ordersData = prefs.getString(_ordersKey);
    if (ordersData != null) {
      final List<dynamic> jsonList = json.decode(ordersData);
      final orders = jsonList
          .map((item) => Order.fromJson(item as Map<String, dynamic>))
          .toList();
      // Most recent first
      orders.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return orders;
    }
    return [];
  }

  Future<Order?> getOrderById(String id) async {
    final orders = await getOrders();
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    final orders = await getOrders();
    final index = orders.indexWhere((order) => order.id == orderId);
    if (index != -1) {
      orders[index] = orders[index].copyWith(status: status);
      await _saveAllOrders(orders);
    }
  }

  Future<void> _saveOrder(Order order) async {
    final orders = await getOrders();
    orders.insert(0, order);
    await _saveAllOrders(orders);
  }

  Future<void> _saveAllOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = orders.map((order) => order.toJson()).toList();
    await prefs.setString(_ordersKey, json.encode(jsonList));
  }
}
