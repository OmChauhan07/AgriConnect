import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/product_provider.dart';
import 'package:agri_connect/providers/order_provider.dart';
import 'package:agri_connect/screens/consumer/product_detail_screen.dart';
import 'package:agri_connect/screens/consumer/cart_screen.dart';
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
  bool _isLoading = true;
  FarmingMethod? _selectedFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
    });

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);

    try {
      await productProvider.loadProducts();
      debugPrint('Products loaded: ${productProvider.allProducts.length}');

      // Debug first product if available
      if (productProvider.allProducts.isNotEmpty) {
        final firstProduct = productProvider.allProducts.first;
        debugPrint(
            'First product: ${firstProduct.name}, ${firstProduct.price}, ${firstProduct.imageUrl}');
      }
    } catch (e) {
      debugPrint('Error loading products: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

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
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _loadProducts();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(LocalizedStrings.get(context, 'refreshing')),
                  duration: const Duration(seconds: 1),
                ),
              );
            },
          ),
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
      body: RefreshIndicator(
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
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
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: LocalizedStrings.searchHint(context),
                      border: InputBorder.none,
                      icon: Icon(
                        Icons.search,
                        color: AppColors.primaryColor,
                      ),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, color: Colors.grey),
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
                const SizedBox(height: 16),

                // Filter row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'All',
                        isSelected: _selectedFilter == null,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Organic',
                        isSelected: _selectedFilter == FarmingMethod.organic,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter =
                                selected ? FarmingMethod.organic : null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Natural',
                        isSelected: _selectedFilter == FarmingMethod.natural,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter =
                                selected ? FarmingMethod.natural : null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Conventional',
                        isSelected:
                            _selectedFilter == FarmingMethod.conventional,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter =
                                selected ? FarmingMethod.conventional : null;
                          });
                        },
                      ),
                    ],
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

                  _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: dummyFarmers.length,
                            itemBuilder: (context, index) {
                              final farmer = dummyFarmers[index];
                              return GestureDetector(
                                onTap: () {
                                  // Show farmer products - Filter products by this farmer
                                  setState(() {
                                    _searchQuery = farmer.name;
                                    _searchController.text = farmer.name;
                                  });
                                },
                                child: Container(
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
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
                    child: topProducts.isEmpty
                        ? Center(
                            child: Text(
                              LocalizedStrings.get(context, 'noProductsFound'),
                              style: TextStyle(
                                fontSize: 16,
                                color: AppColors.greyColor,
                              ),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: topProducts.length,
                            itemBuilder: (context, index) {
                              final product = topProducts[index];
                              return Container(
                                width: 160,
                                margin: const EdgeInsets.only(right: 16),
                                child: ProductCard(
                                  product: product,
                                  isHorizontal: true,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProductDetailScreen(
                                          product: product,
                                        ),
                                      ),
                                    ).then((_) {
                                      // Refresh products when returning from product detail
                                      setState(() {});
                                    });
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                  const SizedBox(height: 24),

                  // Organic Products Section
                  Text(
                    LocalizedStrings.get(context, 'organicProducts'),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 16),

                  SizedBox(
                    height: 230,
                    child: _buildOrganicProductsList(productProvider),
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
                else if (_isLoading)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            LocalizedStrings.get(context, 'loadingProducts'),
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.greyColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.75,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 16,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        product: product,
                        isHorizontal: false,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailScreen(
                                product: product,
                              ),
                            ),
                          ).then((_) {
                            // Refresh products when returning from product detail
                            setState(() {});
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: null,
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

  Widget _buildOrganicProductsList(ProductProvider productProvider) {
    final organicProducts = productProvider.allProducts
        .where((product) => product.farmingMethod == FarmingMethod.organic)
        .toList();

    if (organicProducts.isEmpty) {
      return Center(
        child: Text(
          LocalizedStrings.get(context, 'noOrganicProducts'),
          style: TextStyle(
            fontSize: 16,
            color: AppColors.greyColor,
          ),
        ),
      );
    }

    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: organicProducts.length,
      itemBuilder: (context, index) {
        final product = organicProducts[index];
        return Container(
          width: 160,
          margin: const EdgeInsets.only(right: 16),
          child: Stack(
            children: [
              ProductCard(
                product: product,
                isHorizontal: true,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailScreen(
                        product: product,
                      ),
                    ),
                  ).then((_) {
                    // Refresh products when returning from product detail
                    setState(() {});
                  });
                },
              ),
              // Add an organic badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'ORGANIC',
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
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required Function(bool) onSelected,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: onSelected,
        selectedColor: AppColors.primaryColor.withOpacity(0.2),
        checkmarkColor: AppColors.primaryColor,
        labelStyle: TextStyle(
          color: isSelected ? AppColors.primaryColor : AppColors.textColor,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
