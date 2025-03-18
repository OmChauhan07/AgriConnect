import 'package:flutter/material.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final bool showEditIcon;
  final Function(File)? onImageSelected;

  const UserAvatar({
    Key? key,
    this.imageUrl,
    this.radius = 30,
    this.showEditIcon = false,
    this.onImageSelected,
  }) : super(key: key);

  Future<void> _pickImage(BuildContext context) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null && onImageSelected != null) {
        onImageSelected!(File(image.path));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GestureDetector(
          onTap: showEditIcon ? () => _pickImage(context) : null,
          child: Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.lightGreen,
              border: Border.all(
                color: AppColors.primaryColor,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: imageUrl != null
                  ? Image.network(
                      imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          size: radius,
                          color: AppColors.primaryColor,
                        );
                      },
                    )
                  : Icon(
                      Icons.person,
                      size: radius,
                      color: AppColors.primaryColor,
                    ),
            ),
          ),
        ),
        if (showEditIcon)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.edit,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}
