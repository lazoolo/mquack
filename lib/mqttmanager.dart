import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:logging/logging.dart';

class MqttManager {
  List<String> _messages = [];
  List<String> get messages => _messages;

  final MessageManager messageManager = MessageManager();
  final ConnectionManager connectionManager = ConnectionManager();

  MqttServerClient? client;

  final _logger = Logger('MqttManager');

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
      messageManager.addMessage(newMessage);

      // Log the new message
      _logger.info('Received message: $newMessage');
    });
  }

  void disconnect() {
    client?.disconnect();
  }

  void onDisconnected() {
    connectionManager.onDisconnected();

    _logger.info('MQTT client disconnected');
  }

  void onConnected() {
    connectionManager.onConnected();
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

class MessageManager with ChangeNotifier {
  List<String> _messages = [];

  List<String> get messages => _messages;

  void addMessage(String message) {
    _messages.add(message);
    notifyListeners(); // Notify all listeners about the update
  }
}

class ConnectionManager with ChangeNotifier {
  bool _connected = false;

  bool get connected => _connected;

  void onConnected() {
    _connected = true;
    notifyListeners();
  }

  void onDisconnected() {
    _connected = false;
    notifyListeners();
  }
}
