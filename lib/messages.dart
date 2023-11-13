import 'package:flutter/material.dart';
import 'mqttmanager.dart';
import 'package:provider/provider.dart';

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

  Widget build(BuildContext context) {
    return Consumer<MessageManager>(
      builder: (context, mqttManager, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text('MQTT Messages'),
          ),
          body: ListView.builder(
            itemCount: mqttManager.messages.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(mqttManager.messages[index]),
              );
            },
          ),
          bottomNavigationBar: BottomAppBar(
            child: Row(
              children: <Widget>[
                IconButton(
                  icon: Icon(Icons.home),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the main page
                  },
                ),
                IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    // You're already on the messages page, so no need to navigate
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
