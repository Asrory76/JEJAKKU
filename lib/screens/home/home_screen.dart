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

  final List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  Future<void> _fetchVehicles() async {
    setState(() => _isLoading = true);
    try {
      final fetched = await ApiService.getVehicles();
      if (mounted) {
        setState(() {
          _vehicles.clear();
          _vehicles.addAll(fetched);
        });
      }
    } catch (e) {
      debugPrint('Info: Server fetch failed: $e');
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

  void _showAddVehicleDialog() {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController plateController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
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
              onPressed: () => Navigator.pop(ctx),
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
                  plate: plateController.text.trim().toUpperCase(),
                  isMotor: true,
                );

                Navigator.pop(ctx);
                _addVehicle(newVehicle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
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
                    vehicle: _vehicles.isNotEmpty ? _vehicles.first : null,
                    onTrack: () {
                      if (_vehicles.isNotEmpty) {
                        _openTracking(_vehicles.first);
                      }
                    },
                    onAddVehicle: _showAddVehicleDialog,
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
