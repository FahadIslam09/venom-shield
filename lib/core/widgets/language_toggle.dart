import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_colors.dart';
import '../providers/locale_provider.dart';

class BilingualLanguageToggle extends ConsumerWidget {
  const BilingualLanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(localeProvider);
    final isEn = language == AppLanguage.english;

    return GestureDetector(
      onTap: () => ref.read(localeProvider.notifier).toggleLanguage(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'ENG',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isEn ? FontWeight.w900 : FontWeight.w500,
                color: isEn ? AppColors.primary : AppColors.onSurfaceVariant,
                letterSpacing: 0.08,
              ),
            ),
            Container(
              width: 1,
              height: 12,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: AppColors.outlineVariant,
            ),
            Text(
              'BN',
              style: TextStyle(
                fontSize: 11,
                fontWeight: !isEn ? FontWeight.w900 : FontWeight.w500,
                color: !isEn ? AppColors.primary : AppColors.onSurfaceVariant,
                letterSpacing: 0.08,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
