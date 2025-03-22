import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:agri_connect/providers/auth_provider.dart';
import 'package:agri_connect/providers/product_provider.dart';
import 'package:agri_connect/screens/farmer/farmer_dashboard.dart';
import 'package:agri_connect/models/product.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/localization_helper.dart';
import 'package:agri_connect/services/supabase_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _quantityController = TextEditingController();
  final _unitController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _videoUrlController = TextEditingController();
  final _cultivationPracticesController = TextEditingController();
  final _harvestDateController = TextEditingController();
  final _bestBeforeDateController = TextEditingController();

  FarmingMethod _selectedMethod = FarmingMethod.organic;
  bool _isOrganicCertified = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _descriptionController.dispose();
    _videoUrlController.dispose();
    _cultivationPracticesController.dispose();
    _harvestDateController.dispose();
    _bestBeforeDateController.dispose();
    super.dispose();
  }

  Future<void> _saveProduct() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Validate form
      if (!_formKey.currentState!.validate()) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Save form data
      _formKey.currentState!.save();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      final user = authProvider.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      debugPrint('Adding product with farmer ID: ${user.id}');

      // Create product with a default image
      final success = await productProvider.addProduct(
        name: _nameController.text.trim(),
        price: double.parse(_priceController.text),
        quantity: double.parse(_quantityController.text),
        unit: _unitController.text.trim(),
        description: _descriptionController.text.trim(),
        farmingMethod: _selectedMethod,
        farmerId: user.id,
        videoUrl: _videoUrlController.text.trim(),
        cultivationPractices: _cultivationPracticesController.text.trim(),
        harvestDate: _harvestDateController.text.trim(),
        bestBeforeDate: _bestBeforeDateController.text.trim(),
      );

      if (success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(LocalizedStrings.get(context, 'productAdded')),
              backgroundColor: AppColors.successColor,
            ),
          );
        }

        // Navigate back to dashboard
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const FarmerDashboard()),
          );
        }
      } else {
        throw Exception('Failed to add product');
      }
    } catch (e) {
      debugPrint('Error saving product: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                '${LocalizedStrings.get(context, 'errorAddingProduct')}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image Placeholder
              Center(
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: AppColors.lightGreen,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 50,
                          color: AppColors.primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Product Image',
                          style: TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Product Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: AppStrings.productName,
                  prefixIcon: Icon(Icons.inventory_2_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter product name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Price and Quantity
              Row(
                children: [
                  // Price
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppStrings.productPrice,
                        prefixIcon: Icon(Icons.attach_money),
                        prefixText: '₹ ',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter valid price';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Quantity
                  Expanded(
                    child: TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: AppStrings.productQuantity,
                        prefixIcon: Icon(Icons.scale_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Enter valid quantity';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Unit
              TextFormField(
                controller: _unitController,
                decoration: const InputDecoration(
                  labelText: 'Unit (kg, liter, piece, etc.)',
                  prefixIcon: Icon(Icons.straighten_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter unit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: AppStrings.productDescription,
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Farming Video URL
              TextFormField(
                controller: _videoUrlController,
                decoration: const InputDecoration(
                  labelText: 'Farming Video URL',
                  prefixIcon: Icon(Icons.video_library_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter farming video URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Cultivation Practices
              TextFormField(
                controller: _cultivationPracticesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Cultivation Practices',
                  prefixIcon: Icon(Icons.agriculture_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter cultivation practices';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Harvest Date
              TextFormField(
                controller: _harvestDateController,
                decoration: const InputDecoration(
                  labelText: 'Harvest Date',
                  prefixIcon: Icon(Icons.date_range_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter harvest date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Best Before Date
              TextFormField(
                controller: _bestBeforeDateController,
                decoration: const InputDecoration(
                  labelText: 'Best Before Date',
                  prefixIcon: Icon(Icons.date_range_outlined),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter best before date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Farming Method
              Text(
                AppStrings.farmingMethod,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                children: [
                  _buildMethodChip(FarmingMethod.organic, 'Organic'),
                  _buildMethodChip(FarmingMethod.natural, 'Natural'),
                  _buildMethodChip(FarmingMethod.conventional, 'Conventional'),
                  _buildMethodChip(FarmingMethod.hydroponic, 'Hydroponic'),
                ],
              ),
              const SizedBox(height: 16),

              // Organic Certification
              if (_selectedMethod == FarmingMethod.organic)
                SwitchListTile(
                  title: const Text(AppStrings.organicCertified),
                  subtitle:
                      const Text('This product has organic certification'),
                  value: _isOrganicCertified,
                  activeColor: AppColors.primaryColor,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (value) {
                    setState(() {
                      _isOrganicCertified = value;
                    });
                  },
                ),

              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProduct,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Save Product'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodChip(FarmingMethod method, String label) {
    final isSelected = _selectedMethod == method;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedMethod = method;
        });
      },
      child: Chip(
        label: Text(label),
        backgroundColor:
            isSelected ? AppColors.primaryColor : AppColors.lightGreyColor,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.textColor,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
