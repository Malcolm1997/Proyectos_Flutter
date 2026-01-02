import 'package:flutter/material.dart';
import 'package:mobile_app/core/app_colors.dart';
import 'package:mobile_app/core/box_decoration.dart';
import 'package:mobile_app/core/text_styles.dart';
import 'package:mobile_app/models/medical_device.dart';
import 'package:mobile_app/repositories/device_repositories.dart';
import 'package:mobile_app/services/mqtt_service.dart';
import 'package:mqtt_client/mqtt_client.dart';

class ScreenHome extends StatefulWidget {
  const ScreenHome({super.key});

  @override
  State<ScreenHome> createState() => _ScreenHomeState();
}

class _ScreenHomeState extends State<ScreenHome> {
  final _mqttService = MqttService();
  final _repository = LocalDeviceRepository();

  List<MedicalDevice> _devices = [];
  // Mapa de SerialNumber -> Status
  Map<String, String> _deviceStatuses = {};

  @override
  void initState() {
    super.initState();
    _setupMqtt();
  }

  Future<void> _setupMqtt() async {
    await _mqttService.initializeAndConnect();

    // Recuperar lista de dispositivos
    final devices = await _repository.getDevices();

    if (mounted) {
      setState(() {
        _devices = devices;
        // Inicializar estados en "Offline" si no existen
        for (var d in devices) {
          _deviceStatuses.putIfAbsent(d.serialNumber, () => "Offline");
        }
      });
    }

    if (devices.isEmpty) {
      debugPrint("No hay dispositivos vinculados.");
      return;
    }

    // Suscribirse a cada uno
    for (var device in devices) {
      final topic =
          "texel/${device.model}/${device.serialNumber}/${device.accessKey}/status";
      debugPrint("Suscrito al tópico: $topic");
      _mqttService.subscribe(topic);
    }

    _mqttService.messagesStream?.listen((
      List<MqttReceivedMessage<MqttMessage>>? c,
    ) {
      final MqttPublishMessage recMess = c![0].payload as MqttPublishMessage;
      final topic = c[0].topic; // texel/MODEL/SERIAL/status
      final pt = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      debugPrint('MQTT MSG ($topic): $pt');

      // Extraer serial del tópico para saber a quién actualizar
      // topic format: texel/MODELO/SERIAL/status
      final parts = topic.split('/');
      if (parts.length >= 3) {
        final serial = parts[2];

        if (mounted) {
          setState(() {
            _deviceStatuses[serial] = pt;
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio', style: TextStyles.title)),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(color: Colors.grey[200]),
          child: Column(
            children: [
              Row(
                children: [
                  panel(
                    "${_devices.length}",
                    Icons.published_with_changes_outlined,
                    "Dispositivos Activos",
                    Colors.green,
                  ),
                  panel(
                    "2",
                    Icons.event_note_outlined,
                    "Proximas Sesiones",
                    Color(0xffF59E0B),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  left: 10.0,
                  right: 10.0,
                  bottom: 10.0,
                  top: 20.0,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.monitor_heart_outlined),
                        Text(
                          "Dispositivos Activos",
                          style: TextStyles.textBold,
                        ),
                      ],
                    ),

                    if (_devices.isEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "No hay equipos vinculados",
                          style: TextStyles.text,
                        ),
                      )
                    else
                      ..._devices.map((device) {
                        final status =
                            _deviceStatuses[device.serialNumber] ?? "Offline";
                        return cardDevice(
                          title: "Equipo ${device.model}",
                          nroSerie: device.serialNumber,
                          icon: Icons.local_hospital_outlined,
                          status: status,
                        );
                      }).toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Column cardDevice({
    required String title,
    required String nroSerie,
    required IconData icon,
    required String status,
  }) {
    return Column(
      children: [
        SizedBox(height: 10),
        Container(
          decoration: AppBoxes.card,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(icon, size: 40),
                        SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(title, style: TextStyles.text),
                            Text(nroSerie, style: TextStyles.text),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.wifi,
                          color: status == "Online"
                              ? AppColors.statusSuccess
                              : AppColors.statusError,
                        ),
                        SizedBox(width: 5),
                        Text(
                          status,
                          style: TextStyle(
                            color: status == "Online"
                                ? AppColors.statusSuccess
                                : AppColors.statusError,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        child: Text("Ver"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Expanded panel(String number, IconData icon, String title, Color color) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(
          left: 10.0,
          right: 10.0,
          bottom: 10.0,
          top: 20.0,
        ),
        child: Container(
          decoration: AppBoxes.card,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(icon, color: color),
                    SizedBox(width: 10),
                    Text(number, style: TextStyles.textBoldTitle),
                  ],
                ),
                SizedBox(height: 10),
                Row(children: [Text(title, style: TextStyles.text)]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
