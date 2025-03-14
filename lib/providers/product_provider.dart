import 'package:flutter/material.dart';
import 'package:agri_connect/models/product.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/dummy_data.dart';

class ProductProvider with ChangeNotifier {
  List<Product> get allProducts => List.from(dummyProducts);
  
  List<Product> getProductsByFarmer(String farmerId) {
    return dummyProducts.where((product) => product.farmerId == farmerId).toList();
  }
  
  Product? getProductById(String productId) {
    try {
      return dummyProducts.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }
  
  List<Product> getTopRatedProducts({int limit = 5}) {
    final products = List<Product>.from(dummyProducts);
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
  }) async {
    try {
      final newProduct = Product(
        id: 'p${dummyProducts.length + 1}',
        name: name,
        price: price,
        quantity: quantity,
        unit: unit,
        description: description,
        farmingMethod: farmingMethod,
        farmerId: farmerId,
        rating: 0.0,
        imageUrl: imageUrl ?? 'https://cdn-icons-png.flaticon.com/512/1799/1799977.png',
        dateAdded: DateTime.now(),
      );
      
      dummyProducts.add(newProduct);
      notifyListeners();
      return true;
    } catch (e) {
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
  }) async {
    try {
      final index = dummyProducts.indexWhere((product) => product.id == productId);
      if (index != -1) {
        dummyProducts[index] = dummyProducts[index].copyWith(
          name: name,
          price: price,
          quantity: quantity,
          unit: unit,
          description: description,
          farmingMethod: farmingMethod,
          isAvailable: isAvailable,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> deleteProduct(String productId) async {
    try {
      dummyProducts.removeWhere((product) => product.id == productId);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
  
  // Generate QR Code data for a product
  String generateQRCodeData(String productId) {
    final product = getProductById(productId);
    if (product == null) return '';
    
    final farmer = dummyFarmers.firstWhere(
      (farmer) => farmer.id == product.farmerId,
      orElse: () => dummyFarmers.first,
    );
    
    return '''
    {
      "product_id": "${product.id}",
      "name": "${product.name}",
      "price": ${product.price},
      "farming_method": "${product.farmingMethodString}",
      "farmer_name": "${farmer.name}",
      "farmer_id": "${farmer.id}",
      "date_added": "${product.dateAdded.toIso8601String()}",
      "is_verified": true
    }
    ''';
  }
  
  // Save QR code data for a product
  Future<bool> saveQRCodeData(String productId, String qrCodeData) async {
    try {
      final index = dummyProducts.indexWhere((product) => product.id == productId);
      if (index != -1) {
        dummyProducts[index] = dummyProducts[index].copyWith(
          qrCodeData: qrCodeData,
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }
  
  List<Product> searchProducts(String query) {
    if (query.isEmpty) return allProducts;
    
    return dummyProducts.where((product) {
      return product.name.toLowerCase().contains(query.toLowerCase()) ||
             product.description.toLowerCase().contains(query.toLowerCase());
    }).toList();
  }
}
