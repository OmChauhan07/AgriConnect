import 'package:agri_connect/utils/constants.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final double quantity;
  final String unit;
  final String description;
  final FarmingMethod farmingMethod;
  final String farmerId;
  final double rating;
  final String? imageUrl;
  final DateTime dateAdded;
  final bool isAvailable;
  final String? qrCodeData;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.description,
    required this.farmingMethod,
    required this.farmerId,
    this.rating = 0.0,
    this.imageUrl,
    required this.dateAdded,
    this.isAvailable = true,
    this.qrCodeData,
  });

  Product copyWith({
    String? name,
    double? price,
    double? quantity,
    String? unit,
    String? description,
    FarmingMethod? farmingMethod,
    double? rating,
    String? imageUrl,
    bool? isAvailable,
    String? qrCodeData,
  }) {
    return Product(
      id: this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      description: description ?? this.description,
      farmingMethod: farmingMethod ?? this.farmingMethod,
      farmerId: this.farmerId,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      dateAdded: this.dateAdded,
      isAvailable: isAvailable ?? this.isAvailable,
      qrCodeData: qrCodeData ?? this.qrCodeData,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'description': description,
      'farmingMethod': farmingMethod.toString(),
      'farmerId': farmerId,
      'rating': rating,
      'imageUrl': imageUrl,
      'dateAdded': dateAdded.toIso8601String(),
      'isAvailable': isAvailable,
      'qrCodeData': qrCodeData,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    FarmingMethod method;
    switch (json['farmingMethod']) {
      case 'FarmingMethod.organic': method = FarmingMethod.organic; break;
      case 'FarmingMethod.natural': method = FarmingMethod.natural; break;
      case 'FarmingMethod.conventional': method = FarmingMethod.conventional; break;
      case 'FarmingMethod.hydroponic': method = FarmingMethod.hydroponic; break;
      default: method = FarmingMethod.conventional;
    }
    
    return Product(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      unit: json['unit'],
      description: json['description'],
      farmingMethod: method,
      farmerId: json['farmerId'],
      rating: json['rating'] ?? 0.0,
      imageUrl: json['imageUrl'],
      dateAdded: DateTime.parse(json['dateAdded']),
      isAvailable: json['isAvailable'] ?? true,
      qrCodeData: json['qrCodeData'],
    );
  }

  String get farmingMethodString {
    switch (farmingMethod) {
      case FarmingMethod.organic: return 'Organic';
      case FarmingMethod.natural: return 'Natural';
      case FarmingMethod.conventional: return 'Conventional';
      case FarmingMethod.hydroponic: return 'Hydroponic';
      default: return 'Conventional';
    }
  }
}
