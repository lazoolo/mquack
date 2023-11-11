import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mquacktt.dart';
import 'package:logging/logging.dart';

void main() {
  Logger.root.level =
      Level.ALL; // Set this level to control which log messages to show
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  runApp(
    ChangeNotifierProvider(
      create: (context) => ConnectionState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'mQuack',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Connections'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  MqttManager? mqttManager;
  int _counter = 0;
  String _message = 'HI WORLD';

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              _message,
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton(
              onPressed: () {
                if (Provider.of<ConnectionState>(context, listen: false)
                    .connected) {
                  mqttManager?.disconnect();
                } else {
                  mqttManager = MqttManager(
                    serverAddress: '192.168.86.2',
                    clientId: 'XXYYZZ',
                    onConnectionChanged: (connected) {
                      Provider.of<ConnectionState>(context, listen: false)
                          .connected = connected;
                    },
                    onMessageReceived: (message) {
                      setState(() {
                        _message = message;
                      });
                    },
                  );
                  mqttManager?.connectToBroker();
                }
              },
              child: Text(Provider.of<ConnectionState>(context).connected
                  ? 'Disconnect'
                  : 'Connect'),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ConnectionState extends ChangeNotifier {
  bool _connected = false;

  bool get connected => _connected;

  set connected(bool value) {
    _connected = value;
    notifyListeners();
  }
}
