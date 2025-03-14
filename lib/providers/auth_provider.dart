import 'package:flutter/material.dart';
import 'package:agri_connect/models/user.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/dummy_data.dart';

class AuthProvider with ChangeNotifier {
  User? _currentUser;
  bool _isAuthenticated = false;
  UserRole? _selectedRole;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get selectedRole => _selectedRole;

  void setSelectedRole(UserRole role) {
    _selectedRole = role;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    // For prototype, we'll use some basic validation and dummy data
    if (email.isEmpty || password.isEmpty) {
      return false;
    }

    // Check if email exists in our dummy data
    if (_selectedRole == UserRole.farmer) {
      for (var farmer in dummyFarmers) {
        if (farmer.email == email) {
          // In a real app, we would verify the password
          _currentUser = farmer;
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }
    } else if (_selectedRole == UserRole.consumer) {
      for (var consumer in dummyConsumers) {
        if (consumer.email == email) {
          // In a real app, we would verify the password
          _currentUser = consumer;
          _isAuthenticated = true;
          notifyListeners();
          return true;
        }
      }
    }

    return false;
  }

  Future<bool> signup(String name, String email, String password) async {
    // For prototype, we'll use some basic validation
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      return false;
    }

    // Create a new user
    final newUser = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      role: _selectedRole!,
      profileImageUrl: _selectedRole == UserRole.farmer
          ? 'https://cdn-icons-png.flaticon.com/512/2421/2421733.png'
          : 'https://cdn-icons-png.flaticon.com/512/3177/3177440.png',
      rating: 0,
      phone: '',
    );

    // Add to appropriate list
    if (_selectedRole == UserRole.farmer) {
      dummyFarmers.add(newUser);
    } else {
      dummyConsumers.add(newUser);
    }

    // Auto login
    _currentUser = newUser;
    _isAuthenticated = true;
    notifyListeners();
    return true;
  }

  void logout() {
    _currentUser = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? description,
  }) async {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        address: address ?? _currentUser!.address,
        description: description ?? _currentUser!.description,
      );
      notifyListeners();
    }
  }
}
