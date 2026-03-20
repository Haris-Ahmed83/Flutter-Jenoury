import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get stripePublishableKey =>
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';

  static String get stripeSecretKey =>
      dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  static String get stripeMerchantId =>
      dotenv.env['STRIPE_MERCHANT_ID'] ?? 'merchant.com.jenoury.ecommerce';

  static String get apiBaseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'https://fakestoreapi.com';

  static const String appName = 'Jenoury Shop';
  static const String appVersion = '1.0.0';
  static const String currency = 'USD';
  static const String currencySymbol = '\$';

  // Stripe configuration
  static const int stripePaymentTimeoutSeconds = 30;
  static const double minimumOrderAmount = 0.50;
  static const double freeShippingThreshold = 50.0;
  static const double standardShippingCost = 5.99;
  static const double taxRate = 0.08; // 8% tax
}
