import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:agri_connect/models/product.dart';
import 'package:agri_connect/models/user.dart' as models;
import 'package:agri_connect/models/order.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:image/image.dart' as img;

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // Auth methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
  }) async {
    try {
      // Create auth user first
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'role': role.toString(),
        },
      );

      if (response.user == null) {
        throw Exception('Failed to create user account');
      }

      // At this point, the user is automatically signed in
      // Create the user profile using the authenticated context
      try {
        await _client.from('users').insert({
          'id': response.user!.id,
          'name': name,
          'email': email,
          'role': role.toString(),
          'phone': '',
        });
      } catch (e) {
        debugPrint('Error creating user profile: $e');
        // Sign out if profile creation fails
        await _client.auth.signOut();
        throw Exception('Failed to create user profile');
      }

      // Sign out after successful creation since email verification is required
      await _client.auth.signOut();
      return response;
    } catch (e) {
      debugPrint('Signup error in SupabaseService: $e');
      rethrow;
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      debugPrint('Signin error in SupabaseService: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Signout error in SupabaseService: $e');
      rethrow;
    }
  }

  // Product methods
  Future<List<Product>> getProducts() async {
    try {
      debugPrint('Fetching products from database...');
      final response = await _client
          .from('products')
          .select()
          .order('created_at', ascending: false);

      debugPrint('Raw response from Supabase: $response');

      if (response is List && response.isNotEmpty) {
        debugPrint('First product data: ${response[0]}');
        if (response[0]['farmer_id'] != null) {
          debugPrint('Farmer ID of first product: ${response[0]['farmer_id']}');
        } else {
          debugPrint('First product has no farmer_id field');
        }
      }

      List<Product> products = [];
      for (var item in response as List) {
        try {
          products.add(Product.fromJson(item));
        } catch (e) {
          debugPrint('Error parsing product: $e');
          debugPrint('Problematic data: $item');
        }
      }

      debugPrint('Successfully parsed ${products.length} products');
      return products;
    } catch (e) {
      debugPrint('Error fetching products: $e');
      return [];
    }
  }

  Future<List<Product>> getProductsByFarmer(String farmerId) async {
    final response = await _client
        .from('products')
        .select()
        .eq('farmer_id', farmerId)
        .order('date_added', ascending: false);

    return (response as List)
        .map((product) => Product.fromJson(product))
        .toList();
  }

  Future<Product?> getProductById(String productId) async {
    final response =
        await _client.from('products').select().eq('id', productId).single();

    return response != null ? Product.fromJson(response) : null;
  }

  Future<void> addProduct(Product product) async {
    try {
      debugPrint('Starting product addition process...');

      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }
      debugPrint('Current user ID: ${currentUser.id}');

      // Simplify the farming method string (remove enum prefix)
      final farmingMethodStr =
          product.farmingMethod.toString().split('.').last.toLowerCase();
      debugPrint('Farming method: $farmingMethodStr');

      // Create a simplified product data structure
      final productData = {
        'name': product.name,
        'price': product.price,
        'quantity': product.quantity,
        'unit': product.unit,
        'description': product.description,
        'farming_method': farmingMethodStr,
        'farmer_id': currentUser.id,
        'video_url': product.videoUrl,
        'cultivation_practices': product.cultivationPractices,
        'harvest_date': product.harvestDate,
        'best_before_date': product.bestBeforeDate,
        'is_available': true,
        'rating': 0.0,
        'image_url': product.imageUrl ??
            'https://cdn-icons-png.flaticon.com/512/1799/1799977.png',
      };

      debugPrint('Attempting to insert product with data: $productData');

      final response =
          await _client.from('products').insert(productData).select().single();

      debugPrint('Insert response: $response');
      debugPrint('Product added successfully: ${response['id']}');
    } catch (e) {
      debugPrint('Error adding product: $e');
      rethrow;
    }
  }

  Future<void> updateProduct(Product product) async {
    await _client
        .from('products')
        .update(product.toJson())
        .eq('id', product.id);
  }

  Future<void> deleteProduct(String productId) async {
    await _client.from('products').delete().eq('id', productId);
  }

  // User methods
  Future<models.User?> getCurrentUser() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return null;

      final response =
          await _client.from('users').select().eq('id', user.id).single();

      if (response == null) {
        debugPrint('No user profile found for ID: ${user.id}');
        return null;
      }

      return models.User.fromJson(response);
    } catch (e) {
      debugPrint('Get current user error in SupabaseService: $e');
      return null;
    }
  }

  Future<void> updateUserProfile(models.User user) async {
    try {
      final currentUser = _client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('No authenticated user found');
      }

      if (currentUser.id != user.id) {
        throw Exception('Cannot update profile for different user');
      }

      final userData = {
        'name': user.name,
        'phone': user.phone,
        'address': user.address,
        'description': user.description,
        'updated_at': DateTime.now().toIso8601String(),
      };

      final response = await _client
          .from('users')
          .update(userData)
          .eq('id', user.id)
          .select()
          .single();

      if (response == null) {
        throw Exception('Failed to update user profile');
      }
    } catch (e) {
      debugPrint('Error updating user profile: $e');
      throw Exception('Failed to update profile: ${e.toString()}');
    }
  }

  // Storage methods
  Future<String?> uploadProfileImage(File imageFile, String userId) async {
    try {
      debugPrint('Starting profile image upload process...');

      // Simple validation
      if (!imageFile.existsSync()) {
        throw Exception('Image file does not exist');
      }

      // Read file as bytes directly
      final bytes = await imageFile.readAsBytes();
      debugPrint('Read ${bytes.length} bytes from file');

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path).toLowerCase();
      final filename = 'profile_$userId\_$timestamp$extension';

      debugPrint('Uploading file: $filename');

      // Upload file directly without processing
      await _client.storage.from('profiles').uploadBinary(
            filename,
            bytes,
            fileOptions: FileOptions(
              contentType: 'image/png',
              upsert: true,
            ),
          );

      debugPrint('Upload successful, getting public URL');

      // Get the public URL
      final imageUrl = _client.storage.from('profiles').getPublicUrl(filename);
      debugPrint('Image URL: $imageUrl');

      // Update user profile with new image URL
      await _client
          .from('users')
          .update({'profile_image_url': imageUrl}).eq('id', userId);

      debugPrint('Profile updated successfully');
      return imageUrl;
    } catch (e) {
      debugPrint('Error in uploadProfileImage: $e');
      throw Exception('Failed to update profile image: ${e.toString()}');
    }
  }

  Future<void> deleteProfileImage(String userId) async {
    try {
      // Get the current profile image URL
      final response = await _client
          .from('users')
          .select('profile_image_url')
          .eq('id', userId)
          .single();

      if (response != null && response['profile_image_url'] != null) {
        final imageUrl = response['profile_image_url'] as String;
        final filePath = imageUrl.split('profiles/').last;

        // Delete the file from storage
        await _client.storage.from('profiles').remove([filePath]);

        // Update the user's profile to remove the image URL
        await _client
            .from('users')
            .update({'profile_image_url': null}).eq('id', userId);
      }
    } catch (e) {
      debugPrint('Error deleting profile image: $e');
      throw Exception('Failed to delete profile image: ${e.toString()}');
    }
  }

  // Order methods
  Future<String> createOrder({
    required String userId,
    required List<Map<String, dynamic>> items,
    required String deliveryAddress,
    required double totalAmount,
    required String paymentMethod,
  }) async {
    try {
      final order = {
        'user_id': userId,
        'status': 'pending',
        'total_amount': totalAmount,
        'delivery_address': deliveryAddress,
        'payment_method': paymentMethod,
        'order_date': DateTime.now().toIso8601String(),
      };

      // Insert order and get the ID
      final orderResponse =
          await _client.from('orders').insert(order).select('id').single();

      if (orderResponse == null) {
        throw Exception('Failed to create order');
      }

      final orderId = orderResponse['id'];

      // Insert order items
      for (final item in items) {
        final orderItem = {
          'order_id': orderId,
          'product_id': item['product_id'],
          'quantity': item['quantity'],
          'price': item['price'],
        };

        await _client.from('order_items').insert(orderItem);
      }

      // Update product quantities
      for (final item in items) {
        final productId = item['product_id'];
        final quantity = item['quantity'];

        // Get current product
        final productResponse = await _client
            .from('products')
            .select('quantity')
            .eq('id', productId)
            .single();

        if (productResponse != null) {
          final currentQuantity = productResponse['quantity'];
          final newQuantity = currentQuantity - quantity;

          if (newQuantity >= 0) {
            await _client
                .from('products')
                .update({'quantity': newQuantity}).eq('id', productId);
          }
        }
      }

      return orderId;
    } catch (e) {
      debugPrint('Create order error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getOrdersByUser(String userId) async {
    try {
      // First, get all orders for this user
      final orderResponse = await _client
          .from('orders')
          .select('*')
          .eq('user_id', userId)
          .order('order_date', ascending: false);

      if (orderResponse == null) {
        return [];
      }

      final List<Order> orders = [];

      // For each order, get the order items
      for (final orderData in orderResponse) {
        final orderId = orderData['id'];

        // Get order items
        final itemsResponse = await _client
            .from('order_items')
            .select('*, products(*)')
            .eq('order_id', orderId);

        if (itemsResponse == null) {
          continue;
        }

        final List<OrderItem> items = [];
        String farmerId = '';

        // Process order items
        for (final item in itemsResponse) {
          final product = item['products'];
          if (product != null) {
            farmerId =
                product['farmer_id']; // Assuming all items are from same farmer

            items.add(OrderItem(
              productId: item['product_id'],
              quantity: item['quantity'].toDouble(),
              price: item['price'].toDouble(),
            ));
          }
        }

        // Convert order status string to enum
        OrderStatus status;
        switch (orderData['status']) {
          case 'pending':
            status = OrderStatus.pending;
            break;
          case 'accepted':
            status = OrderStatus.accepted;
            break;
          case 'rejected':
            status = OrderStatus.rejected;
            break;
          case 'shipped':
            status = OrderStatus.shipped;
            break;
          case 'delivered':
            status = OrderStatus.delivered;
            break;
          case 'cancelled':
            status = OrderStatus.cancelled;
            break;
          default:
            status = OrderStatus.pending;
        }

        // Create Order object
        final order = Order(
          id: orderId,
          consumerId: userId,
          farmerId: farmerId,
          products: items,
          totalAmount: orderData['total_amount'].toDouble(),
          status: status,
          orderDate: DateTime.parse(orderData['order_date']),
          deliveryAddress: orderData['delivery_address'],
          notes: orderData['notes'],
        );

        orders.add(order);
      }

      return orders;
    } catch (e) {
      debugPrint('Get orders error: $e');
      return [];
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _client
          .from('orders')
          .update({'status': status.split('.').last}).eq('id', orderId);
    } catch (e) {
      debugPrint('Update order status error: $e');
      rethrow;
    }
  }
}
