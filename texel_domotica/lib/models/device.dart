import 'package:flutter/material.dart';

enum DeviceStatus { online, inUse, offline, maintenance }

class Device {
  final String id;
  final String title;
  final String sn;
  final String? ip;
  final String version;
  final String location;
  final DeviceStatus status;
  final IconData icon;

  const Device({
    required this.id,
    required this.title,
    required this.sn,
    this.ip,
    required this.version,
    required this.location,
    required this.status,
    required this.icon,
  });

  factory Device.fromMap(Map m) {
    final statusStr = (m['status'] as String?) ?? 'offline';
    DeviceStatus s;
    switch (statusStr.toLowerCase()) {
      case 'en uso':
      case 'in use':
        s = DeviceStatus.inUse;
        break;
      case 'en línea':
      case 'online':
        s = DeviceStatus.online;
        break;
      case 'mantenimiento':
      case 'maintenance':
        s = DeviceStatus.maintenance;
        break;
      default:
        s = DeviceStatus.offline;
    }

    return Device(
      id: (m['id'] as String?) ?? (m['sn'] as String?) ?? DateTime.now().toIso8601String(),
      title: (m['title'] as String?) ?? '',
      sn: (m['sn'] as String?) ?? '',
      ip: m['ip'] as String?,
      version: (m['version'] as String?) ?? '',
      location: (m['location'] as String?) ?? '',
      status: s,
      icon: m['icon'] as IconData? ?? Icons.device_unknown,
    );
  }
}
