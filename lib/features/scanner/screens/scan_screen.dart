import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/app_colors.dart';
import '../providers/scanner_provider.dart';
import '../../triage/providers/triage_provider.dart';
import '../../../core/utils/connectivity_service.dart';

class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(scannerProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scannerProvider);
    final connectivity = ref.watch(connectivityProvider).value;

    // Watch for success and navigate
    ref.listen<ScannerState>(scannerProvider, (previous, next) {
      final result = next.result;
      if (result != null && !next.isScanning) {
        ref.read(triageProvider.notifier).submitImageResult(result);
        context.pushReplacement('/triage-result');
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('সাপের ছবি স্ক্যান'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (connectivity == ConnectionStatus.offline) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.wifi_off, color: AppColors.warning),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'আপনি বর্তমানে অফলাইন আছেন। অনলাইন এআই স্ক্যানের বদলে লক্ষণ তালিকা ব্যবহার করুন।',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.warning,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                // Image Box
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.border),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: state.imagePath != null
                        ? (kIsWeb
                            ? Image.network(
                                state.imagePath!,
                                fit: BoxFit.cover,
                              )
                            : Image.file(
                                File(state.imagePath!),
                                fit: BoxFit.cover,
                              ))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.photo_library_outlined,
                                size: 80,
                                color: AppColors.textSecondary.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'কোনো ছবি সিলেক্ট করা হয়নি',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'নিচের বোতামগুলো ব্যবহার করে ছবি তুলুন বা গ্যালারি থেকে যোগ করুন।',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),

                if (state.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.accentLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.error_outline, color: AppColors.accent),
                            SizedBox(width: 8),
                            Text(
                              'ত্রুটি!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.errorMessage!,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => context.pushReplacement('/triage-checklist'),
                          icon: const Icon(Icons.checklist, size: 16),
                          label: const Text('লক্ষণ তালিকা ব্যবহার করুন'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accent,
                            minimumSize: const Size.fromHeight(40),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => ref.read(scannerProvider.notifier).scanImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('ছবি তুলুন'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref.read(scannerProvider.notifier).scanImage(ImageSource.gallery),
                        icon: const Icon(Icons.image),
                        label: const Text('গ্যালারি'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),

                // Section for when user doesn't have a snake image
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'আমার কাছে সাপের ছবি নেই',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => context.pushReplacement('/bite-assessment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          minimumSize: const Size.fromHeight(40),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'কামড়ের স্থান ও লক্ষণ মূল্যায়ন করুন',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Loading Overlay
          if (state.isScanning)
            Container(
              color: Colors.black.withOpacity(0.7),
              child: const Center(
                child: Card(
                  margin: EdgeInsets.symmetric(horizontal: 48),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: AppColors.primary),
                        SizedBox(height: 24),
                        Text(
                          'এআই বিশ্লেষণ চলছে...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'সাপের প্রজাতি ও বিষাক্ততা যাচাই করা হচ্ছে। অনুগ্রহ করে অপেক্ষা করুন।',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
