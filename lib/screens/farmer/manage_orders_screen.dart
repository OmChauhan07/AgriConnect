import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/models/order.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/order_provider.dart';
import 'package:agri_connect/providers/product_provider.dart';
import 'package:agri_connect/widgets/order_card.dart';
import 'package:agri_connect/utils/constants.dart';

class ManageOrdersScreen extends StatefulWidget {
  const ManageOrdersScreen({Key? key}) : super(key: key);

  @override
  State<ManageOrdersScreen> createState() => _ManageOrdersScreenState();
}

class _ManageOrdersScreenState extends State<ManageOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    
    final farmerId = authProvider.currentUser!.id;
    final allOrders = orderProvider.getOrdersByFarmer(farmerId);
    
    // Filter orders by status
    final pendingOrders = allOrders.where((order) => 
      order.status == OrderStatus.pending).toList();
    
    final activeOrders = allOrders.where((order) => 
      order.status == OrderStatus.accepted || 
      order.status == OrderStatus.shipped).toList();
    
    final completedOrders = allOrders.where((order) => 
      order.status == OrderStatus.delivered || 
      order.status == OrderStatus.cancelled).toList();
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Orders'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Active'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Pending Orders Tab
          _buildOrdersList(pendingOrders, productProvider, orderProvider, 'pending'),
          
          // Active Orders Tab
          _buildOrdersList(activeOrders, productProvider, orderProvider, 'active'),
          
          // Completed Orders Tab
          _buildOrdersList(completedOrders, productProvider, orderProvider, 'completed'),
        ],
      ),
    );
  }
  
  Widget _buildOrdersList(
    List<Order> orders, 
    ProductProvider productProvider,
    OrderProvider orderProvider,
    String tabType,
  ) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 64,
              color: AppColors.greyColor,
            ),
            const SizedBox(height: 16),
            Text(
              'No $tabType orders',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        
        return OrderCard(
          order: order,
          productProvider: productProvider,
          onTap: () => _showOrderDetails(context, order, productProvider, orderProvider),
        );
      },
    );
  }
  
  void _showOrderDetails(
    BuildContext context, 
    Order order, 
    ProductProvider productProvider,
    OrderProvider orderProvider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          height: MediaQuery.of(context).size.height * 0.6,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order #${order.id.substring(1)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Order status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getStatusColor(order.status).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.statusString,
                  style: TextStyle(
                    color: _getStatusColor(order.status),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Order date and delivery address
              Text(
                'Order Date: ${_formatDate(order.orderDate)}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 8),
              Text(
                'Delivery Address: ${order.deliveryAddress}',
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 24),
              
              // Order items
              const Text(
                'Order Items',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: order.products.length,
                  itemBuilder: (context, index) {
                    final item = order.products[index];
                    final product = productProvider.getProductById(item.productId);
                    
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Image.network(
                            product?.imageUrl ?? 'https://cdn-icons-png.flaticon.com/512/1799/1799977.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                      ),
                      title: Text(product?.name ?? 'Unknown Product'),
                      subtitle: Text('₹${item.price} x ${item.quantity}'),
                      trailing: Text(
                        '₹${item.subtotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Total amount
              Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade200),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Amount:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Action buttons
              if (order.status == OrderStatus.pending)
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateOrderStatus(context, order.id, OrderStatus.rejected, orderProvider),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.errorColor,
                          side: BorderSide(color: AppColors.errorColor),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateOrderStatus(context, order.id, OrderStatus.accepted, orderProvider),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                )
              else if (order.status == OrderStatus.accepted)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(context, order.id, OrderStatus.shipped, orderProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Mark as Shipped'),
                  ),
                )
              else if (order.status == OrderStatus.shipped)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _updateOrderStatus(context, order.id, OrderStatus.delivered, orderProvider),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Mark as Delivered'),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
  
  Future<void> _updateOrderStatus(
    BuildContext context, 
    String orderId, 
    OrderStatus newStatus,
    OrderProvider orderProvider,
  ) async {
    Navigator.pop(context); // Close the bottom sheet
    
    final success = await orderProvider.updateOrderStatus(orderId, newStatus);
    
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success 
              ? 'Order status updated to ${newStatus.toString().split('.').last}'
              : 'Failed to update order status',
        ),
        backgroundColor: success ? AppColors.successColor : AppColors.errorColor,
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
  
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending: return Colors.orange;
      case OrderStatus.accepted: return Colors.blue;
      case OrderStatus.rejected: return AppColors.errorColor;
      case OrderStatus.shipped: return Colors.deepPurple;
      case OrderStatus.delivered: return AppColors.successColor;
      case OrderStatus.cancelled: return Colors.grey;
      default: return Colors.black;
    }
  }
}
