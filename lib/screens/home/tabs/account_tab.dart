import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../models/vehicle_model.dart';
import '../../../services/api_service.dart';
import '../../auth/login_screen.dart';
import '../../tracking/tracking_screen.dart';

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
    final String displayName = ApiService.currentUser?['name'] ??
        ApiService.currentUser?['username'] ??
        'Pengguna JEJAKKU';
    final String displayEmail =
        ApiService.currentUser?['email'] ?? 'Akun GPS Tracker Aktif';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PROFILE CARD
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
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: AppColors.primary,
                    size: 38,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        displayEmail,
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                const Icon(Icons.edit_outlined, color: AppColors.primary),
              ],
            ),
          ),

          const SizedBox(height: 25),

          // ARMADA SAYA
          const Text(
            'Armada Saya',
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
                if (vehicles.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 18),
                    child: Column(
                      children: [
                        Icon(
                          Icons.directions_car_outlined,
                          size: 38,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Belum ada armada terdaftar.',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
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
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              vehicle.isMotor
                                  ? Icons.two_wheeler_rounded
                                  : Icons.directions_car_rounded,
                              color: AppColors.primary,
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

                // TOMBOL TAMBAH ARMADA
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showAddVehicleDialog(context);
                    },
                    icon: const Icon(Icons.add_rounded, color: AppColors.primary),
                    label: const Text(
                      'Tambah Armada',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
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
              color: AppColors.textPrimary,
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
                  icon: Icons.notifications_none_rounded,
                  title: 'Notifikasi',
                  subtitle: 'Atur peringatan dan status armada',
                  onTap: () => _showMessage(context, 'Pengaturan notifikasi dibuka.'),
                ),
                const Divider(height: 1, indent: 70),
                _accountMenu(
                  icon: Icons.security_rounded,
                  title: 'Keamanan Akun',
                  subtitle: 'Kata sandi dan autentikasi',
                  onTap: () => _showMessage(context, 'Pengaturan keamanan dibuka.'),
                ),
                const Divider(height: 1, indent: 70),
                _accountMenu(
                  icon: Icons.help_outline_rounded,
                  title: 'Bantuan & Dukungan',
                  subtitle: 'FAQ dan layanan bantuan',
                  onTap: () => _showMessage(context, 'Pusat bantuan dibuka.'),
                ),
                const Divider(height: 1, indent: 70),
                _accountMenu(
                  icon: Icons.info_outline_rounded,
                  title: 'Tentang Aplikasi',
                  subtitle: 'Informasi GPS Tracker JEJAKKU',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'JEJAKKU GPS Tracker',
                      applicationVersion: '1.0.0',
                      applicationIcon: const Icon(
                        Icons.two_wheeler_rounded,
                        color: AppColors.primary,
                        size: 40,
                      ),
                      children: const [
                        Text(
                          'Aplikasi modern untuk memantau kendaraan '
                          'menggunakan GPS Tracker real-time.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // TOMBOL KELUAR / LOGOUT
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                _showLogoutConfirmDialog(context);
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

  void _showLogoutConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Konfirmasi Keluar',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text('Apakah Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ApiService.token = null;
              ApiService.currentUser = null;

              // Kembali ke LoginPage dan bersihkan stack navigasi
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Keluar'),
          ),
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
            const SizedBox(width: 14),
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
                    subtitle,
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
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

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
