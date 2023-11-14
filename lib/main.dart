import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'mqttmanager.dart';
import 'package:logging/logging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'sharedwidgets.dart';

final _logger = Logger('Main');

void main() {
  Logger.root.level =
      Level.ALL; // Set this level to control which log messages to show
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  // Instantiate the MqttManager here
  MqttManager mqttManager = MqttManager();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<MessageManager>.value(
            value: mqttManager.messageManager),
        ChangeNotifierProvider<ConnectionManager>.value(
            value: mqttManager.connectionManager),
        Provider<MqttManager>.value(value: mqttManager), // Provide MqttManager
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(
      context,
      designSize: Size(360, 690),
    );
    return MaterialApp(
      title: 'mQuack',
      theme: ThemeData(
        // This is the theme of your application.
        colorScheme:
            ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 1, 47, 12)),
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

  @override
  void initState() {
    super.initState();
    mqttManager = Provider.of<MqttManager>(context, listen: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: MyColumnWidget(mqttManager: mqttManager),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(currentIndex: 0),
    );
  }
}

class MyColumnWidget extends StatefulWidget {
  final MqttManager? mqttManager;
  MyColumnWidget({this.mqttManager});

  @override
  _MyColumnWidgetState createState() => _MyColumnWidgetState();
}

class _MyColumnWidgetState extends State<MyColumnWidget> {
  String _brokerAddress = '192.168.86.1'; // Default broker address
  final TextEditingController _brokerAddressController =
      TextEditingController();

  int _brokerPort = 1883; // Default broker port
  final TextEditingController _brokerPortController = TextEditingController();

  final TextEditingController _clientIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _brokerAddressController.text = _brokerAddress;
    _brokerPortController.text = _brokerPort.toString();
    _clientIdController.text = 'mQuack';
  }

  @override
  Widget build(BuildContext context) {
    MqttManager? mqttManager = widget.mqttManager;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Wrap(
          direction: Axis.horizontal,
          alignment: WrapAlignment.center,
          children: <Widget>[
            _buildBrokerAddressField(),
            _buildPortField(),
            _buildClientIdField(), // Add this line
          ],
        ),
        Consumer<ConnectionManager>(
          builder: (context, connectionManager, child) {
            return ElevatedButton(
              onPressed: () {
                if (connectionManager.connected) {
                  mqttManager?.disconnect();
                } else {
                  _logger.info('DISCONNECT ELSE');
                  mqttManager?.connectToBroker(_brokerAddress, _brokerPort,
                      clientId: 'XXYYZZ');
                }
              },
              child:
                  Text(connectionManager.connected ? 'Disconnect' : 'Connect'),
            );
          },
        ),
      ],
    );
  }

  Widget _buildBrokerAddressField() {
    return Container(
      width: 200.w, // Set your desired maximum width here.
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: TextField(
          controller: _brokerAddressController,
          decoration: InputDecoration(
            labelText: 'Broker Address',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            _brokerAddress = value;
          },
        ),
      ),
    );
  }

  Widget _buildPortField() {
    return Container(
      width: 200.w, // Set your desired maximum width here.
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: TextField(
          controller: _brokerPortController,
          decoration: InputDecoration(
            labelText: 'Port',
            border: OutlineInputBorder(),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly
          ], // Only numbers can be entered
          onChanged: (value) {
            _brokerPort = int.tryParse(value) ?? 1883;
          },
        ),
      ),
    );
  }

  Widget _buildClientIdField() {
    return Container(
      width: 200.w, // Set your desired maximum width here.
      child: Padding(
        padding: EdgeInsets.all(8.0.w),
        child: TextField(
          controller: _clientIdController,
          decoration: InputDecoration(
            labelText: 'Client ID',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            // Update your client ID here
          },
        ),
      ),
    );
  }
}
