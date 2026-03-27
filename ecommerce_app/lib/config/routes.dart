import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/product_detail/product_detail_screen.dart';
import '../screens/cart/cart_screen.dart';
import '../screens/checkout/checkout_screen.dart';
import '../screens/orders/orders_screen.dart';
import '../screens/orders/order_detail_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../models/product.dart';
import '../models/order.dart' as order_model;

class AppRoutes {
  static const String home = '/';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String orderDetail = '/order-detail';
  static const String login = '/login';
  static const String register = '/register';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case home:
        return _buildRoute(const HomeScreen());

      case productDetail:
        final product = settings.arguments as Product;
        return _buildRoute(ProductDetailScreen(product: product));

      case cart:
        return _buildRoute(const CartScreen());

      case checkout:
        return _buildRoute(const CheckoutScreen());

      case orders:
        return _buildRoute(const OrdersScreen());

      case orderDetail:
        final order = settings.arguments as order_model.Order;
        return _buildRoute(OrderDetailScreen(order: order));

      case login:
        return _buildRoute(const LoginScreen());

      case register:
        return _buildRoute(const RegisterScreen());

      case profile:
        return _buildRoute(const ProfileScreen());

      default:
        return _buildRoute(
          const Scaffold(
            body: Center(child: Text('Page not found')),
          ),
        );
    }
  }

  static MaterialPageRoute _buildRoute(Widget page) {
    return MaterialPageRoute(builder: (_) => page);
  }
}
