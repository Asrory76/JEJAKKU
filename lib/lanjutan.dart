import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

// ======================================================
// MODEL KENDARAAN
// ======================================================

class Vehicle {
  final String name;
  final String plate;
  final bool isMotor;

  const Vehicle({
    required this.name,
    required this.plate,
    required this.isMotor,
  });
}

// ======================================================
// HOME PAGE
// ======================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Vehicle> _vehicles = [
    const Vehicle(name: 'Honda Vario 160', plate: 'AB 1234 XY', isMotor: true),
    const Vehicle(name: 'Toyota Avanza', plate: 'AB 5678 CD', isMotor: false),
  ];

  void _addVehicle(Vehicle vehicle) {
    setState(() {
      _vehicles.add(vehicle);
    });
  }

  void _openTracking(Vehicle vehicle) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TrackingPage(vehicle: vehicle)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 214, 213, 213),

      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // HEADER
            // ======================================================

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF087789),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(15),
                  bottomRight: Radius.circular(15),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 45,
                    height: 45,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.two_wheeler_rounded,
                      color: Color(0xFF087789),
                      size: 27,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Text(
                    'JEJAKKU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // ======================================================
            // ISI HALAMAN
            // ======================================================
            Expanded(
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  HomeContent(
                    vehicle: _vehicles.first,
                    onTrack: () => _openTracking(_vehicles.first),
                  ),

                  SearchContent(
                    vehicles: _vehicles,
                    onVehicleTap: _openTracking,
                  ),

                  AccountContent(
                    vehicles: _vehicles,
                    onAddVehicle: _addVehicle,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // ======================================================
      // BOTTOM NAVIGATION
      // ======================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: const Color(0xFF087789),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Akun',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// HALAMAN HOME
// ======================================================

class HomeContent extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onTrack;

  const HomeContent({super.key, required this.vehicle, required this.onTrack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang 👋',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Pantau kendaraanmu dengan mudah.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // STATUS KENDARAAN
          // ======================================================
          GestureDetector(
            onTap: onTrack,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF087789),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 55,
                    height: 55,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      vehicle.isMotor
                          ? Icons.two_wheeler_rounded
                          : Icons.directions_car_rounded,
                      color: const Color(0xFF087789),
                      size: 32,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Row(
                          children: [
                            Icon(
                              Icons.circle,
                              color: Colors.greenAccent,
                              size: 10,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Terhubung',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // INFORMASI KENDARAAN
          // ======================================================
          const Text(
            'Informasi Kendaraan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.speed_rounded,
                        color: Color(0xFF087789),
                        size: 28,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '12.450 KM',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Odometer',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.battery_5_bar_rounded,
                        color: Colors.green,
                        size: 28,
                      ),
                      SizedBox(height: 10),
                      Text(
                        '86%',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Baterai',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ======================================================
          // LOKASI TERAKHIR
          // ======================================================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F4F6),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF087789),
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lokasi Terakhir',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Jl. Kaliurang, Yogyakarta',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                      SizedBox(height: 3),
                      Text(
                        '2 menit yang lalu',
                        style: TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ======================================================
          // TOMBOL LACAK
          // ======================================================
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: onTrack,
              icon: const Icon(Icons.location_searching_rounded),
              label: const Text(
                'Lacak Kendaraan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087789),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // SERVIS
          // ======================================================
          const Text(
            'Pengingat Servis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF3DC),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.build_rounded,
                    color: Colors.orange,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Servis berikutnya',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        '550 KM lagi',
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Pada 13.000 KM',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ======================================================
          // AKTIVITAS
          // ======================================================
          const Text(
            'Aktivitas Terakhir',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.route_rounded, color: Color(0xFF087789)),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Perjalanan selesai',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Text(
                      '10:42',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),

                SizedBox(height: 15),

                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: Colors.grey),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Kendaraan berhenti di Jl. Kaliurang',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

// ======================================================
// HALAMAN TRACKING
// ======================================================

class TrackingPage extends StatelessWidget {
  final Vehicle vehicle;

  const TrackingPage({super.key, required this.vehicle});

  static const LatLng jogja = LatLng(-7.7956, 110.3695);

  @override
  Widget build(BuildContext context) {
    final List<LatLng> route = [
      const LatLng(-7.7819, 110.3671),
      const LatLng(-7.7859, 110.3682),
      const LatLng(-7.7904, 110.3691),
      const LatLng(-7.7956, 110.3695),
      const LatLng(-7.8008, 110.3704),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF087789),
        foregroundColor: Colors.white,
        title: const Text(
          'Lacak Kendaraan',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      body: Stack(
        children: [
          // ======================================================
          // MAP
          // ======================================================

          FlutterMap(
            options: const MapOptions(initialCenter: jogja, initialZoom: 13.5),

            children: [
              // OPEN STREET MAP
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.gps_tracker',
              ),

              // JALUR SIMULASI
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: route,
                    strokeWidth: 5,
                    color: const Color(0xFF087789),
                  ),
                ],
              ),

              // MARKER KENDARAAN
              MarkerLayer(
                markers: [
                  Marker(
                    point: route.last,
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
                                color: Colors.black.withOpacity(0.18),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Text(
                            vehicle.name,
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
                            color: Color(0xFF087789),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            vehicle.isMotor
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

          // ======================================================
          // INFORMASI KENDARAAN DI BAWAH MAP
          // ======================================================
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
                    color: Colors.black.withOpacity(0.15),
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
                      color: const Color(0xFFE8F4F6),
                      borderRadius: BorderRadius.circular(13),
                    ),
                    child: Icon(
                      vehicle.isMotor
                          ? Icons.two_wheeler_rounded
                          : Icons.directions_car_rounded,
                      color: const Color(0xFF087789),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vehicle.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 3),

                        Text(
                          vehicle.plate,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Text(
                          '● GPS Terhubung • Simulasi Yogyakarta',
                          style: TextStyle(color: Colors.green, fontSize: 11),
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

// ======================================================
// HALAMAN SEARCH
// ======================================================

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
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 5),

          const Text(
            'Cari kendaraan atau lokasi yang ingin kamu pantau.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
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
                color: Color(0xFF087789),
              ),
              suffixIcon: IconButton(
                onPressed: () {
                  _searchController.clear();

                  setState(() {
                    _query = '';
                  });
                },
                icon: const Icon(Icons.clear_rounded, color: Color(0xFF087789)),
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
              color: Color(0xFF172033),
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
              color: Color(0xFF172033),
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
              color: Color(0xFF172033),
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
        color: active ? const Color(0xFF087789) : Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: active ? Colors.white : const Color(0xFF087789),
          ),

          const SizedBox(width: 7),

          Text(
            title,
            style: TextStyle(
              color: active ? Colors.white : const Color(0xFF172033),
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
                color: const Color(0xFFE8F4F6),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: const Color(0xFF087789), size: 29),
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
              color: const Color(0xFFE8F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF087789)),
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

// ======================================================
// HALAMAN AKUN
// ======================================================

class AccountContent extends StatelessWidget {
  final List<Vehicle> vehicles;
  final ValueChanged<Vehicle> onAddVehicle;

  const AccountContent({
    super.key,
    required this.vehicles,
    required this.onAddVehicle,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PROFILE
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              children: [
                Container(
                  width: 65,
                  height: 65,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F4F6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF087789),
                    size: 38,
                  ),
                ),

                const SizedBox(width: 15),

                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arya Cahyo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      SizedBox(height: 5),

                      Text(
                        'Pengguna GPS Tracker',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.edit_outlined, color: Color(0xFF087789)),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ARMADA
          const Text(
            'Armada Saya',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
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
                ...vehicles.asMap().entries.map((entry) {
                  final Vehicle vehicle = entry.value;

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key == vehicles.length - 1 ? 0 : 12,
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TrackingPage(vehicle: vehicle),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Row(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F4F6),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              vehicle.isMotor
                                  ? Icons.two_wheeler_rounded
                                  : Icons.directions_car_rounded,
                              color: const Color(0xFF087789),
                              size: 28,
                            ),
                          ),

                          const SizedBox(width: 13),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  vehicle.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                Text(
                                  vehicle.plate,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 4),

                                const Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 8,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      'GPS Terhubung',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 15),

                // TAMBAH ARMADA
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showAddVehicleDialog(context);
                    },
                    icon: const Icon(
                      Icons.add_rounded,
                      color: Color(0xFF087789),
                    ),
                    label: const Text(
                      'Tambah Armada',
                      style: TextStyle(
                        color: Color(0xFF087789),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF087789)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(13),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // PENGATURAN
          const Text(
            'Pengaturan',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF172033),
            ),
          ),

          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                _accountMenu(
                  icon: Icons.build_outlined,
                  title: 'Jadwal Servis',
                  subtitle: 'Atur pengingat servis kendaraan',
                  onTap: () {
                    _showMessage(
                      context,
                      'Fitur Jadwal Servis belum diaktifkan.',
                    );
                  },
                ),

                const Divider(height: 1, indent: 70),

                _accountMenu(
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  subtitle: 'Atur pemberitahuan aplikasi',
                  onTap: () {
                    _showMessage(context, 'Fitur Notifikasi belum diaktifkan.');
                  },
                ),

                const Divider(height: 1, indent: 70),

                _accountMenu(
                  icon: Icons.lock_outline_rounded,
                  title: 'Keamanan',
                  subtitle: 'Password dan keamanan akun',
                  onTap: () {
                    _showMessage(context, 'Fitur Keamanan belum diaktifkan.');
                  },
                ),

                const Divider(height: 1, indent: 70),

                _accountMenu(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Informasi GPS Tracker',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'GPS Tracker',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.two_wheeler_rounded,
                        color: Color(0xFF087789),
                        size: 40,
                      ),
                      children: const [
                        Text(
                          'Aplikasi untuk memantau kendaraan '
                          'menggunakan GPS Tracker.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // LOGOUT
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout_rounded, color: Colors.red),
              label: const Text(
                'Keluar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _accountMenu({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      leading: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F4F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: const Color(0xFF087789)),
      ),

      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),

      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 11, color: Colors.grey),
      ),

      trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),

      onTap: onTap,
    );
  }

  void _showAddVehicleDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();

    final TextEditingController plateController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Tambah Armada',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Masukkan informasi kendaraan yang ingin dipantau.',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),

              const SizedBox(height: 18),

              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Nama Kendaraan',
                  hintText: 'Contoh: Honda Vario 160',
                  prefixIcon: const Icon(Icons.two_wheeler_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              TextField(
                controller: plateController,
                decoration: InputDecoration(
                  labelText: 'Nomor Kendaraan',
                  hintText: 'Contoh: AB 1234 XY',
                  prefixIcon: const Icon(Icons.confirmation_number_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),

          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Batal', style: TextStyle(color: Colors.grey)),
            ),

            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    plateController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Nama dan nomor kendaraan wajib diisi.'),
                    ),
                  );
                  return;
                }

                final Vehicle newVehicle = Vehicle(
                  name: nameController.text.trim(),
                  plate: plateController.text.trim(),
                  isMotor: true,
                );

                Navigator.pop(context);

                onAddVehicle(newVehicle);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Armada berhasil ditambahkan.')),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF087789),
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
