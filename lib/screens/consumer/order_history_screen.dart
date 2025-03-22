import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/order_provider.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/l10n/app_localizations.dart';
import 'package:agri_connect/models/order.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({Key? key}) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      await orderProvider.fetchOrders(authProvider.currentUser!.id);
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final orders = orderProvider.allOrders;

    final activeOrders = orders
        .where((order) =>
            order.status == OrderStatus.pending ||
            order.status == OrderStatus.accepted ||
            order.status == OrderStatus.shipped)
        .toList();

    final completedOrders =
        orders.where((order) => order.status == OrderStatus.delivered).toList();

    final cancelledOrders = orders
        .where((order) =>
            order.status == OrderStatus.rejected ||
            order.status == OrderStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedStrings.get(context, 'orderHistory')),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: LocalizedStrings.get(context, 'active')),
            Tab(text: LocalizedStrings.get(context, 'completed')),
            Tab(text: LocalizedStrings.get(context, 'cancelled')),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(activeOrders, 'noActiveOrders'),
                _buildOrderList(completedOrders, 'noCompletedOrders'),
                _buildOrderList(cancelledOrders, 'noCancelledOrders'),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<Order> orders, String emptyMessage) {
    if (orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              LocalizedStrings.get(context, emptyMessage),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(Order order) {
    final dateFormat = DateFormat('MMM d, y');
    final formattedDate = dateFormat.format(order.orderDate);

    Color statusColor;
    switch (order.status) {
      case OrderStatus.pending:
        statusColor = Colors.orange;
        break;
      case OrderStatus.accepted:
        statusColor = Colors.blue;
        break;
      case OrderStatus.shipped:
        statusColor = Colors.purple;
        break;
      case OrderStatus.delivered:
        statusColor = Colors.green;
        break;
      case OrderStatus.rejected:
      case OrderStatus.cancelled:
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: ExpansionTile(
        title: Text(
          '${LocalizedStrings.get(context, 'order')} #${order.id.substring(0, 8)}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    order.statusString,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${order.totalAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailRow(
                  icon: Icons.calendar_today_outlined,
                  title: LocalizedStrings.get(context, 'orderDate'),
                  value: formattedDate,
                ),
                const SizedBox(height: 8),
                _buildDetailRow(
                  icon: Icons.location_on_outlined,
                  title: LocalizedStrings.get(context, 'deliveryAddress'),
                  value: order.deliveryAddress,
                ),
                const SizedBox(height: 16),
                Text(
                  LocalizedStrings.get(context, 'orderItems'),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...order.products.map((item) => _buildOrderItem(item)),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      LocalizedStrings.get(context, 'totalPrice'),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '₹${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
                if (order.status == OrderStatus.shipped)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _confirmDelivery(order.id),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(
                            LocalizedStrings.get(context, 'confirmDelivery')),
                      ),
                    ),
                  ),
                if (order.status == OrderStatus.pending)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => _cancelOrder(order.id),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child:
                            Text(LocalizedStrings.get(context, 'cancelOrder')),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              item.productId,
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
          ),
          Text(
            '${item.quantity} x ₹${item.price.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '₹${item.subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelivery(String orderId) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizedStrings.get(context, 'confirmDelivery')),
        content: Text(LocalizedStrings.get(context, 'confirmDeliveryMessage')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LocalizedStrings.get(context, 'cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(LocalizedStrings.get(context, 'confirm')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await orderProvider.updateOrderStatus(
        orderId,
        OrderStatus.delivered,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizedStrings.get(context, 'deliveryConfirmed')),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(LocalizedStrings.get(context, 'failedToUpdateStatus')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelOrder(String orderId) async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(LocalizedStrings.get(context, 'cancelOrder')),
        content: Text(LocalizedStrings.get(context, 'cancelOrderConfirmation')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(LocalizedStrings.get(context, 'no')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(LocalizedStrings.get(context, 'yes')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await orderProvider.updateOrderStatus(
        orderId,
        OrderStatus.cancelled,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizedStrings.get(context, 'orderCancelled')),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(LocalizedStrings.get(context, 'failedToUpdateStatus')),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
