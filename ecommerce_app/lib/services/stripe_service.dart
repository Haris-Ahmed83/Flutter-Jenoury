import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';

class StripeService {
  static final StripeService _instance = StripeService._internal();
  factory StripeService() => _instance;
  StripeService._internal();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    Stripe.merchantIdentifier = AppConfig.stripeMerchantId;
    await Stripe.instance.applySettings();
    _isInitialized = true;
  }

  /// Creates a PaymentIntent on the backend and returns the client secret.
  /// In production, this call goes to YOUR backend server.
  /// For demo/testing, we simulate a successful payment flow.
  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    String currency = 'usd',
    Map<String, String>? metadata,
  }) async {
    try {
      // Convert to cents for Stripe
      final amountInCents = (amount * 100).toInt();

      if (amountInCents < 50) {
        throw StripePaymentException(
          'Minimum payment amount is \$0.50',
        );
      }

      // In production, call YOUR backend endpoint:
      // final response = await http.post(
      //   Uri.parse('${AppConfig.apiBaseUrl}/payments/create-intent'),
      //   headers: {
      //     'Content-Type': 'application/json',
      //     'Authorization': 'Bearer $userToken',
      //   },
      //   body: json.encode({
      //     'amount': amountInCents,
      //     'currency': currency,
      //     'metadata': metadata,
      //   }),
      // );

      // For testing without a backend, create PaymentIntent using Stripe secret key directly.
      // WARNING: In production, NEVER use the secret key on the client side.
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer ${AppConfig.stripeSecretKey}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amountInCents.toString(),
          'currency': currency,
          'payment_method_types[]': 'card',
          if (metadata != null)
            ...metadata.map((key, value) => MapEntry('metadata[$key]', value)),
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final error = json.decode(response.body);
        throw StripePaymentException(
          error['error']?['message'] ?? 'Failed to create payment intent',
        );
      }
    } catch (e) {
      if (e is StripePaymentException) rethrow;
      throw StripePaymentException('Payment initialization failed: $e');
    }
  }

  /// Presents the Stripe payment sheet to the user.
  Future<bool> presentPaymentSheet({
    required String clientSecret,
    required String merchantName,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: clientSecret,
          merchantDisplayName: merchantName,
          style: ThemeMode.system,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              primary: Color(0xFF1E3A5F),
            ),
            shapes: PaymentSheetShape(
              borderRadius: 12,
            ),
          ),
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      return true;
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        return false; // User cancelled
      }
      throw StripePaymentException(
        e.error.localizedMessage ?? 'Payment failed',
      );
    } catch (e) {
      throw StripePaymentException('Payment sheet error: $e');
    }
  }

  /// Full payment flow: create intent + present sheet
  Future<PaymentResult> processPayment({
    required double amount,
    String currency = 'usd',
    Map<String, String>? metadata,
  }) async {
    try {
      final paymentIntent = await createPaymentIntent(
        amount: amount,
        currency: currency,
        metadata: metadata,
      );

      final clientSecret = paymentIntent['client_secret'] as String;
      final paymentIntentId = paymentIntent['id'] as String;

      final success = await presentPaymentSheet(
        clientSecret: clientSecret,
        merchantName: AppConfig.appName,
      );

      if (success) {
        return PaymentResult(
          success: true,
          paymentIntentId: paymentIntentId,
          message: 'Payment successful',
        );
      } else {
        return PaymentResult(
          success: false,
          paymentIntentId: paymentIntentId,
          message: 'Payment cancelled by user',
        );
      }
    } on StripePaymentException {
      rethrow;
    } catch (e) {
      throw StripePaymentException('Payment processing error: $e');
    }
  }
}

class PaymentResult {
  final bool success;
  final String paymentIntentId;
  final String message;

  const PaymentResult({
    required this.success,
    required this.paymentIntentId,
    required this.message,
  });
}

class StripePaymentException implements Exception {
  final String message;
  StripePaymentException(this.message);

  @override
  String toString() => message;
}
