import 'package:flutter/foundation.dart';
import '../models/medical_device.dart';

// Interfaz para desacoplar implementación
abstract class IDeviceRepository {
  Future<void> saveDevice(MedicalDevice device);
}

class LocalDeviceRepository implements IDeviceRepository {
  @override
  Future<void> saveDevice(MedicalDevice device) async {
    // SIMULACIÓN: Aquí usarías SharedPreferences.getInstance()
    // final prefs = await SharedPreferences.getInstance();
    // await prefs.setString('last_device', jsonEncode(device.toJson()));
    
    await Future.delayed(const Duration(milliseconds: 800)); // Simula latencia de escritura
    debugPrint("PERSISTENCIA OK: ${device.model} - ${device.serialNumber}");
  }
}