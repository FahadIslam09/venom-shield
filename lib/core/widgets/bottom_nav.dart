import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';

class VenomShieldBottomNav extends StatelessWidget {
  final int currentIndex;

  const VenomShieldBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8, top: 8),
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(
            top: BorderSide(color: AppColors.outlineVariant, width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(context, Icons.home, 'হোম', currentIndex == 0, () {
              if (currentIndex != 0) context.go('/');
            }),
            _buildNavItem(context, Icons.settings_overscan, 'স্ক্যানার', currentIndex == 1, () {
              if (currentIndex != 1) context.go('/scan');
            }),
            _buildNavItem(context, Icons.assignment, 'মূল্যায়ন', currentIndex == 2, () {
              if (currentIndex != 2) context.go('/triage-checklist');
            }),
            _buildNavItem(context, Icons.local_hospital, 'হাসপাতাল', currentIndex == 3, () {
              if (currentIndex != 3) context.go('/hospital-radar');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: isActive
            ? BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: BorderRadius.circular(999),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.onPrimaryContainer : AppColors.onSecondaryContainer,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isActive ? AppColors.onPrimaryContainer : AppColors.onSecondaryContainer,
                letterSpacing: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
