class MedicalDevice {
  final String model;
  final String serialNumber;
  final DateTime registeredAt;
  final String? accessKey;

  MedicalDevice({
    required this.model,
    required this.serialNumber,
    this.accessKey,
    DateTime? registeredAt,
  }) : registeredAt = registeredAt ?? DateTime.now();

  // Serialización para guardar en disco
  Map<String, dynamic> toJson() => {
    'model': model,
    'serial_number': serialNumber,
    'access_key': accessKey,
    'registered_at': registeredAt.toIso8601String(),
  };

  factory MedicalDevice.fromJson(Map<String, dynamic> json) {
    return MedicalDevice(
      model: json['model'],
      serialNumber: json['serial_number'],
      accessKey: json['access_key'],
      registeredAt: DateTime.tryParse(json['registered_at'] ?? ''),
    );
  }
}
