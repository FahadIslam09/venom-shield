import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(hospitalProvider);
    final filteredHospitals = ref.read(hospitalProvider.notifier).getFilteredHospitals();

    // Default position: Dhaka center
    final LatLng initialCenter = state.userPosition != null
        ? LatLng(state.userPosition!.latitude, state.userPosition!.longitude)
        : const LatLng(23.7258, 90.3975);

    return Scaffold(
      appBar: AppBar(
        title: const Text('অ্যান্টি-ভেনম রাডার ম্যাপ'),
        actions: [
          IconButton(
            icon: Icon(_isMapView ? Icons.list : Icons.map),
            onPressed: () {
              setState(() {
                _isMapView = !_isMapView;
              });
            },
          )
        ],
      ),
      body: Column(
        children: [
          // Filter & Search Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            color: Colors.white,
            child: Column(
              children: [
                // Search bar
                TextField(
                  onChanged: (val) => ref.read(hospitalProvider.notifier).updateSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'হাসপাতাল বা উপজেলা খুঁজুন...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 8),
                // Filter switch
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'শুধুমাত্র স্টক আছে এমন হাসপাতাল',
                      style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    ),
                    Switch(
                      value: state.filterInStockOnly,
                      activeColor: AppColors.primary,
                      onChanged: (val) {
                        ref.read(hospitalProvider.notifier).toggleFilterStock();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Main View (Map or List)
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _isMapView
                    ? _buildMapView(initialCenter, filteredHospitals)
                    : _buildListView(filteredHospitals),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => ref.read(hospitalProvider.notifier).fetchHospitals(),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }

  Widget _buildListView(List<Hospital> hospitals) {
    if (hospitals.isEmpty) {
      return const Center(
        child: Text('কোনো হাসপাতাল পাওয়া যায়নি।'),
      );
    }

    final userPos = ref.read(hospitalProvider).userPosition;

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: hospitals.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final hospital = hospitals[index];
        
        // Calculate distance display
        String distStr = '';
        if (userPos != null) {
          final double distance = _dbHelperCalculateDistance(
            userPos.latitude,
            userPos.longitude,
            hospital.lat,
            hospital.lng,
          );
          distStr = '${distance.toStringAsFixed(1)} কিমি দূরে';
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
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
                            hospital.nameBn,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${hospital.upazila}, ${hospital.district}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildStockBadge(hospital.antivenomStatus),
                  ],
                ),
                if (distStr.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    distStr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
                const Divider(height: 24),
                Row(
                  children: [
                    if (hospital.phone.isNotEmpty) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _makeCall(hospital.phone),
                          icon: const Icon(Icons.phone, size: 16),
                          label: const Text('কল করুন', style: TextStyle(fontSize: 13)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(38),
                            padding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openDirections(hospital.lat, hospital.lng),
                        icon: const Icon(Icons.navigation, size: 16),
                        label: const Text('দিকনির্দেশনা', style: TextStyle(fontSize: 13)),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(38),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMapView(LatLng center, List<Hospital> hospitals) {
    final markers = <Marker>[];

    // User location marker
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

    // Hospital markers
    for (var hospital in hospitals) {
      Color markerColor;
      switch (hospital.antivenomStatus) {
        case 'in_stock':
          markerColor = AppColors.safe;
          break;
        case 'limited':
          markerColor = AppColors.warning;
          break;
        default:
          markerColor = AppColors.danger;
      }

      markers.add(
        Marker(
          point: LatLng(hospital.lat, hospital.lng),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () => _showHospitalDetailsSheet(hospital),
            child: Icon(
              Icons.location_on,
              color: markerColor,
              size: 36,
            ),
          ),
        ),
      );
    }

    return FlutterMap(
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
    );
  }

  void _showHospitalDetailsSheet(Hospital hospital) {
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
                          hospital.nameBn,
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
                        label: const Text('কল করুন'),
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
                      label: const Text('দিকনির্দেশনা'),
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

  Widget _buildStockBadge(String status) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'in_stock':
        bg = AppColors.safe.withOpacity(0.1);
        text = AppColors.safe;
        label = 'স্টক আছে';
        break;
      case 'limited':
        bg = AppColors.warning.withOpacity(0.1);
        text = AppColors.warning;
        label = 'সীমিত স্টক';
        break;
      default:
        bg = AppColors.danger.withOpacity(0.1);
        text = AppColors.danger;
        label = 'স্টক নেই';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  double _dbHelperCalculateDistance(double lat1, double lon1, double lat2, double lon2) {
    // Simple copy of formula from database helper for UI distance displays
    final double p = 0.017453292519943295;
    final double a = 0.5 -
        math.cos((lat2 - lat1) * p) / 2 +
        math.cos(lat1 * p) * math.cos(lat2 * p) * (1 - math.cos((lon2 - lon1) * p)) / 2;
    return 12742 * math.asin(math.sqrt(a));
  }
}
