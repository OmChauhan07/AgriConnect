import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/product_provider.dart';
import 'package:agri_connect/providers/order_provider.dart';
import 'package:agri_connect/screens/consumer/product_detail_screen.dart';
import 'package:agri_connect/screens/consumer/cart_screen.dart';
import 'package:agri_connect/screens/consumer/qr_scanner_screen.dart';
import 'package:agri_connect/screens/consumer/consumer_profile_screen.dart';
import 'package:agri_connect/screens/onboarding/login_screen.dart';
import 'package:agri_connect/screens/onboarding/landing_screen.dart';
import 'package:agri_connect/widgets/product_card.dart';
import 'package:agri_connect/widgets/user_avatar.dart';
import 'package:agri_connect/widgets/bottom_navigation.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/dummy_data.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/widgets/language_switcher.dart';
import 'package:agri_connect/l10n/app_localizations.dart';

class ConsumerDashboard extends StatefulWidget {
  const ConsumerDashboard({Key? key}) : super(key: key);

  @override
  State<ConsumerDashboard> createState() => _ConsumerDashboardState();
}

class _ConsumerDashboardState extends State<ConsumerDashboard> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final localizations = AppLocalizations.of(context);

    final user = authProvider.currentUser!;
    final topProducts = productProvider.getTopRatedProducts();
    final filteredProducts = _searchQuery.isEmpty
        ? productProvider.allProducts
        : productProvider.searchProducts(_searchQuery);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedStrings.get(context, 'marketplace')),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingScreen()),
            );
          },
        ),
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
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartScreen()),
                  );
                },
              ),
              if (orderProvider.cartItems.isNotEmpty)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      orderProvider.cartItems.length.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: LocalizedStrings.searchHint(context),
                    border: InputBorder.none,
                    icon: Icon(
                      Icons.search,
                      color: AppColors.greyColor,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
              const SizedBox(height: 24),

              // Featured Farmers
              if (_searchQuery.isEmpty) ...[
                Text(
                  LocalizedStrings.get(context, 'featuredFarmers'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: dummyFarmers.length,
                    itemBuilder: (context, index) {
                      final farmer = dummyFarmers[index];
                      return Container(
                        width: 100,
                        margin: const EdgeInsets.only(right: 16),
                        child: Column(
                          children: [
                            UserAvatar(
                              imageUrl: farmer.profileImageUrl,
                              radius: 35,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              farmer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  farmer.rating.toString(),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Top Rated Products
                Text(
                  LocalizedStrings.topRated(context),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
                const SizedBox(height: 16),

                SizedBox(
                  height: 230,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: topProducts.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 160,
                        margin: const EdgeInsets.only(right: 16),
                        child: ProductCard(
                          product: topProducts[index],
                          isHorizontal: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductDetailScreen(
                                  product: topProducts[index],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  LocalizedStrings.get(context, 'allProducts'),
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ] else
                Text(
                  '${LocalizedStrings.get(context, 'searchResults')}: $_searchQuery',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),

              const SizedBox(height: 16),

              // Product Grid
              if (_searchQuery.isNotEmpty && filteredProducts.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: AppColors.greyColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          LocalizedStrings.get(context, 'noResultsFound'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textColor,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          LocalizedStrings.get(context, 'tryDifferentSearch'),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.greyColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    return ProductCard(
                      product: filteredProducts[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailScreen(
                              product: filteredProducts[index],
                            ),
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
        child: const Icon(Icons.qr_code_scanner),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QRScannerScreen()),
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
              MaterialPageRoute(builder: (context) => const CartScreen()),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const ConsumerProfileScreen()),
            );
          }
        },
        isFarmer: false,
      ),
    );
  }
}
