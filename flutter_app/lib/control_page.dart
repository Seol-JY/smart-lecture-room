import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:serial_test/services/bluetooth_service.dart';
import 'package:serial_test/widgets/custom_appbar.dart';
import 'package:serial_test/widgets/rasp_controller.dart';
import 'dart:async';

class ControlPage extends StatefulWidget {
  final BluetoothDevice server;

  const ControlPage({super.key, required this.server});

  @override
  _ControlPageState createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  BluetoothConnection? connection;
  double currentTemperature = 0.0;
  double currentHumidity = 0.0;
  String controlWidgetKey = "default";
  bool isConnecting = true;
  bool get isConnected =>
      (BluetoothCommunicationService.connection?.isConnected ?? false);

  bool isDisconnecting = false;

  late Timer timer;

  @override
  void initState() {
    super.initState();

    BluetoothConnection.toAddress(widget.server.address).then((connection) {
      BluetoothCommunicationService.connection = connection;
      bluetoothService.setLED(0);
      setState(() {
        isConnecting = false;
        isDisconnecting = false;
      });

      BluetoothCommunicationService.connection!.input!
          .listen(bluetoothService.onDataReceived)
          .onDone(() {
        if (mounted) {
          setState(() {});
        }
      });
    }).catchError((error) {});

    timer = Timer.periodic(
        const Duration(seconds: 5), (Timer t) => _updateTemperHumid());
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget controlWidget = ControlWidgetFactory.createWidget(controlWidgetKey);

    final serverName = widget.server.name ?? "Unknown";
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                "강의실 : $serverName",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.grey,
              ),
              Text(
                isConnecting
                    ? "연결 상태 : Connecting..."
                    : isConnected
                        ? "연결 상태 : Connected"
                        : "연결 상태 : DisConnected",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.grey,
              ),
              Text(
                "현재 온도 : $currentTemperature ℃",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.grey,
              ),
              Text(
                "현재 습도 : $currentHumidity %",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
              ),
              const Divider(
                height: 20,
                thickness: 1,
                color: Colors.grey,
              ),
              controlWidget,
              TextButton(
                onPressed: () {
                  setState(() {
                    controlWidgetKey = "ATTEND";
                  });
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.blue,
                  ),
                ),
                child: const Text(
                  "출석체크",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    controlWidgetKey = "FAN";
                  });
                },
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.blue,
                  ),
                ),
                child: const Text(
                  "선풍기 제어",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              TextButton(
                onPressed: _onExit,
                style: const ButtonStyle(
                  backgroundColor: MaterialStatePropertyAll(
                    Colors.blue,
                  ),
                ),
                child: const Text(
                  "연결 종료",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateTemperHumid() {
    if (!isConnected) return;
    bluetoothService.getTemperHumidFromCurrentClass().then((value) => {
          setState(() {
            currentTemperature = value.temperature;
            currentHumidity = value.humidity;
          })
        });
  }

  void _onExit() async {
    await _disconnect();
    Navigator.of(context).pop();
  }

  Future<void> _disconnect() async {
    // Avoid memory leak (`setState` after dispose) and disconnect
    if (isConnected) {
      await bluetoothService.disconnect();
      isDisconnecting = true;
      connection?.dispose();
      connection = null;
    }
  }
}
