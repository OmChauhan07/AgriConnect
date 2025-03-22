import 'package:flutter/material.dart';
import 'package:agri_connect/models/order.dart';
import 'package:agri_connect/models/product.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/dummy_data.dart';
import 'package:agri_connect/services/supabase_service.dart';

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
  List<Order> _orders = [];
  bool _isLoading = false;

  List<CartItem> get cartItems => _cartItems;
  List<Order> get allOrders => _orders;
  bool get isLoading => _isLoading;

  double get cartTotal {
    return _cartItems.fold(0, (total, item) => total + item.subtotal);
  }

  void addToCart(Product product, {double quantity = 1.0}) {
    final existingIndex =
        _cartItems.indexWhere((item) => item.product.id == product.id);

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

  // Fetch orders from database
  Future<void> fetchOrders(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final supabaseService = SupabaseService();
      _orders = await supabaseService.getOrdersByUser(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Fetch orders error: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Place a new order
  Future<bool> placeOrder({
    required String userId,
    required String deliveryAddress,
    String? notes,
    String paymentMethod = 'Cash on Delivery',
  }) async {
    if (_cartItems.isEmpty) return false;

    try {
      _isLoading = true;
      notifyListeners();

      final orderItems = _cartItems.map((item) {
        return {
          'product_id': item.product.id,
          'quantity': item.quantity,
          'price': item.product.price,
        };
      }).toList();

      final totalAmount = cartTotal;

      // Use the Supabase service to create the order
      final supabaseService = SupabaseService();
      final orderId = await supabaseService.createOrder(
        userId: userId,
        items: orderItems,
        deliveryAddress: deliveryAddress,
        totalAmount: totalAmount,
        paymentMethod: paymentMethod,
      );

      clearCart(); // Clear the cart after order is placed

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Place order error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Update order status
  Future<bool> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      _isLoading = true;
      notifyListeners();

      final supabaseService = SupabaseService();
      await supabaseService.updateOrderStatus(orderId, status.toString());

      // Update local state
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        _orders[index] = _orders[index].copyWith(status: status);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update order status error: $e');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Get orders by consumer ID
  List<Order> getOrdersByConsumer(String consumerId) {
    return _orders.where((order) => order.consumerId == consumerId).toList();
  }

  // Get orders by farmer ID
  List<Order> getOrdersByFarmer(String farmerId) {
    return _orders.where((order) => order.farmerId == farmerId).toList();
  }

  // Get order by ID
  Order? getOrderById(String orderId) {
    try {
      return _orders.firstWhere((order) => order.id == orderId);
    } catch (e) {
      return null;
    }
  }

  // Get count of orders by status for a farmer
  Map<OrderStatus, int> getOrderCountsByStatusForFarmer(String farmerId) {
    final farmerOrders = getOrdersByFarmer(farmerId);

    final counts = <OrderStatus, int>{};
    for (final status in OrderStatus.values) {
      counts[status] =
          farmerOrders.where((order) => order.status == status).length;
    }

    return counts;
  }

  // Get total sales for a farmer
  double getTotalSalesForFarmer(String farmerId) {
    final farmerOrders = getOrdersByFarmer(farmerId);
    return farmerOrders.fold(0, (total, order) => total + order.totalAmount);
  }
}
