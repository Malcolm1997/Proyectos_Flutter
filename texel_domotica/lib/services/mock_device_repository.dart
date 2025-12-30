import 'dart:async';
import 'package:flutter/material.dart';
import 'package:texel_domotica/services/device_repository.dart';
import '../models/device.dart';

class MockDeviceRepository implements DeviceRepository {
  late final StreamController<List<Device>> _controller;
  late List<Device> _data;

  MockDeviceRepository() {
    _data = [
      Device(id: '1', title: 'Radiofrecuencia Texel RF-500', sn: 'TXL-RF-2024-001', ip: '192.168.1.101', version: 'v2.1.3', location: 'Sala A', status: DeviceStatus.online, icon: Icons.wifi),
      Device(id: '2', title: 'Electroestimulador Texel EMS-300', sn: 'TXL-EMS-2024-002', ip: '192.168.1.102', version: 'v1.8.5', location: 'Consultorio 2', status: DeviceStatus.inUse, icon: Icons.play_arrow),
      Device(id: '3', title: 'Ultrasonido Texel US-200', sn: 'TXL-US-2024-003', ip: '192.168.1.103', version: 'v1.5.2', location: 'Almacén', status: DeviceStatus.offline, icon: Icons.sensors),
      Device(id: '4', title: 'Presoterapia Texel PT-400', sn: 'TXL-PT-2024-004', ip: '192.168.1.104', version: 'v2.0.1', location: 'Taller', status: DeviceStatus.maintenance, icon: Icons.settings),
    ];

    // crear controller que re-emite el snapshot actual cuando un nuevo listener se suscribe
    _controller = StreamController<List<Device>>.broadcast(onListen: () {
      _controller.add(List.from(_data));
    });

    // emitir inicial (por si ya hay listeners)
    _controller.add(List.from(_data));

    // simular cambios periódicos
    Timer.periodic(const Duration(seconds: 8), (t) {
      final first = _data[0];
      _data[0] = Device(
        id: first.id,
        title: first.title,
        sn: first.sn,
        ip: first.ip,
        version: first.version,
        location: first.location,
        status: first.status == DeviceStatus.online ? DeviceStatus.inUse : DeviceStatus.online,
        icon: first.icon,
      );
      _controller.add(List.from(_data));
    });
  }

  @override
  Future<List<Device>> getDevices() async => List.from(_data);

  @override
  Stream<List<Device>> watchDevices() => _controller.stream;

  @override
  Future<Device?> getDeviceById(String id) async {
    try {
      return _data.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
}
