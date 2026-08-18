import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../constants/app_colors.dart';
import '../providers/locale_provider.dart';

class VenomShieldBottomNav extends ConsumerWidget {
  final int currentIndex;

  const VenomShieldBottomNav({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lang = ref.watch(localeProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 72,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: lang.t('হোম', 'Home'),
                isActive: currentIndex == 0,
                onTap: () {
                  if (currentIndex != 0) context.go('/');
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.center_focus_weak_outlined,
                activeIcon: Icons.center_focus_strong,
                label: lang.t('স্ক্যানার', 'Scanner'),
                isActive: currentIndex == 1,
                onTap: () {
                  if (currentIndex != 1) context.go('/scan');
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.assignment_outlined,
                activeIcon: Icons.assignment,
                label: lang.t('লক্ষণ ও তালিকা', 'Symptoms & List'),
                isActive: currentIndex == 2,
                onTap: () {
                  if (currentIndex != 2) context.go('/triage-checklist');
                },
              ),
              _buildNavItem(
                context,
                icon: Icons.local_hospital_outlined,
                activeIcon: Icons.local_hospital,
                label: lang.t('হাসপাতাল', 'Hospital'),
                isActive: currentIndex == 3,
                onTap: () {
                  if (currentIndex != 3) context.go('/hospital-radar');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          highlightColor: Colors.transparent,
          splashColor: AppColors.primary.withOpacity(0.06),
          customBorder: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Container with Active Pill Animation
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                width: 64,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive ? AppColors.primaryContainer : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  isActive ? activeIcon : icon,
                  color: isActive ? AppColors.onPrimaryContainer : AppColors.onSurfaceVariant,
                  size: 24,
                ),
              ),
              const SizedBox(height: 4),
              // Label
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? AppColors.primary : AppColors.onSurfaceVariant,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
