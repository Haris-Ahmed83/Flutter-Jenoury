import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../models/cart_item.dart';
import '../services/order_service.dart';

class OrderProvider with ChangeNotifier {
  final OrderService _orderService;

  List<Order> _orders = [];
  bool _isLoading = false;
  String? _error;

  OrderProvider({OrderService? orderService})
      : _orderService = orderService ?? OrderService();

  // Getters
  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasOrders => _orders.isNotEmpty;

  Future<void> loadOrders() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _orderService.getOrders();
    } catch (e) {
      _error = 'Failed to load orders: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Order> placeOrder({
    required List<CartItem> items,
    required String paymentIntentId,
    required ShippingAddress shippingAddress,
  }) async {
    try {
      final order = await _orderService.createOrder(
        items: items,
        paymentIntentId: paymentIntentId,
        shippingAddress: shippingAddress,
      );

      _orders.insert(0, order);
      notifyListeners();
      return order;
    } catch (e) {
      throw Exception('Failed to place order: $e');
    }
  }

  Future<void> updateOrderStatus(
      String orderId, OrderStatus status) async {
    try {
      await _orderService.updateOrderStatus(orderId, status);
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  Order? getOrderById(String id) {
    try {
      return _orders.firstWhere((order) => order.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Order> getOrdersByStatus(OrderStatus status) {
    return _orders.where((order) => order.status == status).toList();
  }
}
