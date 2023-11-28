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
  final ValueNotifier<String> _searchTextNotifier = ValueNotifier<String>('');

  @override
  void initState() {
    super.initState();
    mqttManager = Provider.of<MqttManager>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentIndex: 1,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                _searchTextNotifier.value = value;
              },
              decoration: InputDecoration(
                labelText: "Search",
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(25.0)),
                ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            color: Colors.blue,
            child: Row(
              children: [
                Expanded(
                  child: Text('Topic', style: TextStyle(color: Colors.white)),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(left: 10), // Add left padding here
                    child:
                        Text('Payload', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Consumer<MessageManager>(
              builder: (context, mqttManager, child) {
                return ValueListenableBuilder<String>(
                  valueListenable: _searchTextNotifier,
                  builder: (context, searchText, child) {
                    return FilterableListView(
                      messages: mqttManager.messages,
                      searchText: searchText,
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MessageDetailBottomSheet extends StatelessWidget {
  final Message message;

  MessageDetailBottomSheet({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width, // Full screen width
      height:
          MediaQuery.of(context).size.height * 2 / 3, // 2/3 of screen height
      padding: EdgeInsets.all(10.0),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SelectableText('Topic: ${message.topic}',
                style: TextStyle(fontSize: 18.0)),
            SizedBox(height: 10),
            SelectableText('Payload:\n${message.payload}',
                style: TextStyle(fontSize: 18.0)),
          ],
        ),
      ),
    );
  }
}

class FilterableListView extends StatelessWidget {
  final List<Message> messages;
  final String searchText;

  FilterableListView({required this.messages, required this.searchText});

  @override
  Widget build(BuildContext context) {
    final filteredMessages = messages
        .where((message) => message.payload.contains(searchText))
        .toList();

    return ListView.builder(
      itemCount: filteredMessages.length,
      itemBuilder: (context, index) {
        final message = filteredMessages[filteredMessages.length - index - 1];
        return GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              builder: (BuildContext context) {
                return MessageDetailBottomSheet(message: message);
              },
            );
          },
          child: Container(
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
                      padding:
                          EdgeInsets.only(left: 10), // Add left padding here
                      child: Text(message.payload),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
