import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';
import '../../../models/vehicle_model.dart';

class HomeQuickMenu extends StatelessWidget {
  final Vehicle? vehicle;
  final VoidCallback onTrack;

  const HomeQuickMenu({
    super.key,
    required this.vehicle,
    required this.onTrack,
  });

  void _showFeatureDialog(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Widget content,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color, size: 26),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              const Divider(height: 1),
              const SizedBox(height: 16),
              content,
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEngineControl(BuildContext context) {
    _showFeatureDialog(
      context,
      title: 'Kontrol Starter Mesin',
      subtitle: 'Modul IoT relay pemutus arus kontak',
      icon: Icons.key_rounded,
      color: const Color(0xFFE76F51),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Mode Sistem',
            'SIMULASI IOT',
            isBadge: true,
            badgeColor: AppColors.primary,
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Kendaraan Terpilih', vehicle?.name ?? 'Belum dipilih'),
          const SizedBox(height: 10),
          _buildInfoRow('Status Relay', 'Normal Terhubung (Starter Aktif)'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3CD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: Colors.orange,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Fitur ini merupakan antarmuka untuk modul hardware IoT Relay. Dalam versi aplikasi ini, kendali berjalan dalam mode simulasi keamanan.',
                    style: TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showServiceReminder(BuildContext context) {
    _showFeatureDialog(
      context,
      title: 'Jadwal Perawatan',
      subtitle: 'Catatan servis berkala & ganti oli',
      icon: Icons.build_circle_rounded,
      color: const Color(0xFFF4A261),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Status Servis',
            'CATATAN MANUAL',
            isBadge: true,
            badgeColor: Colors.orange,
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Armada', vehicle?.name ?? 'Semua armada'),
          const SizedBox(height: 10),
          _buildInfoRow('Rekomendasi', 'Ganti Oli & Filter Udara setiap 2.000 KM'),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.event_note_rounded, color: AppColors.primary, size: 22),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Pengingat servis dapat dikonfigurasi berdasarkan jarak tempuh aktual dari modul pelacak GPS Anda.',
                    style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTripLog(BuildContext context) {
    _showFeatureDialog(
      context,
      title: 'Laporan & Statistik Trip',
      subtitle: 'Analisis pelacakan posisi GPS riil',
      icon: Icons.bar_chart_rounded,
      color: const Color(0xFF0077B6),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow(
            'Sumber Data',
            'GPS REAL-TIME',
            isBadge: true,
            badgeColor: const Color(0xFF0077B6),
          ),
          const SizedBox(height: 10),
          _buildInfoRow('Armada', vehicle?.name ?? '-'),
          const SizedBox(height: 10),
          _buildInfoRow(
            'Lokasi Terakhir',
            vehicle?.lastPosition?['address'] ?? 'Yogyakarta',
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F4FC),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.route_rounded, color: Color(0xFF0077B6), size: 22),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Riwayat rute lengkap dicatat otomatis saat kendaraan bergerak. Buka Live Lacak untuk melihat peta jalur.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF0077B6)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isBadge = false,
    Color badgeColor = Colors.grey,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        if (isBadge)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: badgeColor,
              ),
            ),
          )
        else
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> menuItems = [
      {
        'title': 'Live Lacak',
        'subtitle': 'Realtime GPS',
        'icon': Icons.near_me_rounded,
        'color': const Color(0xFF087789),
        'bg': const Color(0xFFE8F4F6),
        'onTap': onTrack,
      },
      {
        'title': 'Riwayat Rute',
        'subtitle': 'Playback jalur',
        'icon': Icons.route_rounded,
        'color': const Color(0xFF7B2CBF),
        'bg': const Color(0xFFF3E8FF),
        'onTap': onTrack,
      },
      {
        'title': 'Kontak Mesin',
        'subtitle': 'Starter cutoff',
        'icon': Icons.key_rounded,
        'color': const Color(0xFFE76F51),
        'bg': const Color(0xFFFDF0ED),
        'onTap': () => _showEngineControl(context),
      },
      {
        'title': 'Servis Rutin',
        'subtitle': 'Ganti oli',
        'icon': Icons.build_circle_rounded,
        'color': const Color(0xFFF4A261),
        'bg': const Color(0xFFFEF5EE),
        'onTap': () => _showServiceReminder(context),
      },
      {
        'title': 'Laporan Trip',
        'subtitle': 'Analitik jarak',
        'icon': Icons.bar_chart_rounded,
        'color': const Color(0xFF0077B6),
        'bg': const Color(0xFFE8F4FC),
        'onTap': () => _showTripLog(context),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Menu & Kontrol Armada',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
                letterSpacing: -0.2,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Fitur telemetri dan kendali operasional GPS',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        // Responsive scrollable quick menu with comfortable tap targets (>= 44x44px)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: menuItems.map((item) {
              return Padding(
                padding: const EdgeInsets.only(right: 10),
                child: SizedBox(
                  width: 78,
                  child: _buildMenuTile(
                    title: item['title'] as String,
                    icon: item['icon'] as IconData,
                    color: item['color'] as Color,
                    bg: item['bg'] as Color,
                    onTap: item['onTap'] as VoidCallback,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuTile({
    required String title,
    required IconData icon,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.08)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 7),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
