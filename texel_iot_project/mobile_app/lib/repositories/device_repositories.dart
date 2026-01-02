import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/medical_device.dart';

// Interfaz para desacoplar implementación
abstract class IDeviceRepository {
  Future<void> saveDevice(MedicalDevice device);
  Future<List<MedicalDevice>> getDevices();
}

class LocalDeviceRepository implements IDeviceRepository {
  static const String _keyDevices = 'saved_devices_list_v1';

  @override
  Future<void> saveDevice(MedicalDevice device) async {
    final prefs = await SharedPreferences.getInstance();
    final List<MedicalDevice> currentList = await getDevices();

    // Buscar si ya existe para actualizarlo
    final index = currentList.indexWhere(
      (d) => d.serialNumber == device.serialNumber,
    );
    if (index != -1) {
      currentList[index] = device;
    } else {
      currentList.add(device);
    }

    final String jsonString = jsonEncode(
      currentList.map((e) => e.toJson()).toList(),
    );
    await prefs.setString(_keyDevices, jsonString);
    debugPrint(
      "PERSISTENCIA: Lista actualizada. Total equipos: ${currentList.length}",
    );
  }

  @override
  Future<List<MedicalDevice>> getDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyDevices);
    if (jsonString == null) return [];

    try {
      final List<dynamic> listMap = jsonDecode(jsonString);
      return listMap.map((e) => MedicalDevice.fromJson(e)).toList();
    } catch (e) {
      debugPrint("Error deserializando lista de dispositivos: $e");
      return [];
    }
  }
}
