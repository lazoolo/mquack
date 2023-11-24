import 'package:flutter/material.dart';
import 'navigation.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

class LogManager {
  final List<LogRecord> logs = [];

  void Function(LogRecord log)? onLog;

  LogManager() {
    Logger.root.onRecord.listen((record) {
      logs.add(record);
      onLog?.call(record);
    });
  }
}

class LogsPage extends StatefulWidget {
  @override
  _LogsPageState createState() => _LogsPageState();
}

class _LogsPageState extends State<LogsPage> {
  late final LogManager logManager;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    logManager = Provider.of<LogManager>(context, listen: false);
    logManager.onLog = (log) {
      setState(() {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      currentIndex: 2,
      body: ListView.builder(
        controller: _scrollController,
        itemCount: logManager.logs.length,
        itemBuilder: (context, index) {
          final log = logManager.logs[index];
          return ListTile(
            title: Text('${log.level.name}: ${log.time}: ${log.message}'),
          );
        },
      ),
    );
  }
}
