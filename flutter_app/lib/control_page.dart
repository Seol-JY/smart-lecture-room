import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:serial_test/services/bluetooth_service.dart';
import 'package:serial_test/widgets/custom_appbar.dart';
import 'package:serial_test/widgets/rasp_controller.dart';
import 'dart:async';

import 'package:serial_test/widgets/slide_to_act.dart';

class ControlPage extends StatefulWidget {
  final BluetoothDevice server;

  const ControlPage({Key? key, required this.server}) : super(key: key);

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
          padding: const EdgeInsets.all(6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: 25,
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      serverName,
                      style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 6,
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10),
                child: isConnecting
                    ? Row(
                        children: [
                          Container(
                              margin: EdgeInsets.only(left: 4),
                              width: 12.0, // Set the desired width
                              height: 12.0, // Set the desired height
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                                strokeWidth: 3.0,
                              )),
                          SizedBox(width: 10),
                          Text(
                            "연결중...",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: const Color.fromARGB(255, 78, 78, 78),
                            ),
                          ),
                        ],
                      )
                    : isConnected
                        ? Row(
                            children: [
                              Icon(
                                size: 16,
                                Icons.check_circle,
                                color: Colors.green,
                              ),
                              Text(
                                " 연결됨",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color.fromARGB(141, 0, 0,
                                      0), // Change color for connected state
                                ),
                              ),
                            ],
                          )
                        : Text(
                            "연결 해제됨",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors
                                  .red, // Change color for disconnected state
                            ),
                          ),
              ),
              SizedBox(
                height: 25,
              ),
              const Divider(
                height: 24,
                thickness: 1,
                color: Color.fromARGB(255, 221, 221, 221),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatusWidget(
                    icon: Icons.thermostat,
                    label: "온도",
                    value: "$currentTemperature ℃",
                    color: Color.fromARGB(255, 255, 37, 37),
                  ),
                  _buildStatusWidget(
                    icon: Icons.opacity,
                    label: "습도",
                    value: "$currentHumidity %",
                    color: Color.fromARGB(255, 38, 96, 255),
                  ),
                ],
              ),
              const Divider(
                height: 24,
                thickness: 1,
                color: Color.fromARGB(255, 221, 221, 221),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          controlWidgetKey = "ATTEND";
                        });
                      },
                      style: ButtonStyle(
                        padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 14),
                        ),
                        backgroundColor: MaterialStatePropertyAll(
                          controlWidgetKey == "ATTEND"
                              ? Colors.blue
                              : Color.fromARGB(255, 185, 185, 185),
                        ),
                      ),
                      child: Text(
                        "출석 체크",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16), // Adjust the spacing between buttons
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          controlWidgetKey = "FAN";
                        });
                      },
                      style: ButtonStyle(
                        padding: MaterialStatePropertyAll(
                          EdgeInsets.symmetric(vertical: 14),
                        ),
                        backgroundColor: MaterialStatePropertyAll(
                          controlWidgetKey == "FAN"
                              ? Colors.blue
                              : Color.fromARGB(255, 185, 185, 185),
                        ),
                      ),
                      child: Text(
                        "선풍기 제어",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              controlWidget,
              SlideAction(
                text: "밀어서 연결 해제",
                elevation: 0,
                height: 56,
                borderRadius: 10,
                onSubmit: _onExit,
                sliderRotate: false,
                sliderButtonIconSize: 24,
                sliderButtonIconPadding: 14,
                textColor: const Color.fromARGB(255, 65, 65, 65),
                outerColor: Color.fromARGB(255, 230, 230, 230),
                innerColor: Color.fromARGB(255, 53, 53, 53),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusWidget({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB(221, 37, 37, 37),
          ),
        ),
        SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color.fromARGB(221, 48, 48, 48),
          ),
        ),
      ],
    );
  }

  void _updateTemperHumid() {
    if (!isConnected) return;
    setState(() {
      isConnecting = false;
    });
    bluetoothService.getTemperHumidFromCurrentClass().then((value) => {
          setState(() {
            currentTemperature = value.temperature;
            currentHumidity = value.humidity;
          })
        });
  }

  Future<void> _onExit() async {
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
