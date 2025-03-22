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
  final String? videoUrl;
  final String? cultivationPractices;
  final String? harvestDate;
  final String? bestBeforeDate;

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
    this.videoUrl,
    this.cultivationPractices,
    this.harvestDate,
    this.bestBeforeDate,
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
    String? videoUrl,
    String? cultivationPractices,
    String? harvestDate,
    String? bestBeforeDate,
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
      videoUrl: videoUrl ?? this.videoUrl,
      cultivationPractices: cultivationPractices ?? this.cultivationPractices,
      harvestDate: harvestDate ?? this.harvestDate,
      bestBeforeDate: bestBeforeDate ?? this.bestBeforeDate,
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
      'farming_method': farmingMethod.toString().split('.').last.toLowerCase(),
      'farmer_id': farmerId,
      'rating': rating,
      'image_url': imageUrl,
      'date_added': dateAdded.toIso8601String(),
      'is_available': isAvailable,
      'video_url': videoUrl,
      'cultivation_practices': cultivationPractices,
      'harvest_date': harvestDate,
      'best_before_date': bestBeforeDate,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    FarmingMethod method;
    String methodStr = json['farming_method'] ?? 'conventional';

    switch (methodStr) {
      case 'organic':
        method = FarmingMethod.organic;
        break;
      case 'natural':
        method = FarmingMethod.natural;
        break;
      case 'conventional':
        method = FarmingMethod.conventional;
        break;
      case 'hydroponic':
        method = FarmingMethod.hydroponic;
        break;
      default:
        method = FarmingMethod.conventional;
    }

    DateTime dateAdded;
    try {
      dateAdded = json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now();
    } catch (e) {
      dateAdded = DateTime.now();
    }

    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'kg',
      description: json['description'] ?? '',
      farmingMethod: method,
      farmerId: json['farmer_id'] ?? '',
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: json['image_url'],
      dateAdded: dateAdded,
      isAvailable: json['is_available'] ?? true,
      videoUrl: json['video_url'],
      cultivationPractices: json['cultivation_practices'],
      harvestDate: json['harvest_date'],
      bestBeforeDate: json['best_before_date'],
    );
  }

  String get farmingMethodString {
    switch (farmingMethod) {
      case FarmingMethod.organic:
        return 'Organic';
      case FarmingMethod.natural:
        return 'Natural';
      case FarmingMethod.conventional:
        return 'Conventional';
      case FarmingMethod.hydroponic:
        return 'Hydroponic';
      default:
        return 'Conventional';
    }
  }
}
