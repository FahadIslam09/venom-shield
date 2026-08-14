import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../providers/scanner_provider.dart';
import '../models/scan_result.dart';
import '../../triage/providers/triage_provider.dart';
import '../../../core/utils/connectivity_service.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    Future.microtask(() {
      ref.read(scannerProvider.notifier).clear();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerProvider);
    final connectivity = ref.watch(connectivityProvider).value;
    final lang = ref.watch(localeProvider);

    ref.listen<ScannerState>(scannerProvider, (previous, next) {
      final result = next.result;
      if (result != null && !next.isScanning) {
        if (result.status == 'identified') {
          ref.read(triageProvider.notifier).submitImageResult(result);
          context.pushReplacement('/triage-result');
        }
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(connectivity, lang),
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Viewfinder Area
                        Expanded(
                          child: _buildViewfinder(state, lang),
                        ),
                        const SizedBox(height: 8),
                        // Controls
                        _buildControls(state, lang),
                        const SizedBox(height: 16),
                        // Manual Entry Hook
                        _buildManualEntryHook(lang),
                      ],
                    ),
                  ),
                  // Loading Overlay
                  if (state.isScanning) _buildLoadingOverlay(lang),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const VenomShieldBottomNav(currentIndex: 1),
    );
  }

  Widget _buildTopBar(ConnectionStatus? connectivity, AppLanguage lang) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.primary),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
              const SizedBox(width: 8),
              Text(
                lang.t('সাপের স্ক্যানার', 'Snake Scanner'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.outlineVariant, width: 1),
            ),
            child: Row(
              children: [
                Icon(
                  connectivity == ConnectionStatus.offline ? Icons.wifi_off : Icons.wifi,
                  size: 14,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  connectivity == ConnectionStatus.offline 
                      ? lang.t('অফলাইন', 'Offline') 
                      : lang.t('অনলাইন', 'Online'),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.05,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewfinder(ScannerState state, AppLanguage lang) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Image or Empty State
          state.imagePath != null
              ? (kIsWeb
                  ? Image.network(state.imagePath!, fit: BoxFit.cover, width: double.infinity)
                  : Image.file(File(state.imagePath!), fit: BoxFit.cover, width: double.infinity))
              : _buildEmptyState(lang),
          // Corner Brackets (viewfinder)
          if (state.imagePath == null) ...[
            _buildCorner(Alignment.topLeft, isTop: true, isLeft: true),
            _buildCorner(Alignment.topRight, isTop: true, isLeft: false),
            _buildCorner(Alignment.bottomLeft, isTop: false, isLeft: true),
            _buildCorner(Alignment.bottomRight, isTop: false, isLeft: false),
          ],
          // Metrics Overlay
          if (state.imagePath == null) _buildMetricsOverlay(),
          // Error State
          if (state.errorMessage != null) _buildErrorOverlay(state, lang),
          // Validation Overlay
          if (state.result != null && state.result!.status != 'identified')
            _buildValidationOverlay(state.result!, lang),
        ],
      ),
    );
  }

  Widget _buildEmptyState(AppLanguage lang) {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Opacity(
            opacity: 0.5 + (_pulseController.value * 0.3),
            child: child,
          );
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.center_focus_strong,
              size: 64,
              color: AppColors.outlineVariant,
            ),
            const SizedBox(height: 16),
            Text(
              lang.t('কোনো ছবি সিলেক্ট করা হয়নি', 'No image selected'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              lang.t('সাপের প্রজাতি শনাক্ত করতে একটি পরিষ্কার ছবি আপলোড করুন', 'Upload a clear photo to identify the snake species'),
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCorner(Alignment alignment, {required bool isTop, required bool isLeft}) {
    return Positioned(
      top: isTop ? 24 : null,
      bottom: isTop ? null : 24,
      left: isLeft ? 24 : null,
      right: isLeft ? null : 24,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          border: Border(
            top: isTop ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            bottom: isTop ? BorderSide.none : const BorderSide(color: AppColors.primary, width: 4),
            left: isLeft ? const BorderSide(color: AppColors.primary, width: 4) : BorderSide.none,
            right: isLeft ? BorderSide.none : const BorderSide(color: AppColors.primary, width: 4),
          ),
          borderRadius: BorderRadius.only(
            topLeft: isTop && isLeft ? const Radius.circular(8) : Radius.zero,
            topRight: isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
            bottomLeft: !isTop && isLeft ? const Radius.circular(8) : Radius.zero,
            bottomRight: !isTop && !isLeft ? const Radius.circular(8) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildMetricsOverlay() {
    return Positioned(
      top: 16,
      left: 16,
      right: 16,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildMetricPill(Icons.flare, 'ISO Auto'),
          _buildMetricPill(Icons.hdr_auto, 'AI Active'),
        ],
      ),
    );
  }

  Widget _buildMetricPill(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface.withOpacity(0.8),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.outlineVariant, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.onSurface,
              letterSpacing: 0.05,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorOverlay(ScannerState state, AppLanguage lang) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.errorContainer,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.error.withOpacity(0.2), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 20),
                const SizedBox(width: 8),
                Text(
                  lang.t('ত্রুটি!', 'Error!'),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              state.errorMessage!,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.onErrorContainer,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => context.pushReplacement('/triage-checklist'),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  lang.t('লক্ষণ তালিকা ব্যবহার করুন', 'Use Symptom Checklist'),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationOverlay(ScanResult result, AppLanguage lang) {
    final bool isUnidentified = result.status == 'unidentified';
    
    // Choose appropriate color theme: warning (yellow/amber) for not_detected, error (red/tertiary) for unidentified
    final themeColor = isUnidentified ? AppColors.error : const Color(0xFFD97706); // Warm Amber
    final containerBg = isUnidentified ? AppColors.errorContainer : const Color(0xFFFEF3C7); // Light Amber
    
    final title = isUnidentified 
        ? lang.t('শনাক্তকরণ অসম্পূর্ণ', 'Identification Incomplete')
        : lang.t('সাপ শনাক্ত করা যায়নি', 'No Snake Detected');
        
    final description = isUnidentified
        ? lang.t(
            result.descriptionBn.isNotEmpty ? result.descriptionBn : 'ছবিতে সাপ দেখা যাচ্ছে, তবে এর প্রজাতি নিশ্চিতভাবে চিহ্নিত করা যাচ্ছে না। নিরাপত্তার জন্য সতর্কতা অবলম্বন করুন।',
            result.descriptionEn.isNotEmpty ? result.descriptionEn : 'A snake is visible, but its species cannot be identified with certainty. Please proceed with caution.'
          )
        : lang.t(
            result.descriptionBn.isNotEmpty ? result.descriptionBn : 'ছবিতে কোনো সাপ শনাক্ত করা যায়নি। এটি কোনো খাবার, হাত, ল্যান্ডস্কেপ বা অন্য বস্তুর ছবি হতে পারে।',
            result.descriptionEn.isNotEmpty ? result.descriptionEn : 'No snake could be detected in this image. It appears to be food, a hand, a landscape, or another unrelated object.'
          );

    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.65), // Smooth translucent background
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outlineVariant, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top Icon / Status Indicator
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: containerBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isUnidentified ? Icons.warning_amber_rounded : Icons.find_in_page_outlined,
                    color: themeColor,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                // Title
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                // Detailed explanation block
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.outlineVariant.withOpacity(0.5), width: 1),
                  ),
                  child: Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 20),
                // Action Buttons
                Row(
                  children: [
                    // Retry Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          ref.read(scannerProvider.notifier).clear();
                        },
                        icon: const Icon(Icons.refresh, size: 14, color: AppColors.primary),
                        label: Text(
                          lang.t('আবার চেষ্টা', 'Retry'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Checklist Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ref.read(scannerProvider.notifier).clear();
                          context.pushReplacement('/triage-checklist');
                        },
                        icon: const Icon(Icons.checklist, size: 14, color: Colors.white),
                        label: Text(
                          lang.t('লক্ষণ তালিকা', 'Checklist'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryContainer,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(ScannerState state, AppLanguage lang) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Gallery Button
        _buildSecondaryButton(
          icon: Icons.photo_library,
          label: lang.t('গ্যালারি', 'Gallery'),
          onTap: () => ref.read(scannerProvider.notifier).scanImage(ImageSource.gallery),
        ),
        const SizedBox(width: 24),
        // Capture Button
        _buildCaptureButton(
          onTap: () => ref.read(scannerProvider.notifier).scanImage(ImageSource.camera),
        ),
        const SizedBox(width: 24),
        // Flash Button
        _buildSecondaryButton(
          icon: Icons.flash_auto,
          label: lang.t('ফ্ল্যাশ', 'Flash'),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSecondaryButton({required IconData icon, required String label, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.outlineVariant, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Icon(icon, color: AppColors.onSurfaceVariant, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.onSurfaceVariant,
              letterSpacing: 0.08,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureButton({required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 96,
        decoration: BoxDecoration(
          color: AppColors.primaryContainer,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.primary, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.photo_camera, color: AppColors.primary, size: 24),
        ),
      ),
    );
  }

  Widget _buildManualEntryHook(AppLanguage lang) {
    return GestureDetector(
      onTap: () => context.pushReplacement('/bite-assessment'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.secondaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: const Icon(Icons.keyboard, color: AppColors.onSecondaryContainer, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('আমার কাছে সাপের ছবি নেই', 'I do not have a snake photo'),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.onSurface,
                      letterSpacing: 0.08,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang.t('কামড়ের স্থান ও লক্ষণ মূল্যায়ন করুন', 'Assess bite site and symptoms'),
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingOverlay(AppLanguage lang) {
    return Container(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.outlineVariant, width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(color: AppColors.primaryContainer),
              const SizedBox(height: 24),
              Text(
                lang.t('এআই বিশ্লেষণ চলছে...', 'AI Analysis in Progress...'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                lang.t(
                  'সাপের প্রজাতি ও বিষাক্ততা যাচাই করা হচ্ছে। অনুগ্রহ করে অপেক্ষা করুন।', 
                  'Verifying snake species and toxicity. Please wait.'
                ),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
