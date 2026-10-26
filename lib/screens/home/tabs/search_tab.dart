import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/vehicle_model.dart';

class SearchContent extends StatefulWidget {
  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle> onVehicleTap;

  const SearchContent({
    super.key,
    required this.vehicles,
    required this.onVehicleTap,
  });

  @override
  State<SearchContent> createState() => _SearchContentState();
}

class _SearchContentState extends State<SearchContent> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Vehicle> get _filteredVehicles {
    if (_query.trim().isEmpty) {
      return widget.vehicles;
    }

    final String q = _query.toLowerCase();

    return widget.vehicles.where((vehicle) {
      return vehicle.name.toLowerCase().contains(q) ||
          vehicle.plate.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cari',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Cari kendaraan atau lokasi yang ingin kamu pantau.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
          ),

          const SizedBox(height: 20),

          // SEARCH BAR
          TextField(
            controller: _searchController,
            onChanged: (value) {
              setState(() {
                _query = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Cari kendaraan, lokasi...',
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: AppColors.primary,
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _query = '';
                  });
                },
                icon: const Icon(Icons.clear_rounded, color: AppColors.primary),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // FILTER
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _filterButton(
                  icon: Icons.directions_car_rounded,
                  title: 'Kendaraan',
                  active: true,
                ),
                const SizedBox(width: 10),
                _filterButton(
                  icon: Icons.location_on_rounded,
                  title: 'Lokasi',
                  active: false,
                ),
                const SizedBox(width: 10),
                _filterButton(
                  icon: Icons.route_rounded,
                  title: 'Aktivitas',
                  active: false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Kendaraan Saya',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          if (_filteredVehicles.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                children: [
                  Icon(Icons.search_off_rounded, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text(
                    'Kendaraan tidak ditemukan',
                    style: TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

          ..._filteredVehicles.map(
            (vehicle) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _vehicleCard(
                icon: vehicle.isMotor
                    ? Icons.two_wheeler_rounded
                    : Icons.directions_car_rounded,
                name: vehicle.name,
                plate: vehicle.plate,
                status: 'Terhubung',
                statusColor: Colors.green,
                onTap: () => widget.onVehicleTap(vehicle),
              ),
            ),
          ),

          const SizedBox(height: 25),

          const Text(
            'Pencarian Terakhir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          _recentSearch(
            icon: Icons.location_on_outlined,
            title: 'Jl. Kaliurang',
            subtitle: 'Lokasi',
          ),

          _recentSearch(
            icon: Icons.location_on_outlined,
            title: 'Kampus UTY',
            subtitle: 'Lokasi',
          ),

          _recentSearch(
            icon: Icons.two_wheeler_outlined,
            title: 'Honda Vario 160',
            subtitle: 'Kendaraan',
          ),

          const SizedBox(height: 25),

          const Text(
            'Lokasi Favorit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _favoriteLocation(
                  icon: Icons.home_rounded,
                  title: 'Rumah',
                  location: 'Yogyakarta',
                ),
                const Divider(),
                _favoriteLocation(
                  icon: Icons.school_rounded,
                  title: 'Kampus',
                  location: 'Universitas Teknologi Yogyakarta',
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _filterButton({
    required IconData icon,
    required String title,
    required bool active,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: active ? AppColors.primary : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: active ? Colors.white : AppColors.primary,
          ),
          const SizedBox(width: 7),
          Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleCard({
    required IconData icon,
    required String name,
    required String plate,
    required String status,
    required Color statusColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppColors.primary, size: 29),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    plate,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(Icons.circle, size: 8, color: statusColor),
                      const SizedBox(width: 5),
                      Text(
                        status,
                        style: TextStyle(fontSize: 11, color: statusColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _recentSearch({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.north_west_rounded, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  Widget _favoriteLocation({
    required IconData icon,
    required String title,
    required String location,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  location,
                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                ),
              ],
            ),
          ),
          const Icon(Icons.star_rounded, color: Colors.orange, size: 21),
        ],
      ),
    );
  }
}
