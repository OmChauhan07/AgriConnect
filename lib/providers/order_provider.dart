import 'package:flutter/material.dart';
import 'package:agri_connect/models/order.dart';
import 'package:agri_connect/models/product.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/dummy_data.dart';

class CartItem {
  final Product product;
  double quantity;

  CartItem({
    required this.product,
    this.quantity = 1.0,
  });

  double get subtotal => product.price * quantity;
}

class OrderProvider with ChangeNotifier {
  List<CartItem> _cartItems = [];
  List<Order> get allOrders => List.from(dummyOrders);

  List<CartItem> get cartItems => _cartItems;
  
  double get cartTotal {
    return _cartItems.fold(0, (total, item) => total + item.subtotal);
  }

  void addToCart(Product product, {double quantity = 1.0}) {
    final existingIndex = _cartItems.indexWhere((item) => item.product.id == product.id);
    
    if (existingIndex >= 0) {
      _cartItems[existingIndex].quantity += quantity;
    } else {
      _cartItems.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cartItems.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateCartItemQuantity(String productId, double quantity) {
    final index = _cartItems.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _cartItems[index].quantity = quantity;
      notifyListeners();
    }
  }

  void clearCart() {
    _cartItems = [];
    notifyListeners();
  }

  // Get orders by consumer ID
  List<Order> getOrdersByConsumer(String consumerId) {
    return dummyOrders.where((order) => order.consumerId == consumerId).toList();
  }

  // Get orders by farmer ID
  List<Order> getOrdersByFarmer(String farmerId) {
    return dummyOrders.where((order) => order.farmerId == farmerId).toList();
  }

  // Get order by ID
  Order? getOrderById(String orderId) {
    try {
      return dummyOrders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Place a new order
  Future<bool> placeOrder({
    required String consumerId,
    required String farmerId,
    required String deliveryAddress,
    String? notes,
  }) async {
    if (_cartItems.isEmpty) return false;
    
    try {
      final orderItems = _cartItems.map((item) {
        return OrderItem(
          productId: item.product.id,
          quantity: item.quantity,
          price: item.product.price,
        );
      }).toList();
      
      final totalAmount = cartTotal;
      
      final newOrder = Order(
        id: 'o${dummyOrders.length + 1}',
        consumerId: consumerId,
        farmerId: farmerId,
        products: orderItems,
        totalAmount: totalAmount,
        status: OrderStatus.pending,
        orderDate: DateTime.now(),
        deliveryAddress: deliveryAddress,
        notes: notes,
      );
      
      dummyOrders.add(newOrder);
      clearCart(); // Clear the cart after order is placed
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final index = dummyOrders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        dummyOrders[index] = dummyOrders[index].copyWith(
          status: status,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  // Get count of orders by status for a farmer
  Map<OrderStatus, int> getOrderCountsByStatusForFarmer(String farmerId) {
    final farmerOrders = getOrdersByFarmer(farmerId);
    
    final counts = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      counts[status] = farmerOrders.where((order) => order.status == status).length;
    }
    
    return counts;
  }

  // Get total sales for a farmer
  double getTotalSalesForFarmer(String farmerId) {
    final farmerOrders = getOrdersByFarmer(farmerId);
    return farmerOrders.fold(0, (total, order) => total + order.totalAmount);
  }
}
