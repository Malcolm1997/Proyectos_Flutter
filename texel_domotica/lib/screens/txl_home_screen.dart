// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import '../core/app_colors.dart';
import '../models/device.dart';
import '../services/mock_device_repository.dart';
import '../widgets/info_card.dart';
import '../widgets/device_card.dart';
import '../widgets/device_modal.dart';
import '../widgets/bottom_nav.dart';

class TxlHomeScreen extends StatefulWidget {
  const TxlHomeScreen({super.key});

  @override
  State<TxlHomeScreen> createState() => _TxlHomeScreenState();
}

class _TxlHomeScreenState extends State<TxlHomeScreen> {
  final repo = MockDeviceRepository();
  int _currentIndex = 0;

  @override
  void dispose() {
    super.dispose();
    // repo no tiene dispose en esta versión; si lo tiene, ciérralo aquí
  }

  @override
  Widget build(BuildContext context) {
    final Color cardBg = AppColors.backgroundComponent;
    final Color cardBorder = AppColors.secundary.withOpacity(0.12);
    final Color primaryText = Colors.black87;
    final Color accent = AppColors.primary;

    final pages = [
      _buildDevicesPage(cardBg, cardBorder, primaryText, accent),
      _buildPlaceholder('Agenda', primaryText),
      _buildPlaceholder('Historial', primaryText),
      _buildPlaceholder('Ajustes', primaryText),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(child: pages[_currentIndex]),
      bottomNavigationBar: BottomNav(currentIndex: _currentIndex, onTap: (i) => setState(() => _currentIndex = i)),
    );
  }

  Widget _buildDevicesPage(Color cardBg, Color cardBorder, Color primaryText, Color accent) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StreamBuilder<List<Device>>(
            stream: repo.watchDevices(),
            initialData: const [],
            builder: (context, snap) {
              final list = snap.data ?? [];
              final total = list.length;
              final online = list.where((d) => d.status == DeviceStatus.online).length;

              return Row(
                children: [
                  Expanded(
                    child: InfoCard(value: '$total', label: 'Equipos totales', background: cardBg, borderColor: cardBorder, valueColor: primaryText),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InfoCard(value: '$online', label: 'En línea', background: cardBg, borderColor: cardBorder, valueColor: accent),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 18),
          Text('MIS EQUIPOS', style: TextStyle(color: primaryText.withOpacity(0.8), fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<Device>>(
              stream: repo.watchDevices(),
              initialData: const [],
              builder: (context, snap) {
                final list = snap.data ?? [];
                if (list.isEmpty) return const Center(child: Text('No hay equipos'));
                return ListView.separated(
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final d = list[index];
                    return DeviceCard(
                      title: d.title,
                      sn: d.sn,
                      status: d.status.toString().split('.').last,
                      version: d.version,
                      icon: d.icon,
                      statusColor: _mapStatusColor(d.status),
                      background: cardBg,
                      borderColor: cardBorder,
                      primaryText: primaryText,
                      expanded: false,
                      location: d.location,
                      onTap: () => showDeviceModal(context, d, onStart: (intensity, temperature, duration) {
                        // TODO: enviar a repositorio/IoT
                        debugPrint('Start $intensity $temperature $duration on ${d.title}');
                      }),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String label, Color primaryText) {
    return Center(child: Text(label, style: TextStyle(fontSize: 18, color: primaryText)));
  }

  Color _mapStatusColor(DeviceStatus s) {
    switch (s) {
      case DeviceStatus.online:
        return AppColors.primary;
      case DeviceStatus.inUse:
        return AppColors.primary;
      case DeviceStatus.offline:
        return AppColors.secundary;
      case DeviceStatus.maintenance:
        return AppColors.accent;
    }
  }
}