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
          return Column(
            children: [
              Container(
                padding: EdgeInsets.all(8.0),
                color: Colors.blue,
                child: Row(
                  children: [
                    Expanded(
                      child:
                          Text('Topic', style: TextStyle(color: Colors.white)),
                    ),
                    Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.only(left: 10), // Add left padding here
                        child: Text('Payload',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: mqttManager.messages.length,
                  itemBuilder: (context, index) {
                    final message = mqttManager
                        .messages[mqttManager.messages.length - index - 1];
                    return Container(
                      color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(message.topic),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                    left: 10), // Add left padding here
                                child: Text(message.payload),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
