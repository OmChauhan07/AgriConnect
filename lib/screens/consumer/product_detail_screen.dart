import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:agri_connect/models/product.dart';
import 'package:agri_connect/providers/order_provider.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/screens/consumer/cart_screen.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/dummy_data.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/l10n/app_localizations.dart';
import 'package:agri_connect/services/translation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;

  const ProductDetailScreen({
    Key? key,
    required this.product,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  double _quantity = 1.0;
  final double _minQuantity = 0.1;
  final double _maxQuantity = 10.0;
  final double _step = 0.1;

  // For translated content
  String _translatedProductName = '';
  String _translatedDescription = '';
  String _translatedFarmingMethod = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _translateProductDetails();
  }

  // Translate product details
  Future<void> _translateProductDetails() async {
    setState(() {
      _isLoading = true;
    });

    final translator = TranslationService();

    if (await translator.needsTranslation()) {
      final translations = await translator.translateTexts([
        widget.product.name,
        widget.product.description,
        widget.product.farmingMethodString,
      ]);

      setState(() {
        _translatedProductName =
            translations[widget.product.name] ?? widget.product.name;
        _translatedDescription = translations[widget.product.description] ??
            widget.product.description;
        _translatedFarmingMethod =
            translations[widget.product.farmingMethodString] ??
                widget.product.farmingMethodString;
        _isLoading = false;
      });
    } else {
      setState(() {
        _translatedProductName = widget.product.name;
        _translatedDescription = widget.product.description;
        _translatedFarmingMethod = widget.product.farmingMethodString;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);
    final localizations = AppLocalizations.of(context);

    // Find the farmer of this product
    final farmer = dummyFarmers.firstWhere(
      (farmer) => farmer.id == widget.product.farmerId,
      orElse: () => dummyFarmers.first,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedStrings.get(context, 'productDetails')),
        actions: [
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
                    decoration: const BoxDecoration(
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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  Container(
                    height: 220,
                    width: double.infinity,
                    color: AppColors.lightGreen,
                    child: widget.product.imageUrl != null
                        ? Image.network(
                            widget.product.imageUrl!,
                            fit: BoxFit.contain,
                          )
                        : Icon(
                            Icons.image_not_supported_outlined,
                            size: 80,
                            color: AppColors.greyColor,
                          ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name and Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                _translatedProductName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹${widget.product.price}',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryColor,
                                  ),
                                ),
                                Text(
                                  localizations.translate('perUnit').replaceAll(
                                      '{unit}', widget.product.unit),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),

                        // Rating
                        Row(
                          children: [
                            RatingBar.builder(
                              initialRating: widget.product.rating,
                              minRating: 1,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: 18,
                              ignoreGestures: true,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {},
                            ),
                            const SizedBox(width: 8),
                            Text(
                              widget.product.rating.toString(),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.textColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Farming Method Chip
                        Wrap(
                          spacing: 8,
                          children: [
                            Chip(
                              label: Text(_translatedFarmingMethod),
                              backgroundColor: _getFarmingMethodColor(
                                  widget.product.farmingMethod),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 16),

                        // Farmer Info
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: AppColors.lightGreen,
                                shape: BoxShape.circle,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(25),
                                child: farmer.profileImageUrl != null
                                    ? Image.network(
                                        farmer.profileImageUrl!,
                                        fit: BoxFit.cover,
                                      )
                                    : Icon(
                                        Icons.person,
                                        color: AppColors.primaryColor,
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    farmer.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${farmer.rating} ${localizations.translate('rating')}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: AppColors.greyColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Show farmer details in a modal bottom sheet
                                showModalBottomSheet(
                                  context: context,
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(20)),
                                  ),
                                  builder: (context) =>
                                      _buildFarmerDetailsSheet(farmer),
                                );
                              },
                              child: Text(
                                LocalizedStrings.get(context, 'viewProfile'),
                                style: TextStyle(
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Divider
                        Divider(color: Colors.grey.shade300),
                        const SizedBox(height: 16),

                        // Description
                        Text(
                          LocalizedStrings.get(context, 'description'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _translatedDescription,
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textColor,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Quantity Selector
                        Text(
                          LocalizedStrings.get(context, 'quantity'),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_quantity > _minQuantity) {
                                    _quantity = (_quantity - _step);
                                    // Round to 1 decimal place
                                    _quantity = double.parse(
                                        _quantity.toStringAsFixed(1));
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.remove_circle_outline,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${_quantity.toStringAsFixed(1)} ${widget.product.unit}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  if (_quantity < _maxQuantity &&
                                      _quantity < widget.product.quantity) {
                                    _quantity = (_quantity + _step);
                                    // Round to 1 decimal place
                                    _quantity = double.parse(
                                        _quantity.toStringAsFixed(1));
                                  }
                                });
                              },
                              icon: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              localizations
                                  .translate('availableQuantity')
                                  .replaceAll('{quantity}',
                                      widget.product.quantity.toString())
                                  .replaceAll('{unit}', widget.product.unit),
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.greyColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Total Price
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                LocalizedStrings.get(context, 'totalPrice'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                '₹${(widget.product.price * _quantity).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Add to Cart Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_quantity <= 0 ||
                                  _quantity > widget.product.quantity) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(LocalizedStrings.get(
                                        context, 'invalidQuantity')),
                                  ),
                                );
                                return;
                              }

                              orderProvider.addToCart(widget.product,
                                  quantity: _quantity);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    localizations
                                        .translate('addedToCart')
                                        .replaceAll('{product}',
                                            _translatedProductName),
                                  ),
                                  action: SnackBarAction(
                                    label: LocalizedStrings.get(
                                        context, 'viewCart'),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const CartScreen()),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                            child: Text(
                              LocalizedStrings.get(context, 'addToCart'),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFarmerDetailsSheet(user) {
    return FutureBuilder<Map<String, String>>(
      future: _translateFarmerDetails(user),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final translations = snapshot.data ?? {};
        final translatedName = translations['name'] ?? user.name;
        final translatedDescription =
            translations['description'] ?? (user.description ?? '');

        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: user.profileImageUrl != null
                          ? Image.network(
                              user.profileImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.person,
                              color: AppColors.primaryColor,
                              size: 30,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          translatedName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${user.rating} ${LocalizedStrings.get(context, 'rating')}',
                              style: TextStyle(
                                fontSize: 14,
                                color: AppColors.greyColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Farmer description
              if (user.description != null) ...[
                Text(
                  LocalizedStrings.get(context, 'aboutFarm'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  translatedDescription.isNotEmpty
                      ? translatedDescription
                      : LocalizedStrings.get(context, 'noDescriptionAvailable'),
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Contact information
              Text(
                LocalizedStrings.get(context, 'contactInformation'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.email_outlined,
                    size: 16,
                    color: AppColors.greyColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (user.phone.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: AppColors.greyColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.phone,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textColor,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 4),
              if (user.address != null && user.address!.isNotEmpty)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: AppColors.greyColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        user.address!,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textColor,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),

              // View all products button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // In a full implementation, this would navigate to a screen showing
                    // all products from this farmer
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(LocalizedStrings.get(
                            context, 'featureNotAvailable')),
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(LocalizedStrings.get(context, 'viewAllProducts')),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<Map<String, String>> _translateFarmerDetails(user) async {
    final translator = TranslationService();

    if (await translator.needsTranslation()) {
      final Map<String, String> translations = {};

      // Translate farmer name
      translations['name'] = await translator.translateText(user.name);

      // Translate description if available
      if (user.description != null && user.description.isNotEmpty) {
        translations['description'] =
            await translator.translateText(user.description);
      } else {
        translations['description'] = '';
      }

      return translations;
    } else {
      return {
        'name': user.name,
        'description': user.description ?? '',
      };
    }
  }

  Color _getFarmingMethodColor(FarmingMethod method) {
    switch (method) {
      case FarmingMethod.organic:
        return Colors.green;
      case FarmingMethod.natural:
        return Colors.teal;
      case FarmingMethod.conventional:
        return Colors.blue;
      case FarmingMethod.hydroponic:
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}
