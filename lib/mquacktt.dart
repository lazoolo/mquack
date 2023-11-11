import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logging/logging.dart';

class MqttManager {
  final String serverAddress;
  final String clientId;
  final Function(bool) onConnectionChanged;
  final Function(String) onMessageReceived;

  MqttServerClient? client;

  final _logger = Logger('MqttManager');

  MqttManager({
    required this.serverAddress,
    required this.clientId,
    required this.onConnectionChanged,
    required this.onMessageReceived,
  });

  Future<MqttServerClient> connectToBroker() async {
    client = MqttServerClient(serverAddress, clientId);
    client!.logging(on: false);
    client!.keepAlivePeriod = 60;
    client!.onDisconnected = onDisconnected;
    client!.onConnected = onConnected;
    client!.onSubscribed = onSubscribed;

    try {
      await client!.connect();
    } catch (e) {
      _logger.info('Exception: ');
      client!.disconnect();
    }

    if (client!.connectionStatus!.state == MqttConnectionState.connected) {
      _logger.info('MQTT client connected');
      // Set the callback for when a message is received
      setupMessageListener(); // Use setupMessageListener here
    } else {
      _logger.info('ERROR: MQTT client connection failed - '
          'disconnecting, state is ${client!.connectionStatus!.state}');
      client!.disconnect();
    }

    return client!;
  }

  void setupMessageListener() {
    client?.updates?.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttPublishMessage recMess = c[0].payload as MqttPublishMessage;
      final String newMessage =
          MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

      // Call the callback
      onMessageReceived(newMessage);
    });
  }

  void disconnect() {
    client?.disconnect();
  }

  void onDisconnected() {
    onConnectionChanged(false);
    _logger.info('MQTT client disconnected');
  }

  void onConnected() {
    onConnectionChanged(true);
    _logger.info('MQTT client connected');
    subscribeToAllTopics();
  }

  void onSubscribed(String topic) {
    _logger.info('Subscribed to topic: ');
  }

  Future<void> subscribeToAllTopics() async {
    _logger.info('Subscribing to all topics');
    client!.subscribe('#', MqttQos.atMostOnce);
  }
}
