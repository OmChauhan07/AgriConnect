import 'package:flutter/foundation.dart';
import 'package:agri_connect/utils/constants.dart';

class User {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? profileImageUrl;
  final double rating;
  final String phone;
  String? address;
  String? description;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.profileImageUrl,
    this.rating = 0.0,
    required this.phone,
    this.address,
    this.description,
  });

  User copyWith({
    String? name,
    String? email,
    UserRole? role,
    String? profileImageUrl,
    double? rating,
    String? phone,
    String? address,
    String? description,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      rating: rating ?? this.rating,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.toString(),
      'profileImageUrl': profileImageUrl,
      'rating': rating,
      'phone': phone,
      'address': address,
      'description': description,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      role: json['role'] == 'UserRole.farmer' ? UserRole.farmer : UserRole.consumer,
      profileImageUrl: json['profileImageUrl'],
      rating: json['rating'] ?? 0.0,
      phone: json['phone'] ?? '',
      address: json['address'],
      description: json['description'],
    );
  }
}
