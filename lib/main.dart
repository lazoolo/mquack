import 'package:flutter/material.dart';
import 'package:mquack/messages.dart';
import 'package:provider/provider.dart';
import 'navigation.dart';
import 'mqttmanager.dart';
import 'package:logging/logging.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

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
      initialRoute: '/connections', // Set the default route
      routes: {
        '/connections': (context) => MyHomePage(),
        '/messages': (context) => MessageListPage(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
    return ResponsiveLayout(
      currentIndex: 0,
      body: ConnectFormWidget(mqttManager: mqttManager),
    );
  }
}

class ConnectFormWidget extends StatefulWidget {
  final MqttManager? mqttManager;
  ConnectFormWidget({this.mqttManager});

  @override
  _ConnectFormWidgetState createState() => _ConnectFormWidgetState();
}

class _ConnectFormWidgetState extends State<ConnectFormWidget> {
  MqttManager? mqttManager;
  String _brokerAddress = ''; // Default broker address
  final TextEditingController _brokerAddressController =
      TextEditingController();

  int _brokerPort = 1883; // Default broker port
  final TextEditingController _brokerPortController = TextEditingController();

  String _clientId = 'mQuack';
  final TextEditingController _clientIdController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Add this line

  @override
  void initState() {
    super.initState();
    mqttManager = widget.mqttManager;
    _brokerAddress = mqttManager?.client?.server ?? '';
    _brokerPort = mqttManager?.client?.port ?? 1883;
    _clientId = mqttManager?.client?.clientIdentifier ?? 'mQuack';
    _brokerAddressController.text = _brokerAddress;
    _brokerPortController.text = _brokerPort.toString();
    _clientIdController.text = _clientId;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      // Wrap the Column widget with a Form widget
      key: _formKey, // Assign the GlobalKey to the Form widget
      child: Column(
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
                  if (_formKey.currentState!.validate()) {
                    // Validate the form before proceeding
                    if (connectionManager.connected) {
                      mqttManager?.disconnect();
                    } else {
                      _logger.info('DISCONNECT ELSE');
                      mqttManager?.connectToBroker(_brokerAddress, _brokerPort,
                          clientId: _clientId);
                    }
                  }
                },
                child: Text(
                    connectionManager.connected ? 'Disconnect' : 'Connect'),
              );
            },
          ),
        ],
      ),
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
            _clientId = value;
          },
        ),
      ),
    );
  }
}
