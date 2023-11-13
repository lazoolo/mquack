import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logging/logging.dart';

class MqttManager {
  List<String> _messages = [];
  List<Function(String)> _messageCallbacks = [];
  List<Function> _connectedCallbacks = [];
  List<Function> _disconnectedCallbacks = [];

  MqttServerClient? client;

  final _logger = Logger('MqttManager');

  MqttManager() {}

  Future<MqttServerClient> connectToBroker(String serverAddress, int serverPort,
      {String? clientId}) async {
    client = MqttServerClient(serverAddress, clientId ?? 'mQuack');
    client!.logging(on: false);
    client!.port = serverPort;
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

      // Add the new message to _messages
      _messages.add(newMessage);

      // Log the new message
      _logger.info('Received message: $newMessage');

      // Call all registered callbacks
      for (var callback in _messageCallbacks) {
        callback(newMessage);
      }
    });
  }

  void registerMessageCallback(Function(String) callback) {
    _messageCallbacks.add(callback);
  }

  List<String> get messages => _messages;

  void disconnect() {
    client?.disconnect();
  }

  void registerConnectedCallback(Function callback) {
    _connectedCallbacks.add(callback);
  }

  void registerDisconnectedCallback(Function callback) {
    _disconnectedCallbacks.add(callback);
  }

  void onDisconnected() {
    for (var callback in _disconnectedCallbacks) {
      callback();
    }

    _logger.info('MQTT client disconnected');
  }

  void onConnected() {
    for (var callback in _connectedCallbacks) {
      callback();
    }
    ;
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
