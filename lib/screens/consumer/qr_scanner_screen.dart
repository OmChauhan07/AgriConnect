import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/dummy_data.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;
  String? _scannedData;
  Map<String, dynamic>? _productData;
  bool _isVerified = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (!_isScanning) return;
    
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;
    
    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;
    
    setState(() {
      _isScanning = false;
      _scannedData = barcode.rawValue;
    });
    
    _processScannedData();
  }

  void _processScannedData() {
    if (_scannedData == null) return;
    
    try {
      // Try to parse the QR data as JSON
      final Map<String, dynamic> data = jsonDecode(_scannedData!);
      
      // Check if this is a valid product QR code
      if (data.containsKey('product_id') && data.containsKey('farmer_id')) {
        setState(() {
          _productData = data;
          _isVerified = data['is_verified'] == true;
        });
      } else {
        _showInvalidQRSnackBar('Invalid product QR code format');
      }
    } catch (e) {
      _showInvalidQRSnackBar('Unable to process QR code data');
    }
  }

  void _showInvalidQRSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.errorColor,
        action: SnackBarAction(
          label: 'SCAN AGAIN',
          textColor: Colors.white,
          onPressed: _resetScanner,
        ),
      ),
    );
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _scannedData = null;
      _productData = null;
      _isVerified = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _scannerController.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.flip_camera_ios),
            onPressed: () => _scannerController.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _productData != null
                ? _buildProductVerificationResult()
                : Stack(
                    alignment: Alignment.center,
                    children: [
                      MobileScanner(
                        controller: _scannerController,
                        onDetect: _onDetect,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primaryColor,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        width: 250,
                        height: 250,
                      ),
                      Positioned(
                        bottom: 32,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text(
                            'Align QR code within the frame',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          
          // Bottom instructions
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Text(
                  'Scan the QR code on the product to verify its authenticity and trace its origin.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildInfoItem(
                      icon: Icons.verified_user_outlined,
                      label: 'Verify Product',
                    ),
                    const SizedBox(width: 24),
                    _buildInfoItem(
                      icon: Icons.track_changes_outlined,
                      label: 'Track Origin',
                    ),
                    const SizedBox(width: 24),
                    _buildInfoItem(
                      icon: Icons.info_outline,
                      label: 'View Details',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String label,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.primaryColor,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.greyColor,
          ),
        ),
      ],
    );
  }

  Widget _buildProductVerificationResult() {
    if (_productData == null) return const SizedBox();
    
    final productName = _productData!['name'] ?? 'Unknown Product';
    final farmerId = _productData!['farmer_id'] ?? '';
    final farmingMethod = _productData!['farming_method'] ?? 'Unknown';
    final dateAdded = _productData!['date_added'] ?? '';
    
    // Find the farmer from dummy data
    final farmer = dummyFarmers.firstWhere(
      (f) => f.id == farmerId,
      orElse: () => dummyFarmers.first,
    );
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Verification Status
          Center(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _isVerified ? Colors.green.shade50 : Colors.red.shade50,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isVerified ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Icon(
                _isVerified ? Icons.verified_outlined : Icons.gpp_bad_outlined,
                size: 48,
                color: _isVerified ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              _isVerified ? 'Product Verified' : 'Verification Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _isVerified ? Colors.green : Colors.red,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _isVerified
                  ? 'This product is authentic and traceable'
                  : 'Could not verify product authenticity',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.greyColor,
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Product Details
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDetailRow('Product Name', productName),
                  const Divider(),
                  _buildDetailRow('Farming Method', farmingMethod),
                  const Divider(),
                  _buildDetailRow('Date Added', 
                    dateAdded.isNotEmpty ? dateAdded.substring(0, 10) : 'Unknown'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Farmer Details
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Farmer Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          shape: BoxShape.circle,
                        ),
                        child: farmer.profileImageUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.network(
                                  farmer.profileImageUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Icon(
                                Icons.person,
                                color: AppColors.primaryColor,
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              farmer.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  farmer.rating.toString(),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.greyColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetScanner,
                  icon: const Icon(Icons.qr_code_scanner),
                  label: const Text('Scan Again'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('Done'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.greyColor,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
