import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../core/constants/app_colors.dart';
import '../../models/vehicle_model.dart';
import '../../services/api_service.dart';

class TrackingPage extends StatefulWidget {
  final Vehicle vehicle;

  const TrackingPage({super.key, required this.vehicle});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  static const LatLng jogjaDefault = LatLng(-7.7956, 110.3695);
  late final MapController _mapController;

  List<LatLng> _route = [];
  bool _isLoading = false;
  String _currentAddress = 'Yogyakarta, Indonesia';

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // Inisialisasi posisi terakhir dari data kendaraan jika tersedia
    if (widget.vehicle.lastPosition != null) {
      final lat = (widget.vehicle.lastPosition!['lat'] as num?)?.toDouble();
      final lng = (widget.vehicle.lastPosition!['lng'] as num?)?.toDouble();
      if (lat != null && lng != null) {
        _route = [LatLng(lat, lng)];
        if (widget.vehicle.lastPosition!['address'] != null) {
          _currentAddress = widget.vehicle.lastPosition!['address'].toString();
        }
      }
    }

    _fetchLiveTracking();
  }

  Future<void> _fetchLiveTracking() async {
    if (widget.vehicle.id == null) return;
    setState(() => _isLoading = true);
    try {
      final history = await ApiService.getPositionHistory(widget.vehicle.id!);
      if (mounted) {
        if (history.isNotEmpty) {
          final List<LatLng> fetchedPoints = history.map((p) {
            final lat = (p['lat'] as num).toDouble();
            final lng = (p['lng'] as num).toDouble();
            return LatLng(lat, lng);
          }).toList();

          setState(() {
            _route = fetchedPoints;
            final last = history.last;
            if (last['address'] != null && last['address'].toString().isNotEmpty) {
              _currentAddress = last['address'].toString();
            }
          });

          // Center map to latest position
          if (_route.isNotEmpty) {
            _mapController.move(_route.last, 14.5);
          }
        }
      }
    } catch (e) {
      debugPrint('Error fetching tracking data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng latestPoint = _route.isNotEmpty ? _route.last : jogjaDefault;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: Text(
          'Lacak ${widget.vehicle.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.refresh_rounded),
            tooltip: 'Perbarui Posisi GPS',
            onPressed: _isLoading ? null : _fetchLiveTracking,
          ),
        ],
      ),

      body: Stack(
        children: [
          // Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: latestPoint,
              initialZoom: 14.0,
            ),
            children: [
              // OPEN STREET MAP
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gps_tracker',
              ),

              // JALUR RUTE GPS
              if (_route.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _route,
                      strokeWidth: 5,
                      color: AppColors.primary,
                    ),
                  ],
                ),

              // MARKER KENDARAAN (POSISI TERAKHIR)
              MarkerLayer(
                markers: [
                  Marker(
                    point: latestPoint,
                    width: 150,
                    height: 90,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.18),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            widget.vehicle.name,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Container(
                          width: 44,
                          height: 44,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.vehicle.isMotor
                                ? Icons.two_wheeler_rounded
                                : Icons.directions_car_rounded,
                            color: Colors.white,
                            size: 25,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // ATRIBUT OSM
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),

          // PEMBERITAHUAN EMPTY STATE KETIKA BELUM ADA KOORDINAT TERCATAT
          if (_route.isEmpty && !_isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(color: Colors.orange.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: Colors.orange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Belum ada koordinat rute GPS tersimpan untuk ${widget.vehicle.name}. Menampilkan peta referensi Yogyakarta.',
                        style: const TextStyle(fontSize: 12, color: AppColors.textPrimary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Informasi kendaraan di bawah peta
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      widget.vehicle.isMotor
                          ? Icons.two_wheeler_rounded
                          : Icons.directions_car_rounded,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.vehicle.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.textPrimary,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          widget.vehicle.plate,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 5),

                        Row(
                          children: [
                            const Text(
                              '● Terhubung ',
                              style: TextStyle(
                                color: AppColors.success,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Expanded(
                              child: Text(
                                '• $_currentAddress',
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
