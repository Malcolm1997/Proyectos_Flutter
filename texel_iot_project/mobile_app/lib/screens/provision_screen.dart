import 'package:flutter/material.dart';
import 'package:flutter_esp_ble_prov/flutter_esp_ble_prov.dart';

class ProvisionScreen extends StatefulWidget {
  const ProvisionScreen({super.key});

  @override
  State<ProvisionScreen> createState() => _ProvisionScreenState();
}

class _ProvisionScreenState extends State<ProvisionScreen> {
  final _plugin = FlutterEspBleProv();
  final _prefixController = TextEditingController(text: 'TXL_');
  final _popController = TextEditingController(text: 'abcd1234');
  final _passController = TextEditingController();

  List<String> _devices = [];
  List<String> _networks = [];

  String? _selectedDevice;
  String? _selectedSsid;
  int _pageIndex = 0;
  bool _working = false;

  Future<void> _scanBle() async {
    setState(() {
      _working = true;
      _devices = [];
      _selectedDevice = null;
    });
    try {
      final prefix = _prefixController.text;
      final res = await _plugin.scanBleDevices(prefix);
      setState(() => _devices = res);
      setState(() => _devices = res);
      setState(() => _pageIndex = 1);
    } catch (e) {
      // Error handling silently or logging if needed
    } finally {
      setState(() => _working = false);
    }
  }

  Future<void> _scanWifiForSelectedDevice() async {
    if (_selectedDevice == null) return;
    setState(() {
      _working = true;
      _networks = [];
      _selectedSsid = null;
    });
    try {
      final pop = _popController.text;
      final res = await _plugin.scanWifiNetworks(_selectedDevice!, pop);
      setState(() => _networks = res);
      setState(() => _networks = res);
      setState(() => _pageIndex = 2);
    } catch (e) {
      // Error handling silently
    } finally {
      setState(() => _working = false);
    }
  }

