import 'package:agri_connect/utils/constants.dart';

class OrderItem {
  final String productId;
  final double quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  double get subtotal => quantity * price;

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'quantity': quantity,
      'price': price,
    };
  }

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['productId'],
      quantity: json['quantity'],
      price: json['price'],
    );
  }
}

class Order {
  final String id;
  final String consumerId;
  final String farmerId;
  final List<OrderItem> products;
  final double totalAmount;
  final OrderStatus status;
  final DateTime orderDate;
  final String deliveryAddress;
  final String? notes;

  Order({
    required this.id,
    required this.consumerId,
    required this.farmerId,
    required this.products,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.deliveryAddress,
    this.notes,
  });

  Order copyWith({
    List<OrderItem>? products,
    double? totalAmount,
    OrderStatus? status,
    String? deliveryAddress,
    String? notes,
  }) {
    return Order(
      id: this.id,
      consumerId: this.consumerId,
      farmerId: this.farmerId,
      products: products ?? this.products,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: this.orderDate,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'consumerId': consumerId,
      'farmerId': farmerId,
      'products': products.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.toString(),
      'orderDate': orderDate.toIso8601String(),
      'deliveryAddress': deliveryAddress,
      'notes': notes,
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    OrderStatus orderStatus;
    switch (json['status']) {
      case 'OrderStatus.pending': orderStatus = OrderStatus.pending; break;
      case 'OrderStatus.accepted': orderStatus = OrderStatus.accepted; break;
      case 'OrderStatus.rejected': orderStatus = OrderStatus.rejected; break;
      case 'OrderStatus.shipped': orderStatus = OrderStatus.shipped; break;
      case 'OrderStatus.delivered': orderStatus = OrderStatus.delivered; break;
      case 'OrderStatus.cancelled': orderStatus = OrderStatus.cancelled; break;
      default: orderStatus = OrderStatus.pending;
    }

    return Order(
      id: json['id'],
      consumerId: json['consumerId'],
      farmerId: json['farmerId'],
      products: (json['products'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: json['totalAmount'],
      status: orderStatus,
      orderDate: DateTime.parse(json['orderDate']),
      deliveryAddress: json['deliveryAddress'],
      notes: json['notes'],
    );
  }

  String get statusString {
    switch (status) {
      case OrderStatus.pending: return 'Pending';
      case OrderStatus.accepted: return 'Accepted';
      case OrderStatus.rejected: return 'Rejected';
      case OrderStatus.shipped: return 'Shipped';
      case OrderStatus.delivered: return 'Delivered';
      case OrderStatus.cancelled: return 'Cancelled';
      default: return 'Unknown';
    }
  }
}
