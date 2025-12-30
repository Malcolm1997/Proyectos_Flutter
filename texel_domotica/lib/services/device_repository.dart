import '../models/device.dart';

abstract class DeviceRepository {
  Future<List<Device>> getDevices();
  Stream<List<Device>> watchDevices();
  Future<Device?> getDeviceById(String id);
}
