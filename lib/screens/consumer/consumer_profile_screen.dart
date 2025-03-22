import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/order_provider.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/widgets/user_avatar.dart';
import 'dart:io';
import 'package:agri_connect/services/supabase_service.dart';
import 'package:agri_connect/screens/consumer/language_settings_screen.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/l10n/app_localizations.dart';
import 'package:agri_connect/widgets/language_switcher.dart';

class ConsumerProfileScreen extends StatefulWidget {
  const ConsumerProfileScreen({Key? key}) : super(key: key);

  @override
  State<ConsumerProfileScreen> createState() => _ConsumerProfileScreenState();
}

class _ConsumerProfileScreenState extends State<ConsumerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  final SupabaseService _supabaseService = SupabaseService();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser;
    if (user != null) {
      _nameController.text = user.name;
      _phoneController.text = user.phone;
      _addressController.text = user.address ?? '';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleImageSelected(File imageFile) async {
    setState(() {
      _isUploadingImage = true;
    });

    try {
      final user =
          Provider.of<AuthProvider>(context, listen: false).currentUser!;
      final imageUrl =
          await _supabaseService.uploadProfileImage(imageFile, user.id);

      if (imageUrl != null) {
        // Update the user's profile with the new image URL
        final updatedUser = user.copyWith(profileImageUrl: imageUrl);
        await Provider.of<AuthProvider>(context, listen: false)
            .updateUserProfile(
          name: updatedUser.name,
          phone: updatedUser.phone,
          address: updatedUser.address,
        );

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(LocalizedStrings.get(context, 'profileImageUpdated'))),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                '${LocalizedStrings.get(context, 'profileImageUpdateError')}: $e')),
      );
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await Provider.of<AuthProvider>(context, listen: false)
            .updateUserProfile(
          name: _nameController.text,
          phone: _phoneController.text,
          address: _addressController.text,
        );

        if (!mounted) return;
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(LocalizedStrings.get(context, 'profileUpdated'))),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  '${LocalizedStrings.get(context, 'profileUpdateError')}: ${e.toString()}')),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.currentUser!;
    final orders =
        Provider.of<OrderProvider>(context).getOrdersByConsumer(user.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(LocalizedStrings.get(context, 'profile')),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            )
          else
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  _loadUserData(); // Reset form data
                });
              },
            ),
          const LanguageSwitcher(),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      UserAvatar(
                        imageUrl: user.profileImageUrl,
                        radius: 60,
                        showEditIcon: _isEditing,
                        onImageSelected: _handleImageSelected,
                      ),
                      if (_isUploadingImage)
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.black26,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (!_isEditing)
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    user.email,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.greyColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            if (_isEditing) ...[
              // Edit Profile Form
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: LocalizedStrings.get(context, 'name'),
                        prefixIcon: const Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocalizedStrings.get(
                              context, 'pleaseEnterName');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Phone field
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: LocalizedStrings.get(context, 'phoneNumber'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocalizedStrings.get(
                              context, 'pleaseEnterPhone');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    TextFormField(
                      controller: _addressController,
                      decoration: InputDecoration(
                        labelText: LocalizedStrings.get(context, 'address'),
                        prefixIcon: const Icon(Icons.location_on_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return LocalizedStrings.get(
                              context, 'pleaseEnterAddress');
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProfile,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                LocalizedStrings.get(context, 'saveProfile')),
                      ),
                    ),
                  ],
                ),
              ),
            ] else ...[
              // Order Statistics
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.lightGreen,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _buildStatItem(
                      count: orders.length,
                      label: LocalizedStrings.get(context, 'totalOrders'),
                    ),
                    const VerticalDivider(thickness: 1),
                    _buildStatItem(
                      count: orders
                          .where((o) => o.status == OrderStatus.delivered)
                          .length,
                      label: LocalizedStrings.get(context, 'completed'),
                    ),
                    const VerticalDivider(thickness: 1),
                    _buildStatItem(
                      count: orders
                          .where((o) =>
                              o.status == OrderStatus.pending ||
                              o.status == OrderStatus.accepted ||
                              o.status == OrderStatus.shipped)
                          .length,
                      label: LocalizedStrings.get(context, 'inProgress'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Profile Info
              Text(
                LocalizedStrings.get(context, 'personalInformation'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildProfileInfoItem(
                icon: Icons.email_outlined,
                label: LocalizedStrings.get(context, 'email'),
                value: user.email,
              ),
              _buildProfileInfoItem(
                icon: Icons.phone_outlined,
                label: LocalizedStrings.get(context, 'phone'),
                value: user.phone.isNotEmpty
                    ? user.phone
                    : LocalizedStrings.get(context, 'notProvided'),
              ),
              _buildProfileInfoItem(
                icon: Icons.location_on_outlined,
                label: LocalizedStrings.get(context, 'address'),
                value: user.address ??
                    LocalizedStrings.get(context, 'notProvided'),
              ),
              const SizedBox(height: 24),

              // Recent Orders
              Text(
                LocalizedStrings.get(context, 'recentOrders'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              if (orders.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_bag_outlined,
                        color: AppColors.greyColor,
                      ),
                      const SizedBox(width: 16),
                      Text(LocalizedStrings.get(context, 'noOrdersYet')),
                    ],
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: orders.length > 3 ? 3 : orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Order #${order.id.substring(1)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(order.status)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    order.statusString,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: _getStatusColor(order.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Date: ${_formatDate(order.orderDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.greyColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Total: ₹${order.totalAmount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

              if (orders.length > 3)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Center(
                    child: TextButton(
                      onPressed: () {
                        // In a full app, this would navigate to an orders history screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(LocalizedStrings.get(
                                context, 'featureNotAvailable')),
                          ),
                        );
                      },
                      child: Text(
                        LocalizedStrings.get(context, 'viewAllOrders'),
                        style: TextStyle(
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 32),

              // Settings/Preferences
              Text(
                LocalizedStrings.get(context, 'appSettings'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildSettingsItem(
                icon: Icons.language_outlined,
                title: LocalizedStrings.get(context, 'language'),
                subtitle: _getCurrentLanguage(context),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LanguageSettingsScreen(),
                    ),
                  );
                },
              ),
              _buildSettingsItem(
                icon: Icons.notifications_outlined,
                title: LocalizedStrings.get(context, 'notifications'),
                subtitle: LocalizedStrings.get(context, 'enabled'),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          LocalizedStrings.get(context, 'featureNotAvailable')),
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),

              // Logout Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    authProvider.logout();
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.errorColor,
                    side: BorderSide(color: AppColors.errorColor),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(LocalizedStrings.get(context, 'logout')),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({required int count, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.greyColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.lightGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.greyColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.lightGreen,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppColors.primaryColor,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.accepted:
        return Colors.blue;
      case OrderStatus.rejected:
        return AppColors.errorColor;
      case OrderStatus.shipped:
        return Colors.deepPurple;
      case OrderStatus.delivered:
        return AppColors.successColor;
      case OrderStatus.cancelled:
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  // Helper to get current language name
  String _getCurrentLanguage(BuildContext context) {
    final locale = AppLocalizations.of(context).locale;
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'hi':
        return 'हिंदी (Hindi)';
      case 'gu':
        return 'ગુજરાતી (Gujarati)';
      default:
        return 'English';
    }
  }
}
