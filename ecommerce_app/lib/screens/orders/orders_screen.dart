import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/routes.dart';
import '../../config/theme.dart';
import '../../models/order.dart';
import '../../providers/order_provider.dart';
import '../../utils/helpers.dart';

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(title: const Text('My Orders')),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, _) {
          if (orderProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          if (!orderProvider.hasOrders) {
            return _buildEmptyOrders(context);
          }

          return RefreshIndicator(
            onRefresh: () => orderProvider.loadOrders(),
            color: AppTheme.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: orderProvider.orders.length,
              itemBuilder: (context, index) {
                return _buildOrderCard(context, orderProvider.orders[index]);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrders(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.receipt_long_outlined,
                size: 80, color: Colors.grey.shade300),
            const SizedBox(height: 24),
            const Text(
              'No orders yet',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your order history will appear here\nonce you make a purchase',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              ),
              child: const Text('Start Shopping'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.orderDetail,
        arguments: order,
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Order #${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                _buildStatusBadge(order.status),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              Helpers.formatDateTime(order.createdAt),
              style: const TextStyle(
                fontSize: 13,
                color: AppTheme.textSecondary,
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalItems} item${order.totalItems > 1 ? 's' : ''}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
                Text(
                  Helpers.formatCurrency(order.total),
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 16, color: AppTheme.textLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    '${order.shippingAddress.city}, ${order.shippingAddress.state}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(Icons.chevron_right,
                    color: AppTheme.textLight, size: 20),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bgColor;
    Color textColor;

    switch (status) {
      case OrderStatus.pending:
        bgColor = Colors.orange.shade50;
        textColor = Colors.orange.shade700;
        break;
      case OrderStatus.processing:
        bgColor = Colors.blue.shade50;
        textColor = Colors.blue.shade700;
        break;
      case OrderStatus.shipped:
        bgColor = Colors.purple.shade50;
        textColor = Colors.purple.shade700;
        break;
      case OrderStatus.delivered:
        bgColor = Colors.green.shade50;
        textColor = Colors.green.shade700;
        break;
      case OrderStatus.cancelled:
        bgColor = Colors.red.shade50;
        textColor = Colors.red.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}
