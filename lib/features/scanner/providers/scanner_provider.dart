import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../models/scan_result.dart';
import '../services/ai_service.dart';

class ScannerState {
  final bool isScanning;
  final ScanResult? result;
  final String? errorMessage;
  final String? base64Image;
  final String? imagePath;

  ScannerState({
    this.isScanning = false,
    this.result,
    this.errorMessage,
    this.base64Image,
    this.imagePath,
  });

  ScannerState copyWith({
    bool? isScanning,
    ScanResult? result,
    String? errorMessage,
    String? base64Image,
    String? imagePath,
  }) {
    return ScannerState(
      isScanning: isScanning ?? this.isScanning,
      result: result ?? this.result,
      errorMessage: errorMessage ?? this.errorMessage,
      base64Image: base64Image ?? this.base64Image,
      imagePath: imagePath ?? this.imagePath,
    );
  }
}

class ScannerNotifier extends StateNotifier<ScannerState> {
  final AiService _aiService = AiService();
  final ImagePicker _picker = ImagePicker();

  ScannerNotifier() : super(ScannerState());

  void clear() {
    state = ScannerState();
  }

  Future<void> scanImage(ImageSource source) async {
    state = state.copyWith(isScanning: true, errorMessage: null, result: null);

    try {
      XFile? image;
      try {
        image = await _picker.pickImage(
          source: source,
          maxWidth: 800,
          maxHeight: 800,
          imageQuality: 85,
        );
      } catch (cameraErr) {
        // Fallback to gallery if camera hardware / browser permission fails
        if (source == ImageSource.camera) {
          image = await _picker.pickImage(
            source: ImageSource.gallery,
            maxWidth: 800,
            maxHeight: 800,
            imageQuality: 85,
          );
        } else {
          rethrow;
        }
      }

      if (image == null) {
        state = state.copyWith(isScanning: false);
        return;
      }

      final bytes = await image.readAsBytes();
      final base64Image = base64Encode(bytes);

      state = state.copyWith(
        base64Image: base64Image,
        imagePath: image.path,
      );

      final result = await _aiService.scanImage(base64Image);

      if (result == null) {
        state = state.copyWith(
          isScanning: false,
          errorMessage: 'সার্ভার সংযোগে ত্রুটি ঘটেছে। দয়া করে নিচের লক্ষণ ও তালিকা পূরণ করুন।',
        );
      } else {
        state = state.copyWith(
          isScanning: false,
          result: result,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        errorMessage: 'ছবি প্রসেস করতে ত্রুটি হয়েছে: $e',
      );
    }
  }
}

final scannerProvider = StateNotifierProvider<ScannerNotifier, ScannerState>((ref) {
  return ScannerNotifier();
});
