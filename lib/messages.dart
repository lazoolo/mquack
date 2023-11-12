import 'package:flutter/material.dart';

class MessageListPage extends StatefulWidget {
  final List<String> messages;

  MessageListPage({Key? key, required this.messages}) : super(key: key);

  @override
  _MessageListPageState createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MQTT Messages'),
      ),
      body: ListView.builder(
        itemCount: widget.messages.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(widget.messages[index]),
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
  }
}
