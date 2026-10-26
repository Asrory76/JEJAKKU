import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../models/vehicle_model.dart';
import '../../services/api_service.dart';
import '../tracking/tracking_screen.dart';
import 'tabs/account_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/search_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isLoading = false;

  final List<Vehicle> _vehicles = [
    const Vehicle(id: 1, name: 'Honda Vario 160', plate: 'AB 1234 XY', isMotor: true),
    const Vehicle(id: 2, name: 'Toyota Avanza', plate: 'AB 5678 CD', isMotor: false),
  ];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await ApiService.getVehicles();
      if (mounted && fetched.isNotEmpty) {
        setState(() {
          _vehicles.clear();
          _vehicles.addAll(fetched);
        });
      }
    } catch (e) {
      debugPrint('Info: Server fetch failed, using local fallback: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addVehicle(Vehicle vehicle) async {
    try {
      final newVehicle = await ApiService.addVehicle(
        name: vehicle.name,
        plate: vehicle.plate,
        isMotor: vehicle.isMotor,
      );
      if (mounted) {
        setState(() {
          _vehicles.add(newVehicle);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Armada berhasil disimpan ke database!')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _vehicles.add(vehicle);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Tersimpan lokal: $e')),
        );
      }
    }
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
      backgroundColor: const Color.fromARGB(255, 240, 243, 244),
      body: SafeArea(
        child: Column(
          children: [
            // ======================================================
            // HEADER JEJAKKU
            // ======================================================
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.primary,
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
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.two_wheeler_rounded,
                      color: AppColors.primary,
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

                  const Spacer(),

                  IconButton(
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.sync_rounded, color: Colors.white),
                    tooltip: 'Sinkronkan Armada dari Server',
                    onPressed: _isLoading ? null : _fetchVehicles,
                  ),
                ],
              ),
            ),

            // ======================================================
            // CONTENT TABS
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
      // BOTTOM NAVIGATION BAR
      // ======================================================
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: AppColors.primary,
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
            label: 'Cari',
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