  Future<void> _startProvision() async {
    if (_selectedDevice == null || _selectedSsid == null) return;
    setState(() => _working = true);

    // show progress dialog (indeterminate)
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Aprovisionando...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              SizedBox(height: 12),
              CircularProgressIndicator(),
              SizedBox(height: 12),
              Text('El dispositivo se está conectando a la red...'),
            ],
          ),
        ),
      ),
    );

    try {
      final pop = _popController.text;
      final pass = _passController.text;
      await _plugin.provisionWifi(_selectedDevice!, pop, _selectedSsid!, pass);
      await _plugin.provisionWifi(_selectedDevice!, pop, _selectedSsid!, pass);
      Navigator.of(context).pop(); // close progress
      _showSuccessDialog();
      setState(() => _pageIndex = 3);
    } catch (e) {
      Navigator.of(context).pop(); // close progress
      Navigator.of(context).pop(); // close progress
      _showErrorDialog(e.toString());
    } finally {
      setState(() => _working = false);
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text('Dispositivo configurado'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dispositivo: ${_selectedDevice ?? '-'}'),
            const SizedBox(height: 6),
            // Serial not always available; show placeholder if not parseable
            Text('Número de serie: ${_parseSerial(_selectedDevice) ?? '-'}'),
            const SizedBox(height: 6),
            Text('Red WiFi: ${_selectedSsid ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Finalizar'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  static String? _parseSerial(String? deviceName) {
    // intenta extraer S/N si el nombre contiene 'TXL-' o 'S/N:'
    if (deviceName == null) return null;
    final reg = RegExp(r'(S\/N[:\s]*([A-Z0-9\-\_]+))|(TXL-[A-Z0-9\-\_]+)');
    final m = reg.firstMatch(deviceName);
    return m?.group(2) ?? m?.group(0);
  }

  @override
  void dispose() {
    _prefixController.dispose();
    _popController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Widget _buildHeader(String title, String subtitle, IconData icon) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        CircleAvatar(radius: 36, child: Icon(icon, size: 36)),
        const SizedBox(height: 12),
        Text(subtitle, textAlign: TextAlign.center),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image(image: AssetImage('assets/texel_logo.png'), height: 30),
      ),
      body: SafeArea(
        child: _working
            ? const Center(child: CircularProgressIndicator())
            : IndexedStack(
                index: _pageIndex,
                children: [
                  // Page 0 - Buscar dispositivos
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _buildHeader(
                            'Buscar dispositivos',
                            'Asegúrate de que el equipo esté encendido y en modo de configuración (LED azul parpadeando).',
                            Icons.bluetooth_searching,
                          ),
                          TextField(
                            controller: _prefixController,
                            decoration: const InputDecoration(
                              labelText: 'Prefijo del dispositivo',
                              prefixIcon: Icon(Icons.tag),
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            onPressed: _scanBle,
                            child: const Text('Iniciar búsqueda'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Page 1 - Lista de dispositivos
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _buildHeader(
                            'Dispositivos encontrados',
                            'Selecciona el equipo que deseas configurar.',
                            Icons.bluetooth,
                          ),
                          if (_devices.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No se encontraron dispositivos. Presiona "Iniciar búsqueda" en la pantalla anterior.',
                                textAlign: TextAlign.center,
                              ),
                            )
                          else
                            ..._devices.map((d) {
                              final selected = d == _selectedDevice;
                              return Card(
                                color: selected ? Colors.green.shade50 : null,
                                child: ListTile(
                                  leading: const Icon(Icons.bluetooth),
                                  title: Text(d),
                                  subtitle: Text(
                                    'S/N: ${_parseSerial(d) ?? '-'}',
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(
                                      Icons.wifi,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {
                                      setState(() => _selectedDevice = d);
                                      _scanWifiForSelectedDevice();
                                    },
                                  ),
                                  onTap: () =>
                                      setState(() => _selectedDevice = d),
                                ),
                              );
                            }).toList(),
                          const SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: _devices.isEmpty
                                ? null
                                : () => setState(() => _pageIndex = 2),
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text(
                              'Configurar WiFi del dispositivo seleccionado',
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Page 2 - Seleccionar SSID y credenciales
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _buildHeader(
                            'Configurar WiFi',
                            'Conectado a ${_selectedDevice ?? '-'}\nIngresa las credenciales de la red WiFi.',
                            Icons.wifi,
                          ),
                          if (_networks.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Column(
                                children: [
                                  const Text(
                                    'No hay redes disponibles. Escanea la WiFi del dispositivo.',
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _scanWifiForSelectedDevice,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Escanear redes'),
                                  ),
                                ],
                              ),
                            )
                          else
                            ..._networks.map((s) {
                              return RadioListTile<String>(
                                value: s,
                                groupValue: _selectedSsid,
                                title: Text(s),
                                onChanged: (v) =>
                                    setState(() => _selectedSsid = v),
                              );
                            }).toList(),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passController,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            obscureText: true,
                          ),
                          const SizedBox(height: 8),
                          // Proof escondido: no editable ni seleccionable
                          TextField(
                            controller: _popController,
                            decoration: const InputDecoration(
                              labelText: 'Proof of possession (oculto)',
                              prefixIcon: Icon(Icons.key),
                            ),
                            readOnly: true,
                            enableInteractiveSelection: false,
                            obscureText: true,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed:
                                (_selectedSsid == null ||
                                    _selectedDevice == null)
                                ? null
                                : _startProvision,
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Configurar WiFi'),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Page 3 - Resultado / lista final
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Column(
                        children: [
                          _buildHeader(
                            'Configuración exitosa',
                            'Dispositivo configurado correctamente.',
                            Icons.check_circle,
                          ),
                          Card(
                            child: ListTile(
                              leading: const Icon(Icons.devices),
                              title: Text(_selectedDevice ?? '-'),
                              subtitle: Text(
                                'S/N: ${_parseSerial(_selectedDevice) ?? '-'}',
                              ),
                              trailing: Text(_selectedSsid ?? '-'),
                            ),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                            ),
                            child: const Text('Finalizar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
