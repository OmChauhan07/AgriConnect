import 'package:flutter/material.dart';
import 'package:agri_connect/models/product.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/services/supabase_service.dart';

class ProductProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get allProducts => List.from(_products);
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    try {
      _isLoading = true;
      notifyListeners();

      _products = await _supabaseService.getProducts();
      notifyListeners();
    } catch (e) {
      debugPrint('Load products error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<Product> getProductsByFarmer(String farmerId) {
    return _products.where((product) => product.farmerId == farmerId).toList();
  }

  Product? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  List<Product> getTopRatedProducts({int limit = 5}) {
    final products = List<Product>.from(_products);
    products.sort((a, b) => b.rating.compareTo(a.rating));
    return products.take(limit).toList();
  }

  Future<bool> addProduct({
    required String name,
    required double price,
    required double quantity,
    required String unit,
    required String description,
    required FarmingMethod farmingMethod,
    required String farmerId,
    String? imageUrl,
    String? videoUrl,
    String? cultivationPractices,
    String? harvestDate,
    String? bestBeforeDate,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final newProduct = Product(
        id: farmerId + '_' + timestamp.toString(),
        name: name,
        price: price,
        quantity: quantity,
        unit: unit,
        description: description,
        farmingMethod: farmingMethod,
        farmerId: farmerId,
        rating: 0.0,
        imageUrl: imageUrl ??
            'https://cdn-icons-png.flaticon.com/512/1799/1799977.png',
        dateAdded: DateTime.now(),
        videoUrl: videoUrl,
        cultivationPractices: cultivationPractices,
        harvestDate: harvestDate,
        bestBeforeDate: bestBeforeDate,
      );

      await _supabaseService.addProduct(newProduct);
      await loadProducts();
      return true;
    } catch (e) {
      debugPrint('Add product error: $e');
      return false;
    }
  }

  Future<bool> updateProduct({
    required String productId,
    String? name,
    double? price,
    double? quantity,
    String? unit,
    String? description,
    FarmingMethod? farmingMethod,
    bool? isAvailable,
    String? videoUrl,
    String? cultivationPractices,
    String? harvestDate,
    String? bestBeforeDate,
  }) async {
    try {
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        final updatedProduct = _products[index].copyWith(
          name: name,
          price: price,
          quantity: quantity,
          unit: unit,
          description: description,
          farmingMethod: farmingMethod,
          isAvailable: isAvailable,
          videoUrl: videoUrl,
          cultivationPractices: cultivationPractices,
          harvestDate: harvestDate,
          bestBeforeDate: bestBeforeDate,
        );

        await _supabaseService.updateProduct(updatedProduct);
        _products[index] = updatedProduct;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Update product error: $e');
      return false;
    }
  }

  Future<bool> deleteProduct(String productId) async {
    try {
      await _supabaseService.deleteProduct(productId);
      _products.removeWhere((product) => product.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Delete product error: $e');
      return false;
    }
  }

  String generateQRCodeData(String productId) {
    final product = getProductById(productId);
    if (product == null) return '';

    return '''
    {
      "product_id": "${product.id}",
      "name": "${product.name}",
      "price": ${product.price},
      "farming_method": "${product.farmingMethodString}",
      "farmer_id": "${product.farmerId}",
      "date_added": "${product.dateAdded.toIso8601String()}",
      "is_verified": true
    }
    ''';
  }

  Future<bool> saveQRCodeData(String productId, String qrCodeData) async {
    try {
      final index = _products.indexWhere((product) => product.id == productId);
      if (index != -1) {
        final updatedProduct = _products[index].copyWith(
          qrCodeData: qrCodeData,
        );

        await _supabaseService.updateProduct(updatedProduct);
        _products[index] = updatedProduct;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Save QR code data error: $e');
      return false;
    }
  }

  List<Product> searchProducts(String query) {
    if (query.isEmpty) return allProducts;

    return _products.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
          product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
