import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widgets/bottom_nav.dart';
import '../../../core/widgets/language_toggle.dart';
import '../providers/hospital_provider.dart';
import '../models/hospital.dart';

class HospitalRadarScreen extends ConsumerStatefulWidget {
  const HospitalRadarScreen({super.key});

  @override
  ConsumerState<HospitalRadarScreen> createState() => _HospitalRadarScreenState();
}

class _HospitalRadarScreenState extends ConsumerState<HospitalRadarScreen> {
  bool _isMapView = false;
  final MapController _mapController = MapController();
  final List<String> _selectedStockStatuses = ['in_stock', 'limited', 'out_of_stock'];
  final List<String> _selectedHospitalTypes = ['medical_college', 'district', 'upazila', 'general'];

  Future<void> _makeCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  Future<void> _openDirections(double lat, double lng) async {
    final Uri url = Uri.parse('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  void _moveToLocation(LatLng target) {
    _mapController.move(target, 13.0);
  }

  Future<void> _getCurrentLocationAndMove() async {
    await ref.read(hospitalProvider.notifier).fetchHospitals();
    final pos = ref.read(hospitalProvider).userPosition;
    if (pos != null) {
      _moveToLocation(LatLng(pos.latitude, pos.longitude));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalProvider);
    final rawFilteredHospitals = ref.read(hospitalProvider.notifier).getFilteredHospitals();
    final filteredHospitals = rawFilteredHospitals.where((h) {
      if (!_selectedStockStatuses.contains(h.antivenomStatus)) return false;
      if (!_selectedHospitalTypes.contains(h.type)) return false;
      return true;
    }).toList();

    final LatLng initialCenter = state.userPosition != null
        ? LatLng(state.userPosition!.latitude, state.userPosition!.longitude)
        : const LatLng(23.7258, 90.3975);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator(color: AppColors.primaryContainer))
                  : _buildContent(initialCenter, filteredHospitals, state),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryContainer,
        onPressed: _getCurrentLocationAndMove,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
      bottomNavigationBar: const VenomShieldBottomNav(currentIndex: 3),
    );
  }

  Widget _buildTopBar() {
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
              const SizedBox(width: 4),
              const Text(
                'VenomShield AI',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const BilingualLanguageToggle(),
        ],
      ),
    );
  }

  Widget _buildContent(LatLng initialCenter, List<Hospital> hospitals, HospitalState state) {
    return Column(
      children: [
        // Search and Filter
        _buildSearchFilter(state),
        // Main View
        Expanded(
          child: _isMapView
              ? _buildMapView(initialCenter, hospitals)
              : _buildListView(hospitals, state),
        ),
      ],
    );
  }

  Widget _buildSearchFilter(HospitalState state) {
    final lang = ref.watch(localeProvider);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
        ),
      ),
      child: Column(
        children: [
          // Search Bar
          TextField(
            onChanged: (val) => ref.read(hospitalProvider.notifier).updateSearchQuery(val),
            decoration: InputDecoration(
              hintText: lang.t('হাসপাতাল বা উপজেলা খুঁজুন...', 'Search hospitals or sub-districts...'),
              prefixIcon: const Icon(Icons.search, color: AppColors.onSurfaceVariant),
              filled: true,
              fillColor: AppColors.surface,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: AppColors.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(999),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          // Filter Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.t('শুধুমাত্র স্টক আছে এমন হাসপাতাল', 'Available stock only'),
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurface,
                ),
              ),
              Switch(
                value: state.filterInStockOnly,
                activeColor: AppColors.primaryContainer,
                onChanged: (val) {
                  ref.read(hospitalProvider.notifier).toggleFilterStock();
                },
              ),
            ],
          ),
          // View Toggle
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMapView = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: !_isMapView ? AppColors.primaryContainer : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: !_isMapView ? AppColors.primaryContainer : AppColors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.list,
                          size: 16,
                          color: !_isMapView ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lang.t('তালিকা', 'List'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: !_isMapView ? Colors.white : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isMapView = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: _isMapView ? AppColors.primaryContainer : AppColors.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isMapView ? AppColors.primaryContainer : AppColors.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.map,
                          size: 16,
                          color: _isMapView ? Colors.white : AppColors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          lang.t('ম্যাপ', 'Map'),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _isMapView ? Colors.white : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Hospital> hospitals, HospitalState state) {
    final lang = ref.watch(localeProvider);
    if (hospitals.isEmpty) {
      return Center(
        child: Text(
          lang.t('কোনো হাসপাতাল পাওয়া যায়নি।', 'No hospitals found.'),
          style: const TextStyle(color: AppColors.onSurfaceVariant),
        ),
      );
    }

    final userPos = state.userPosition;

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                lang.t('নিকটস্থ কেন্দ্রসমূহ', 'Nearest Centers'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onSurface,
                ),
              ),
              GestureDetector(
                onTap: () => _showFilterSheet(context, lang),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(Icons.filter_list, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      lang.t('ফিল্টার', 'Filter'),
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.08,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Hospital List
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: hospitals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final hospital = hospitals[index];
              final lang = ref.watch(localeProvider);
              String distStr = '';
              if (userPos != null) {
                final double distance = _dbHelperCalculateDistance(
                  userPos.latitude,
                  userPos.longitude,
                  hospital.lat,
                  hospital.lng,
                );
                distStr = lang.isBengali
                    ? '${_toBengaliDigits(distance.toStringAsFixed(1))} কিমি দূরে'
                    : '${distance.toStringAsFixed(1)} km away';
              }

              return _buildHospitalCard(hospital, distStr);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildHospitalCard(Hospital hospital, String distStr) {
    final lang = ref.watch(localeProvider);
    Color accentColor;
    switch (hospital.antivenomStatus) {
      case 'in_stock':
        accentColor = AppColors.primary;
        break;
      case 'limited':
        accentColor = const Color(0xFFEAB308);
        break;
      default:
        accentColor = AppColors.error;
    }

    return Container(
      decoration: BoxDecoration(
        color: hospital.antivenomStatus == 'out_of_stock'
            ? AppColors.surface
            : AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hospital.antivenomStatus == 'out_of_stock'
              ? AppColors.error.withOpacity(0.2)
              : AppColors.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Accent Bar
          Positioned(
            top: 0,
            left: 0,
            bottom: 0,
            width: 4,
            child: Container(
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            lang.t(hospital.nameBn, hospital.nameEn),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.onSurface,
                              decoration: hospital.antivenomStatus == 'out_of_stock'
                                  ? TextDecoration.lineThrough
                                  : null,
                              decorationColor: hospital.antivenomStatus == 'out_of_stock'
                                  ? AppColors.error.withOpacity(0.5)
                                  : null,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on, size: 14, color: AppColors.onSurfaceVariant),
                              const SizedBox(width: 4),
                              Text(
                                distStr.isNotEmpty ? '$distStr • ${hospital.upazila}' : hospital.upazila,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStockBadge(hospital.antivenomStatus),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => _openDirections(hospital.lat, hospital.lng),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.navigation, size: 16, color: Colors.white),
                              const SizedBox(width: 4),
                              Text(
                                lang.t('দিকনির্দেশনা', 'Directions'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    if (hospital.phone.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => _makeCall(hospital.phone),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.outlineVariant, width: 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.phone, size: 16, color: AppColors.primary),
                                const SizedBox(width: 4),
                                Text(
                                  lang.t('কল করুন', 'Call'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockBadge(String status) {
    final lang = ref.watch(localeProvider);
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'in_stock':
        bgColor = AppColors.primaryFixed;
        textColor = AppColors.primary;
        label = lang.t('স্টক আছে', 'In Stock');
        break;
      case 'limited':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFCA8A04);
        label = lang.t('সীমিত স্টক', 'Limited');
        break;
      default:
        bgColor = AppColors.errorContainer;
        textColor = AppColors.error;
        label = lang.t('স্টক নেই', 'No Stock');
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: textColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.08,
            ),
          ),
          if (status == 'in_stock')
            Text(
              lang.t('পলিভ্যালেন্ট এভিএস', 'Polyvalent AVS'),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: AppColors.primaryContainer,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMapView(LatLng center, List<Hospital> hospitals) {
    final markers = <Marker>[];

    final userPos = ref.read(hospitalProvider).userPosition;
    if (userPos != null) {
      markers.add(
        Marker(
          point: LatLng(userPos.latitude, userPos.longitude),
          width: 40,
          height: 40,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    for (var hospital in hospitals) {
      Color markerColor;
      switch (hospital.antivenomStatus) {
        case 'in_stock':
          markerColor = AppColors.primary;
          break;
        case 'limited':
          markerColor = const Color(0xFFEAB308);
          break;
        default:
          markerColor = AppColors.error;
      }

      markers.add(
        Marker(
          point: LatLng(hospital.lat, hospital.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showHospitalDetailsSheet(hospital),
            child: Container(
              decoration: BoxDecoration(
                color: markerColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: markerColor.withOpacity(0.4),
                    blurRadius: 15,
                  ),
                ],
              ),
              child: const Icon(
                Icons.vaccines,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      );
    }

    return Stack(
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 10.0,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.venomshield.venomshield',
            ),
            MarkerLayer(markers: markers),
          ],
        ),
        // Map Controls
        Positioned(
          top: 16,
          right: 16,
          child: Column(
            children: [
              _buildMapControl(Icons.my_location, _getCurrentLocationAndMove),
              const SizedBox(height: 8),
              _buildMapControl(Icons.layers, () {}),
            ],
          ),
        ),
        // Search Bar on Map
        Positioned(
          top: 16,
          left: 16,
          right: 72,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: AppColors.outlineVariant, width: 1),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: AppColors.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'খুঁজুন...',
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMapControl(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: AppColors.onSurface),
      ),
    );
  }

  void _showHospitalDetailsSheet(Hospital hospital) {
    final lang = ref.read(localeProvider);
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lang.t(hospital.nameBn, hospital.nameEn),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${hospital.upazila}, ${hospital.district}',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStockBadge(hospital.antivenomStatus),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (hospital.phone.isNotEmpty) ...[
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pop(context);
                          _makeCall(hospital.phone);
                        },
                        icon: const Icon(Icons.phone),
                        label: Text(lang.t('কল করুন', 'Call')),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _openDirections(hospital.lat, hospital.lng);
                      },
                      icon: const Icon(Icons.navigation),
                      label: Text(lang.t('দিকনির্দেশনা', 'Directions')),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  double _dbHelperCalculateDistance(double lat1, double lon1, double lat2, double lon2) {
    final double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }

  void _showFilterSheet(BuildContext context, AppLanguage lang) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        lang.t('ফিল্টার করুন', 'Filter Options'),
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  
                  Text(
                    lang.t('অ্যান্টি-ভেনম স্টক', 'Anti-venom Stock'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildFilterChip(
                        label: lang.t('স্টক আছে', 'In Stock'),
                        isSelected: _selectedStockStatuses.contains('in_stock'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStockStatuses.add('in_stock');
                            } else {
                              if (_selectedStockStatuses.length > 1) {
                                _selectedStockStatuses.remove('in_stock');
                              }
                            }
                          });
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: lang.t('সীমিত', 'Limited'),
                        isSelected: _selectedStockStatuses.contains('limited'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStockStatuses.add('limited');
                            } else {
                              if (_selectedStockStatuses.length > 1) {
                                _selectedStockStatuses.remove('limited');
                              }
                            }
                          });
                          setSheetState(() {});
                        },
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: lang.t('স্টক নেই', 'No Stock'),
                        isSelected: _selectedStockStatuses.contains('out_of_stock'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedStockStatuses.add('out_of_stock');
                            } else {
                              if (_selectedStockStatuses.length > 1) {
                                _selectedStockStatuses.remove('out_of_stock');
                              }
                            }
                          });
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text(
                    lang.t('হাসপাতালের ধরন', 'Hospital Type'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: lang.t('মেডিকেল কলেজ', 'Medical College'),
                        isSelected: _selectedHospitalTypes.contains('medical_college'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedHospitalTypes.add('medical_college');
                            } else {
                              if (_selectedHospitalTypes.length > 1) {
                                _selectedHospitalTypes.remove('medical_college');
                              }
                            }
                          });
                          setSheetState(() {});
                        },
                      ),
                      _buildFilterChip(
                        label: lang.t('জেলা সদর', 'District'),
                        isSelected: _selectedHospitalTypes.contains('district'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedHospitalTypes.add('district');
                            } else {
                              if (_selectedHospitalTypes.length > 1) {
                                _selectedHospitalTypes.remove('district');
                              }
                            }
                          });
                          setSheetState(() {});
                        },
                      ),
                      _buildFilterChip(
                        label: lang.t('উপজেলা স্বাস্থ্য', 'Upazila Health'),
                        isSelected: _selectedHospitalTypes.contains('upazila'),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedHospitalTypes.add('upazila');
                            } else {
                              if (_selectedHospitalTypes.length > 1) {
                                _selectedHospitalTypes.remove('upazila');
                              }
                            }
                          });
                          setSheetState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required ValueChanged<bool> onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: onSelected,
      selectedColor: AppColors.primary,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        color: isSelected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
    );
  }

  String _toBengaliDigits(String input) {
    const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
    const bengali = ['০', '১', '২', '৩', '৪', '৫', '৬', '৭', '৮', '৯'];
    String result = input;
    for (int i = 0; i < english.length; i++) {
      result = result.replaceAll(english[i], bengali[i]);
    }
    return result;
  }
}
