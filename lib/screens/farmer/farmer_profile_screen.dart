import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/widgets/user_avatar.dart';
import 'dart:io';
import 'package:agri_connect/services/supabase_service.dart';
import 'package:agri_connect/screens/farmer/language_settings_screen.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/l10n/app_localizations.dart';

class FarmerProfileScreen extends StatefulWidget {
  const FarmerProfileScreen({Key? key}) : super(key: key);

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  final SupabaseService _supabaseService = SupabaseService();
  bool _isEditing = false;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<AuthProvider>(context, listen: false).currentUser!;
    _nameController = TextEditingController(text: user.name);
    _phoneController = TextEditingController(text: user.phone);
    _addressController = TextEditingController(text: user.address ?? '');
    _descriptionController =
        TextEditingController(text: user.description ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Provider.of<AuthProvider>(context, listen: false).updateUserProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim(),
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;

      setState(() {
        _isEditing = false;
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
      setState(() {
        _isLoading = false;
      });
    }
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
          description: updatedUser.description,
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

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser!;

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
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _isEditing = false;
                  // Reset controllers to current user values
                  _nameController.text = user.name;
                  _phoneController.text = user.phone;
                  _addressController.text = user.address ?? '';
                  _descriptionController.text = user.description ?? '';
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
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
                    RatingBar.builder(
                      initialRating: user.rating,
                      minRating: 1,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 24,
                      ignoreGestures: true,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (rating) {},
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Profile Information
              if (_isEditing) ...[
                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: LocalizedStrings.get(context, 'farmName'),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocalizedStrings.get(context, 'pleaseEnterName');
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
                      return LocalizedStrings.get(context, 'pleaseEnterPhone');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Address field
                TextFormField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: LocalizedStrings.get(context, 'farmAddress'),
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
                const SizedBox(height: 16),

                // Description field
                TextFormField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: LocalizedStrings.get(context, 'farmDescription'),
                    prefixIcon: const Icon(Icons.description_outlined),
                    alignLabelWithHint: true,
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocalizedStrings.get(
                          context, 'pleaseEnterDescription');
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
                        : Text(LocalizedStrings.get(context, 'saveProfile')),
                  ),
                ),
              ] else ...[
                // Display profile info in non-editing mode
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
                if (user.description != null && user.description!.isNotEmpty)
                  _buildProfileInfoItem(
                    icon: Icons.description_outlined,
                    label: LocalizedStrings.get(context, 'aboutFarm'),
                    value: user.description!,
                    isMultiLine: true,
                  ),

                const SizedBox(height: 32),

                // Farming Certifications Section
                Text(
                  LocalizedStrings.get(context, 'farmingCertifications'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.lightGreen,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.verified_outlined,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                LocalizedStrings.get(
                                    context, 'organicCertification'),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                LocalizedStrings.get(
                                    context, 'tapToAddCertification'),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.add_circle_outline,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // App Settings Section
                Text(
                  LocalizedStrings.get(context, 'settings'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Language Settings
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.lightGreen,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.language_outlined,
                      color: AppColors.primaryColor,
                      size: 20,
                    ),
                  ),
                  title: Text(LocalizedStrings.get(context, 'language')),
                  subtitle: Text(_getLanguageName(context)),
                  trailing: const Icon(Icons.chevron_right),
                  contentPadding: EdgeInsets.zero,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const FarmerLanguageSettingsScreen(),
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
                      Provider.of<AuthProvider>(context, listen: false)
                          .logout();
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
      ),
    );
  }

  Widget _buildProfileInfoItem({
    required IconData icon,
    required String label,
    required String value,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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

  String _getLanguageName(BuildContext context) {
    final locale = AppLocalizations.of(context).locale;
    switch (locale.languageCode) {
      case 'en':
        return LocalizedStrings.get(context, 'english');
      case 'hi':
        return LocalizedStrings.get(context, 'hindi');
      case 'gu':
        return LocalizedStrings.get(context, 'gujarati');
      default:
        return LocalizedStrings.get(context, 'english');
    }
  }
}
