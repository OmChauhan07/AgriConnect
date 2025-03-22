import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/product_provider.dart';
import 'package:agri_connect/providers/order_provider.dart';
import 'package:agri_connect/screens/farmer/add_product_screen.dart';
import 'package:agri_connect/screens/farmer/manage_orders_screen.dart';
import 'package:agri_connect/screens/farmer/farmer_profile_screen.dart';
import 'package:agri_connect/widgets/product_card.dart';
import 'package:agri_connect/widgets/bottom_navigation.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/widgets/language_switcher.dart';
import 'package:agri_connect/l10n/app_localizations.dart';

class FarmerDashboard extends StatefulWidget {
  const FarmerDashboard({Key? key}) : super(key: key);

  @override
  State<FarmerDashboard> createState() => _FarmerDashboardState();
}

class _FarmerDashboardState extends State<FarmerDashboard> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final localizations = AppLocalizations.of(context);

    final user = authProvider.currentUser!;
    final farmerId = user.id;

    final products = productProvider.getProductsByFarmer(farmerId);
    final orderCounts = orderProvider.getOrderCountsByStatusForFarmer(farmerId);
    final totalSales = orderProvider.getTotalSalesForFarmer(farmerId);

    // Calculate order stats
    final pendingOrders = orderCounts[OrderStatus.pending] ?? 0;
    final deliveredOrders = orderCounts[OrderStatus.delivered] ?? 0;
    final totalOrders = orderProvider.getOrdersByFarmer(farmerId).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedStrings.get(context, 'farmerDashboard')),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        LocalizedStrings.get(context, 'featureNotAvailable'))),
              );
            },
          ),
          const LanguageSwitcher(isDashboard: true),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(
                        LocalizedStrings.get(context, 'featureNotAvailable'))),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Farmer Profile Section
              Container(
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Profile Image
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border:
                            Border.all(color: AppColors.primaryColor, width: 2),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(35),
                        child: user.profileImageUrl != null
                            ? Image.network(
                                user.profileImageUrl!,
                                fit: BoxFit.cover,
                              )
                            : const Icon(Icons.person,
                                size: 40, color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Farmer Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.greyColor,
                            ),
                          ),
                          // Add phone number if available
                          if (user.phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              user.phone,
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.greyColor,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Edit Profile Button
                    IconButton(
                      icon: Icon(
                        Icons.edit,
                        color: AppColors.primaryColor,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FarmerProfileScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Order Statistics Section
              Text(
                LocalizedStrings.get(context, 'orderStatistics'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  _buildStatCard(
                    title: LocalizedStrings.get(context, 'totalOrders'),
                    value: '$totalOrders',
                    icon: Icons.shopping_bag_outlined,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    title: LocalizedStrings.get(context, 'pending'),
                    value: '$pendingOrders',
                    icon: Icons.pending_outlined,
                    color: Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    title: LocalizedStrings.get(context, 'delivered'),
                    value: '$deliveredOrders',
                    icon: Icons.check_circle_outline,
                    color: AppColors.successColor,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Sales Chart
              if (totalOrders > 0)
                Container(
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocalizedStrings.get(context, 'salesOverview'),
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textColor,
                            ),
                          ),
                          Text(
                            '₹${totalSales.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Placeholder for Sales Chart
                      Expanded(
                        child: Center(
                          child: Text(
                            LocalizedStrings.get(
                                context, 'salesChartPlaceholder'),
                            style: TextStyle(
                              color: AppColors.greyColor,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Your Products Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocalizedStrings.get(context, 'yourProducts'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedIndex = 3;
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddProductScreen()),
                      );
                    },
                    child: Text(
                      LocalizedStrings.get(context, 'addNew'),
                      style: TextStyle(
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Products List
              if (products.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_shopping_cart,
                        size: 48,
                        color: AppColors.greyColor,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        LocalizedStrings.get(context, 'noProductsYet'),
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textColor,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        LocalizedStrings.get(context, 'tapAddProductToStart'),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.greyColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: products[index],
                      isFarmerView: true,
                      onTap: () {
                        // For prototype, just show a dialog with product details
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text(products[index].name),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                    '${LocalizedStrings.get(context, 'price')}: ₹${products[index].price}/${products[index].unit}'),
                                Text(
                                    '${LocalizedStrings.get(context, 'quantity')}: ${products[index].quantity} ${products[index].unit}'),
                                Text(
                                    '${LocalizedStrings.get(context, 'farmingMethod')}: ${products[index].farmingMethodString}'),
                                const SizedBox(height: 8),
                                Text(products[index].description),
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: Text(
                                    LocalizedStrings.get(context, 'close')),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddProductScreen()),
          );
        },
      ),
      bottomNavigationBar: CustomBottomNavigation(
        selectedIndex: _selectedIndex,
        onItemSelected: (index) {
          setState(() {
            _selectedIndex = index;
          });

          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ManageOrdersScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const FarmerProfileScreen()),
            );
          }
        },
        isFarmer: true,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: AppColors.greyColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderStatusIndicator(String title, int count, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              count.toString(),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: TextStyle(
            color: AppColors.textColor,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
