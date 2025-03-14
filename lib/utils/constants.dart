import 'package:flutter/material.dart';

class AppColors {
  static Color primaryColor = const Color(0xFF019267);
  static Color accentColor = const Color(0xFF00C897);
  static Color lightGreen = const Color(0xFFE0F7E9);
  static Color textColor = const Color(0xFF333333);
  static Color greyColor = const Color(0xFFAAAAAA);
  static Color lightGreyColor = const Color(0xFFEEEEEE);
  static Color errorColor = const Color(0xFFE53935);
  static Color successColor = const Color(0xFF4CAF50);
}

class AppFonts {
  static double extraSmall = 12.0;
  static double small = 14.0;
  static double medium = 16.0;
  static double large = 18.0;
  static double extraLarge = 22.0;
  static double huge = 26.0;
}

class AppStrings {
  // App Name
  static const appName = "AgriConnect";
  
  // Onboarding
  static const welcome = "Welcome to AgriConnect";
  static const chooseRole = "Choose your role";
  static const farmer = "Farmer";
  static const consumer = "Consumer";
  static const login = "Sign In";
  static const signup = "Sign Up";
  static const email = "Email";
  static const username = "Username";
  static const password = "Password";
  static const confirmPassword = "Confirm Password";
  static const dontHaveAccount = "Don't have account?";
  static const alreadyHaveAccount = "Already have account?";
  static const register = "Register";
  
  // Farmer
  static const addProduct = "Add Product";
  static const manageProducts = "Manage Products";
  static const manageOrders = "Manage Orders";
  static const farmProfile = "Farm Profile";
  static const productName = "Product Name";
  static const productType = "Product Type";
  static const productPrice = "Price";
  static const productQuantity = "Quantity";
  static const productDescription = "Description";
  static const farmingMethod = "Farming Method";
  static const generateQR = "Generate QR Code";
  static const organicCertified = "Organic Certified";
  
  // Consumer
  static const scan = "Scan QR";
  static const marketplace = "Marketplace";
  static const cart = "Cart";
  static const orderHistory = "Order History";
  static const checkout = "Checkout";
  static const addToCart = "Add to Cart";
  static const totalAmount = "Total Amount";
  static const placeOrder = "Place Order";
  static const searchProducts = "Search products...";
  static const verifyProduct = "Verify Product";
  
  // Common
  static const profile = "Profile";
  static const settings = "Settings";
  static const notifications = "Notifications";
  static const logout = "Logout";
  static const save = "Save";
  static const cancel = "Cancel";
  static const delete = "Delete";
  static const edit = "Edit";
  static const viewDetails = "View Details";
}

enum UserRole {
  farmer,
  consumer,
}

enum OrderStatus {
  pending,
  accepted,
  rejected,
  shipped,
  delivered,
  cancelled,
}

enum FarmingMethod {
  organic,
  natural,
  conventional,
  hydroponic,
}
