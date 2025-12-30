class MedicalDevice {
  final String model;
  final String serialNumber;
  final DateTime registeredAt;

  MedicalDevice({
    required this.model,
    required this.serialNumber,
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();

  // Serialización para guardar en disco
  Map<String, dynamic> toJson() => {
        'model': model,
        'serial_number': serialNumber,
        'registered_at': registeredAt.toIso8601String(),
      };
}