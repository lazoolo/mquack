import 'package:flutter/material.dart';
import 'mqttmanager.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';

class MessageListPage extends StatefulWidget {
  MessageListPage({Key? key}) : super(key: key);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  MqttManager? mqttManager;

  @override
  void initState() {
    super.initState();
    mqttManager = Provider.of<MqttManager>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentIndex: 1,
      body: Consumer<MessageManager>(
        builder: (context, mqttManager, child) {
          return ListView.builder(
            itemCount: mqttManager.messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(mqttManager.messages[index]),
              );
            },
          );
        },
      ),
    );
  }
}
