import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/order_provider.dart';
import 'package:agri_connect/screens/consumer/consumer_dashboard.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/l10n/app_localizations.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _addressController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isPlacingOrder = false;

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final cartItems = orderProvider.cartItems;
    final cartTotal = orderProvider.cartTotal;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedStrings.get(context, 'yourCart')),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(LocalizedStrings.get(context, 'clearCart')),
                    content: Text(
                        LocalizedStrings.get(context, 'clearCartConfirmation')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(LocalizedStrings.get(context, 'cancel')),
                      ),
                      TextButton(
                        onPressed: () {
                          orderProvider.clearCart();
                          Navigator.pop(context);
                        },
                        child: Text(
                          LocalizedStrings.get(context, 'clear'),
                          style: TextStyle(color: AppColors.errorColor),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? _buildEmptyCart()
          : Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    separatorBuilder: (context, index) =>
                        Divider(color: Colors.grey.shade200),
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return _buildCartItem(item, orderProvider);
                    },
                  ),
                ),
                _buildOrderSummary(cartTotal),
              ],
            ),
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed:
                    _isPlacingOrder ? null : () => _showCheckoutSheet(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isPlacingOrder
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        LocalizedStrings.get(context, 'proceedToCheckout'),
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 64,
            color: AppColors.greyColor,
          ),
          const SizedBox(height: 16),
          Text(
            LocalizedStrings.get(context, 'cartEmpty'),
            style: TextStyle(
              fontSize: 18,
              color: AppColors.greyColor,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            LocalizedStrings.get(context, 'addProductsToCart'),
            style: TextStyle(
              fontSize: 14,
              color: AppColors.greyColor,
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => const ConsumerDashboard()),
              );
            },
            child: Text(LocalizedStrings.get(context, 'browseProducts')),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(CartItem item, OrderProvider orderProvider) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.lightGreen,
            borderRadius: BorderRadius.circular(8),
          ),
          child: item.product.imageUrl != null
              ? Image.network(
                  item.product.imageUrl!,
                  fit: BoxFit.cover,
                )
              : Icon(
                  Icons.image_not_supported_outlined,
                  color: AppColors.greyColor,
                ),
        ),
        const SizedBox(width: 16),

        // Product Details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.product.name,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${LocalizedStrings.get(context, 'farmingMethod')}: ${item.product.farmingMethodString}',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.greyColor,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    '₹${item.product.price}/${item.product.unit}',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),

                  // Quantity controls
                  GestureDetector(
                    onTap: () {
                      if (item.quantity > 0.1) {
                        orderProvider.updateCartItemQuantity(
                          item.product.id,
                          item.quantity - 0.1,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.remove, size: 16),
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      item.quantity.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (item.quantity < item.product.quantity) {
                        orderProvider.updateCartItemQuantity(
                          item.product.id,
                          item.quantity + 0.1,
                        );
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.add, size: 16),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal: ₹${item.subtotal.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete_outline,
                      color: AppColors.errorColor,
                      size: 20,
                    ),
                    onPressed: () {
                      orderProvider.removeFromCart(item.product.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrderSummary(double total) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizedStrings.get(context, 'subtotal'),
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '₹${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizedStrings.get(context, 'deliveryFee'),
                style: TextStyle(fontSize: 14),
              ),
              Text(
                '₹40.00',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                LocalizedStrings.get(context, 'totalAmount'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '₹${(total + 40).toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCheckoutSheet(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // For prototype, we're assuming the first cart item's farmer is the seller for the entire order
    final firstItem = orderProvider.cartItems.first;
    final farmerId = firstItem.product.farmerId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocalizedStrings.get(context, 'checkout'),
                    style: TextStyle(
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

              // Delivery Address
              Text(
                LocalizedStrings.get(context, 'deliveryAddress'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _addressController,
                decoration: InputDecoration(
                  hintText:
                      LocalizedStrings.get(context, 'enterDeliveryAddress'),
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Notes
              Text(
                LocalizedStrings.get(context, 'orderNotes'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: LocalizedStrings.get(
                      context, 'specialDeliveryInstructions'),
                  prefixIcon: Icon(Icons.note_outlined),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),

              // Payment Options
              Text(
                LocalizedStrings.get(context, 'paymentMethod'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.money,
                      color: AppColors.primaryColor,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        LocalizedStrings.get(context, 'cashOnDelivery'),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.check_circle,
                      color: AppColors.primaryColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Place Order Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await _placeOrder();
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text(
                    LocalizedStrings.get(context, 'placeOrder'),
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Future<void> _placeOrder() async {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(LocalizedStrings.get(context, 'mustBeLoggedIn')),
        ),
      );
      return;
    }

    if (_addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              LocalizedStrings.get(context, 'pleaseProvideDeliveryAddress')),
        ),
      );
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    try {
      final success = await orderProvider.placeOrder(
        userId: user.id,
        deliveryAddress: _addressController.text.trim(),
        notes: _notesController.text.trim(),
        paymentMethod: 'Cash on Delivery',
      );

      if (success) {
        _showOrderSuccessDialog();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizedStrings.get(context, 'orderPlaceFailed')),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              '${LocalizedStrings.get(context, 'error')}: ${e.toString()}'),
        ),
      );
    } finally {
      setState(() {
        _isPlacingOrder = false;
      });
    }
  }

  void _showOrderSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.check_circle,
              color: AppColors.successColor,
            ),
            const SizedBox(width: 16),
            Text(LocalizedStrings.get(context, 'orderPlaced')),
          ],
        ),
        content: Text(
          LocalizedStrings.get(context, 'orderPlacedSuccessfully'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const ConsumerDashboard(),
                ),
              );
            },
            child: Text(LocalizedStrings.get(context, 'ok')),
          ),
        ],
      ),
    );
  }
}
