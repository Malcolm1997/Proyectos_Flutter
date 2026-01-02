import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app/repositories/device_repositories.dart';
import 'package:mobile_app/services/mqtt_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/medical_device.dart';

class DeviceRegistrationScreen extends StatefulWidget {
  const DeviceRegistrationScreen({super.key});

  @override
  State<DeviceRegistrationScreen> createState() =>
      _DeviceRegistrationScreenState();
}

class _DeviceRegistrationScreenState extends State<DeviceRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _modelController = TextEditingController();
  final _serialController = TextEditingController();
  final _keyController = TextEditingController();

  final IDeviceRepository _repository = LocalDeviceRepository();

  bool _isLoading = false;

  void _processQR(String rawData) {
    try {
      final Map<String, dynamic> data = jsonDecode(rawData);

      final model = data['m']?.toString();
      final serial = data['s']?.toString();
      // Guardamos la clave si existe, aunque no se muestre
      final key = data['k']?.toString();

      if (model == null || serial == null) {
        _showSnack('QR inválido: Faltan datos (m/s)', isError: true);
        return;
      }

      setState(() {
        _modelController.text = model.toUpperCase().trim();
        _serialController.text = serial.toUpperCase().trim();
        _keyController.text = key ?? '';
      });

      _showSnack('Datos importados del QR correctamente');
    } catch (e) {
      _showSnack('Error al leer QR: NO es un JSON válido ($e)', isError: true);
    }
  }

  // --- Lógica de Guardado ---
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Ocultar teclado
    FocusScope.of(context).unfocus();

    // 1. Validar Credenciales via MQTT
    final model = _modelController.text.trim();
    final serial = _serialController.text.trim();
    final key = _keyController.text.trim();

    // Tópico de validación: texel/MODEL/SERIAL/KEY/existo
    // Esperamos que el valor sea "true"
    final validationTopic = "texel/$model/$serial/$key/existo";

    _showSnack("Verificando credenciales con el equipo...", isError: false);

    // Asegurar conexión antes de chequear
    final mqtt = MqttService();
    if (!mqtt.isConnected) await mqtt.initializeAndConnect();

    final isValid = await mqtt.checkTopicValue(validationTopic, "true");

    if (!isValid) {
      if (mounted) {
        _showSnack(
          "Error: No se pudo verificar el equipo. Revise que esté encendido y los datos sean correctos.",
          isError: true,
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    final device = MedicalDevice(
      model: model,
      serialNumber: serial,
      accessKey: key,
    );

    try {
      await _repository.saveDevice(device);
      if (!mounted) return;
      _showSnack('Equipo ${device.model} vinculado exitosamente');

      // Esperamos brevísima para que el snackbar se vea
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) context.push('/home');
    } catch (e) {
      _showSnack('Error de persistencia: $e', isError: true);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // --- Navegación al Escáner ---
  Future<void> _openScanner() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const _QRScannerView()),
    );
    if (result != null && mounted) {
      _processQR(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image(image: AssetImage('assets/texel_logo.png'), height: 30),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Visual
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blueGrey.shade200),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blueGrey),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Escanee el QR en la carcasa del ESP32 o ingrese datos manualmente.',
                        style: TextStyle(
                          color: Colors.blueGrey.shade800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Botón Escáner Grande
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _openScanner,
                icon: const Icon(Icons.qr_code_scanner, size: 28),
                label: const Text('ESCANEAR QR AHORA'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 30),
              // Reemplazo visual para el separador con texto
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      "O ingreso manual",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),

              // Inputs
              _buildInput(_modelController, 'Modelo', Icons.memory, 'Ej: VR'),
              const SizedBox(height: 16),
              _buildInput(
                _serialController,
                'Número de Serie',
                Icons.fingerprint,
                'Ej: 111-022',
              ),
              const SizedBox(height: 16),
              _buildInput(
                _keyController,
                'Clave de Acceso',
                Icons.vpn_key,
                'Ej: A9zL2',
              ),

              const SizedBox(height: 32),

              // Botón Guardar
              FilledButton(
                onPressed: _isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('VINCULAR EQUIPO'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController controller,
    String label,
    IconData icon,
    String hint,
  ) {
    return TextFormField(
      controller: controller,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (v) => (v == null || v.isEmpty) ? 'Campo requerido' : null,
    );
  }
}

// Widget Interno Privado para la Cámara
class _QRScannerView extends StatelessWidget {
  const _QRScannerView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Encuadre el Código QR')),
      backgroundColor: Colors.black,
      body: MobileScanner(
        controller: MobileScannerController(
          detectionSpeed: DetectionSpeed.noDuplicates,
          returnImage: false,
        ),
        onDetect: (capture) {
          final List<Barcode> barcodes = capture.barcodes;
          for (final barcode in barcodes) {
            if (barcode.rawValue != null) {
              Navigator.pop(context, barcode.rawValue!);
              break;
            }
          }
        },
      ),
    );
  }
}
