import 'package:flutter/material.dart';
import 'package:agri_connect/utils/constants.dart';
import 'package:agri_connect/utils/localization_helper.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final bool isFarmer;

  const CustomBottomNavigation({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.isFarmer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: isFarmer
              ? _buildFarmerNavItems(context)
              : _buildConsumerNavItems(context),
        ),
      ),
    );
  }

  List<Widget> _buildFarmerNavItems(BuildContext context) {
    return [
      _buildNavItem(
        context: context,
        index: 0,
        icon: Icons.dashboard_outlined,
        activeIcon: Icons.dashboard,
        label: LocalizedStrings.get(context, 'dashboard'),
      ),
      _buildNavItem(
        context: context,
        index: 1,
        icon: Icons.shopping_bag_outlined,
        activeIcon: Icons.shopping_bag,
        label: LocalizedStrings.get(context, 'orders'),
      ),
      _buildNavItem(
        context: context,
        index: 2,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: LocalizedStrings.get(context, 'profile'),
      ),
    ];
  }

  List<Widget> _buildConsumerNavItems(BuildContext context) {
    return [
      _buildNavItem(
        context: context,
        index: 0,
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: LocalizedStrings.get(context, 'home'),
      ),
      _buildNavItem(
        context: context,
        index: 1,
        icon: Icons.shopping_cart_outlined,
        activeIcon: Icons.shopping_cart,
        label: LocalizedStrings.get(context, 'cart'),
      ),
      _buildNavItem(
        context: context,
        index: 2,
        icon: Icons.person_outline,
        activeIcon: Icons.person,
        label: LocalizedStrings.get(context, 'profile'),
      ),
    ];
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.lightGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primaryColor : AppColors.greyColor,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected ? AppColors.primaryColor : AppColors.greyColor,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
