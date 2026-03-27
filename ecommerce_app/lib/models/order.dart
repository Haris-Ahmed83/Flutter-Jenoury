import 'cart_item.dart';

enum OrderStatus {
  pending,
  processing,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Order {
  final String id;
  final List<CartItem> items;
  final double subtotal;
  final double shipping;
  final double tax;
  final double total;
  final OrderStatus status;
  final DateTime createdAt;
  final String paymentIntentId;
  final ShippingAddress shippingAddress;

  const Order({
    required this.id,
    required this.items,
    required this.subtotal,
    required this.shipping,
    required this.tax,
    required this.total,
    required this.status,
    required this.createdAt,
    required this.paymentIntentId,
    required this.shippingAddress,
  });

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items: (json['items'] as List)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      shipping: (json['shipping'] as num).toDouble(),
      tax: (json['tax'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      status: OrderStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => OrderStatus.pending,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      paymentIntentId: json['payment_intent_id'] as String,
      shippingAddress: ShippingAddress.fromJson(
          json['shipping_address'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'shipping': shipping,
      'tax': tax,
      'total': total,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'payment_intent_id': paymentIntentId,
      'shipping_address': shippingAddress.toJson(),
    };
  }

  Order copyWith({OrderStatus? status}) {
    return Order(
      id: id,
      items: items,
      subtotal: subtotal,
      shipping: shipping,
      tax: tax,
      total: total,
      status: status ?? this.status,
      createdAt: createdAt,
      paymentIntentId: paymentIntentId,
      shippingAddress: shippingAddress,
    );
  }
}

class ShippingAddress {
  final String fullName;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String zipCode;
  final String country;
  final String phone;

  const ShippingAddress({
    required this.fullName,
    required this.addressLine1,
    this.addressLine2 = '',
    required this.city,
    required this.state,
    required this.zipCode,
    this.country = 'US',
    required this.phone,
  });

  String get formattedAddress =>
      '$addressLine1${addressLine2.isNotEmpty ? ', $addressLine2' : ''}\n$city, $state $zipCode\n$country';

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      fullName: json['full_name'] as String,
      addressLine1: json['address_line_1'] as String,
      addressLine2: json['address_line_2'] as String? ?? '',
      city: json['city'] as String,
      state: json['state'] as String,
      zipCode: json['zip_code'] as String,
      country: json['country'] as String? ?? 'US',
      phone: json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'address_line_1': addressLine1,
      'address_line_2': addressLine2,
      'city': city,
      'state': state,
      'zip_code': zipCode,
      'country': country,
      'phone': phone,
    };
  }
}
