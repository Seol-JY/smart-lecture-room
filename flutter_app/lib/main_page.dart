import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:serial_test/widgets/custom_appbar.dart';

import 'services/background_collecting_task.dart';
import 'bouded_device_list.dart';

// import './helpers/LineChart.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  _MainPage createState() => _MainPage();
}

class _MainPage extends State<MainPage> {
  Timer? _discoverableTimeoutTimer;

  BackgroundCollectingTask? _collectingTask;

  @override
  void initState() {
    super.initState();

    Future.doWhile(() async {
      // Wait if adapter not enabled
      if ((await FlutterBluetoothSerial.instance.isEnabled) ?? false) {
        return false;
      }
      await Future.delayed(const Duration(milliseconds: 0xDD));
      return true;
    }).then((_) {});
  }

  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    _collectingTask?.dispose();
    _discoverableTimeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
        appBar: CustomAppBar(),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(children: [
              SizedBox(
                height: 20,
              ),
              Center(
                child: Text(
                  "주변 연결 가능한 강의실",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Expanded(child: BoundedDeviceList(checkAvailability: false)),
            ]),
          ),
        ));
  }
}
