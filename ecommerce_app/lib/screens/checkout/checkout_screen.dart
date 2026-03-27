import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/stripe_service.dart';
import '../../utils/helpers.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isProcessing = false;

  // Shipping address controllers
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _address2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _prefillUserData();
  }

  void _prefillUserData() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (auth.isLoggedIn && auth.user != null) {
      _nameController.text = auth.user!.fullName;
      _phoneController.text = auth.user!.phone ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _address2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('Checkout')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Shipping Address'),
              const SizedBox(height: 12),
              _buildShippingForm(),
              const SizedBox(height: 28),
              _buildSectionTitle('Order Summary'),
              const SizedBox(height: 12),
              _buildOrderSummaryCard(cart),
              const SizedBox(height: 28),
              _buildSectionTitle('Payment'),
              const SizedBox(height: 12),
              _buildPaymentInfo(),
              const SizedBox(height: 32),
              _buildPayButton(cart),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _buildShippingForm() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'Full Name',
            icon: Icons.person_outline,
            validator: (v) =>
                v == null || v.isEmpty ? 'Name is required' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (v) =>
                v == null || v.isEmpty ? 'Phone is required' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _addressController,
            label: 'Street Address',
            icon: Icons.location_on_outlined,
            validator: (v) =>
                v == null || v.isEmpty ? 'Address is required' : null,
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _address2Controller,
            label: 'Apt, Suite, etc. (Optional)',
            icon: Icons.apartment_outlined,
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  icon: Icons.location_city_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _stateController,
                  label: 'State',
                  icon: Icons.map_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildTextField(
            controller: _zipController,
            label: 'ZIP Code',
            icon: Icons.markunread_mailbox_outlined,
            keyboardType: TextInputType.number,
            validator: (v) =>
                v == null || v.isEmpty ? 'ZIP is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
      ),
    );
  }

  Widget _buildOrderSummaryCard(CartProvider cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          ...cart.items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${item.product.title} x${item.quantity}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      Helpers.formatCurrency(item.totalPrice),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              )),
          const Divider(height: 20),
          _summaryRow('Subtotal', Helpers.formatCurrency(cart.subtotal)),
          const SizedBox(height: 4),
          _summaryRow(
            'Shipping',
            cart.hasFreeShipping
                ? 'FREE'
                : Helpers.formatCurrency(cart.shipping),
          ),
          const SizedBox(height: 4),
          _summaryRow('Tax', Helpers.formatCurrency(cart.tax)),
          const Divider(height: 20),
          _summaryRow(
            'Total',
            Helpers.formatCurrency(cart.total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
            color: isBold ? AppTheme.textPrimary : AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 18 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: isBold ? AppTheme.primaryColor : AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF635BFF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.credit_card,
              color: Color(0xFF635BFF),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pay with Stripe',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Secure payment via Stripe payment sheet',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline,
              size: 18, color: AppTheme.accentColor),
        ],
      ),
    );
  }

  Widget _buildPayButton(CartProvider cart) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: _isProcessing ? null : () => _processPayment(cart),
        child: _isProcessing
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : Text(
                'Pay ${Helpers.formatCurrency(cart.total)}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Future<void> _processPayment(CartProvider cart) async {
    if (!_formKey.currentState!.validate()) return;

    // Check if user is logged in
    final auth = Provider.of<AuthProvider>(context, listen: false);
    if (!auth.isLoggedIn) {
      Helpers.showSnackBar(context, 'Please login to continue', isError: true);
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final stripeService = StripeService();
      final result = await stripeService.processPayment(
        amount: cart.total,
        metadata: {
          'user_id': auth.user!.id,
          'item_count': cart.totalQuantity.toString(),
        },
      );

      if (!mounted) return;

      if (result.success) {
        // Create order
        final orderProvider =
            Provider.of<OrderProvider>(context, listen: false);

        final shippingAddress = ShippingAddress(
          fullName: _nameController.text.trim(),
          addressLine1: _addressController.text.trim(),
          addressLine2: _address2Controller.text.trim(),
          city: _cityController.text.trim(),
          state: _stateController.text.trim(),
          zipCode: _zipController.text.trim(),
          phone: _phoneController.text.trim(),
        );

        await orderProvider.placeOrder(
          items: List.from(cart.items),
          paymentIntentId: result.paymentIntentId,
          shippingAddress: shippingAddress,
        );

        // Clear cart
        await cart.clearCart();

        if (!mounted) return;

        Helpers.showSuccessDialog(
          context,
          title: 'Order Placed!',
          message:
              'Your order has been placed successfully. You can track it in your order history.',
          buttonText: 'View Orders',
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.orders,
              (route) => route.isFirst,
            );
          },
        );
      } else {
        Helpers.showSnackBar(context, result.message, isError: true);
      }
    } on StripePaymentException catch (e) {
      if (mounted) {
        Helpers.showSnackBar(context, e.message, isError: true);
      }
    } catch (e) {
      if (mounted) {
        Helpers.showSnackBar(
          context,
          'Something went wrong. Please try again.',
          isError: true,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
