import 'package:flutter/material.dart';
import 'package:agri_connect/models/user.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/services/supabase_service.dart';

class AuthProvider with ChangeNotifier {
  final SupabaseService _supabaseService = SupabaseService();
  User? _currentUser;
  bool _isAuthenticated = false;
  UserRole? _selectedRole;
  String? _errorMessage;

  User? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;
  UserRole? get selectedRole => _selectedRole;
  String? get errorMessage => _errorMessage;

  void setSelectedRole(UserRole role) {
    _selectedRole = role;
    _errorMessage = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _errorMessage = null;
      final response = await _supabaseService.signIn(
        email: email,
        password: password,
      );

      if (response.user != null) {
        _currentUser = await _supabaseService.getCurrentUser();
        if (_currentUser == null) {
          _errorMessage = 'Failed to load user profile';
          return false;
        }
        _isAuthenticated = true;
        notifyListeners();
        return true;
      }
      _errorMessage = 'Invalid email or password';
      return false;
    } catch (e) {
      _errorMessage = 'Login failed: ${e.toString()}';
      debugPrint('Login error: $e');
      return false;
    }
  }

  Future<bool> signup(String name, String email, String password) async {
    try {
      _errorMessage = null;

      if (_selectedRole == null) {
        _errorMessage = 'Please select a role';
        notifyListeners();
        return false;
      }

      final response = await _supabaseService.signUp(
        name: name,
        email: email,
        password: password,
        role: _selectedRole!,
      );

      if (response.user != null) {
        // Don't set current user or authenticated state here
        // User needs to verify email first
        notifyListeners();
        return true;
      }

      _errorMessage = 'Failed to create account';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('Signup error: $e');
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      _errorMessage = null;
      await _supabaseService.signOut();
      _currentUser = null;
      _isAuthenticated = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
      debugPrint('Logout error: $e');
    }
  }

  Future<void> updateUserProfile({
    String? name,
    String? phone,
    String? address,
    String? description,
  }) async {
    if (_currentUser != null) {
      try {
        final updatedUser = _currentUser!.copyWith(
          name: name ?? _currentUser!.name,
          phone: phone ?? _currentUser!.phone,
          address: address ?? _currentUser!.address,
          description: description ?? _currentUser!.description,
        );

        await _supabaseService.updateUserProfile(updatedUser);
        _currentUser = updatedUser;
        notifyListeners();
      } catch (e) {
        debugPrint('Update profile error: $e');
      }
    }
  }

  // Check if user is already logged in when app starts
  Future<void> checkAuthState() async {
    try {
      _currentUser = await _supabaseService.getCurrentUser();
      _isAuthenticated = _currentUser != null;
      notifyListeners();
    } catch (e) {
      debugPrint('Check auth state error: $e');
    }
  }
}
