import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:serial_test/widgets/custom_appbar.dart';

import 'services/background_collecting_task.dart';
import 'bouded_device_list.dart';

// import './helpers/LineChart.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

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

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("강의실 연결 안내"),
          content: Text(
              "페어링된 기기 목록에서 원하는 강의실을 선택하세요. \n\n설정 > 블루투스에서 디바이스를 등록해야 합니다."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("확인"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(6),
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10, right: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "연결할 강의실 선택",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                    GestureDetector(
                      onTap: _showInfoDialog,
                      child: Icon(
                        Icons.info,
                        color: Color.fromARGB(255, 146, 146, 146),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                alignment: Alignment.centerLeft,
                margin: EdgeInsets.only(left: 10),
                child: Text(
                  "페어링된 기기 목록에서 선택하세요.",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color.fromARGB(255, 78, 78, 78)),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              Divider(
                height: 2,
                thickness: 0.5,
                color: Color.fromARGB(255, 211, 211, 211),
              ),
              SizedBox(
                height: 5,
              ),
              Expanded(child: BoundedDeviceList(checkAvailability: false)),
            ],
          ),
        ),
      ),
    );
  }
}
