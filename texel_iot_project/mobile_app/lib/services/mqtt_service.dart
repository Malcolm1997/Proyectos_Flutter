import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  // Singleton
  static final MqttService _instance = MqttService._internal();
  factory MqttService() => _instance;
  MqttService._internal();

  late MqttServerClient client;
  bool isConnected = false;

  // Broker Configuration
  final String _host = '192.168.100.107';
  final int _port = 1883;

  Future<void> initializeAndConnect() async {
    // Unique ID
    final String clientId =
        'texel_app_${DateTime.now().millisecondsSinceEpoch}';

    client = MqttServerClient(_host, clientId);
    client.port = _port;
    client.logging(on: false);
    client.keepAlivePeriod = 20;
    client.onDisconnected = _onDisconnected;
    client.onConnected = _onConnected;
    client.onSubscribed = _onSubscribed;

    // Configuración de mensaje de conexión
    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('texel/app/status')
        .withWillMessage('Disconnected')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    client.connectionMessage = connMess;

    try {
      debugPrint('MQTT: Conectando a $_host...');
      await client.connect();
    } on NoConnectionException catch (e) {
      debugPrint('MQTT: Client exception - $e');
      client.disconnect();
    } on SocketException catch (e) {
      debugPrint('MQTT: Socket exception - $e');
      client.disconnect();
    }
  }

  void subscribe(String topic) {
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      debugPrint('MQTT: Suscribiendo a $topic');
      client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  Stream<List<MqttReceivedMessage<MqttMessage>>>? get messagesStream =>
      client.updates;

  void _onConnected() {
    debugPrint('MQTT: CONNECTED');
    isConnected = true;
  }

  void _onDisconnected() {
    debugPrint('MQTT: DISCONNECTED');
    isConnected = false;
  }

  void _onSubscribed(String topic) {
    debugPrint('MQTT: Subscripción confirmada para $topic');
  }

  void disconnect() {
    client.disconnect();
  }

  /// Verifica si un tópico tiene un valor específico (retenido).
  /// Retorna [true] si recibe [expectedValue] dentro del [timeout].
  Future<bool> checkTopicValue(
    String topic,
    String expectedValue, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    if (!isConnected) return false;

    // Crear un Completer para esperar la respuesta
    final completer = Completer<bool>();

    // Suscribirse
    debugPrint('MQTT CHECK: Verificando $topic...');
    client.subscribe(topic, MqttQos.atMostOnce);

    // Escuchar temporalmente
    final subscription = client.updates?.listen((
      List<MqttReceivedMessage<MqttMessage>>? c,
    ) {
      final recMess = c![0].payload as MqttPublishMessage;
      final pt = MqttPublishPayload.bytesToStringAsString(
        recMess.payload.message,
      );

      // Chequear si es el tópico correcto (por si hay otros mensajes fluyendo)
      if (c[0].topic == topic) {
        if (pt == expectedValue && !completer.isCompleted) {
          completer.complete(true);
        }
      }
    });

    // Esperar resultado o timeout
    try {
      await completer.future.timeout(timeout);
    } catch (e) {
      // Timeout
      if (!completer.isCompleted) completer.complete(false);
    }

    // Limpieza
    await subscription?.cancel();
    client.unsubscribe(topic);
    debugPrint(
      'MQTT CHECK: Fin verificación. Resultado: ${completer.isCompleted ? await completer.future : "Timeout"}',
    );

    return await completer.future;
  }
}
