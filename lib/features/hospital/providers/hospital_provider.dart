import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/database/database_helper.dart';
import '../models/hospital.dart';

class HospitalState {
  final bool isLoading;
  final List<Hospital> hospitals;
  final Position? userPosition;
  final String? errorMessage;
  final bool filterInStockOnly;
  final String searchQuery;

  HospitalState({
    this.isLoading = false,
    this.hospitals = const [],
    this.userPosition,
    this.errorMessage,
    this.filterInStockOnly = false,
    this.searchQuery = '',
  });

  HospitalState copyWith({
    bool? isLoading,
    List<Hospital>? hospitals,
    Position? userPosition,
    String? errorMessage,
    bool? filterInStockOnly,
    String? searchQuery,
  }) {
    return HospitalState(
      isLoading: isLoading ?? this.isLoading,
      hospitals: hospitals ?? this.hospitals,
      userPosition: userPosition ?? this.userPosition,
      errorMessage: errorMessage ?? this.errorMessage,
      filterInStockOnly: filterInStockOnly ?? this.filterInStockOnly,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class HospitalNotifier extends StateNotifier<HospitalState> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  HospitalNotifier() : super(HospitalState());

  Future<void> fetchHospitals() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Get user position with timeout fallback
      Position? position;
      try {
        position = await _determinePosition();
      } catch (e) {
        print('GPS failed, using fallback: $e');
        // Default position: Dhaka center
        position = Position(
          latitude: 23.7258,
          longitude: 90.3975,
          timestamp: DateTime.now(),
          accuracy: 0.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );
      }

      final nearest = await _dbHelper.getNearestHospitals(
        position.latitude,
        position.longitude,
        limit: 50,
      );

      state = state.copyWith(
        isLoading: false,
        hospitals: nearest,
        userPosition: position,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'হাসপাতালের তালিকা লোড করতে সমস্যা হয়েছে: $e',
      );
    }
  }

  void toggleFilterStock() {
    state = state.copyWith(filterInStockOnly: !state.filterInStockOnly);
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  List<Hospital> getFilteredHospitals() {
    return state.hospitals.where((h) {
      final matchesSearch = h.nameBn.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          h.nameEn.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          h.district.toLowerCase().contains(state.searchQuery.toLowerCase()) ||
          h.upazila.toLowerCase().contains(state.searchQuery.toLowerCase());
      
      if (!matchesSearch) return false;
      
      if (state.filterInStockOnly) {
        return h.antivenomStatus == 'in_stock' || h.antivenomStatus == 'limited';
      }
      
      return true;
    }).toList();
  }

  Future<Position> _determinePosition() async {
    if (kIsWeb) {
      return Future.error('Location services are not supported on web platforms.');
    }

    bool serviceEnabled;
    LocationPermission permission;

    // 1. Check and request location permission first to ensure user gets prompted on startup
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    } 

    // 2. Test if location services (GPS hardware toggle) are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
      timeLimit: const Duration(seconds: 5),
    );
  }
}

final hospitalProvider = StateNotifierProvider<HospitalNotifier, HospitalState>((ref) {
  final notifier = HospitalNotifier();
  notifier.fetchHospitals();
  return notifier;
});
