import 'package:serial_test/services/bluetooth_service.dart';
import 'package:flutter/material.dart';

BluetoothCommunicationService bluetoothService =
    BluetoothCommunicationService.instance;

class ControlWidgetFactory {
  static RaspberryControlWidget createWidget(String? value) {
    if (value == "FAN") {
      return const FanControlWidget();
    }
    if (value == "ATTEND") {
      return const AttendCheckControlWidget();
    } else {
      return const DefaultControlWidget();
    }
  }
}

abstract class RaspberryControlWidget extends StatefulWidget {
  const RaspberryControlWidget({Key? key}) : super(key: key);

  @override
  RaspberryControlWidgetState createState();
}

abstract class RaspberryControlWidgetState
    extends State<RaspberryControlWidget> {
  Widget buildContent(BuildContext context);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: buildContent(context),
    );
  }
}

class DefaultControlWidget extends RaspberryControlWidget {
  const DefaultControlWidget({super.key});

  @override
  _DefaultControlWidgetState createState() => _DefaultControlWidgetState();
}

class _DefaultControlWidgetState extends RaspberryControlWidgetState {
  @override
  Widget buildContent(BuildContext context) {
    return Container();
  }
}

class FanControlWidget extends RaspberryControlWidget {
  const FanControlWidget({super.key});

  @override
  _FanControlWidgetState createState() => _FanControlWidgetState();
}

class _FanControlWidgetState extends RaspberryControlWidgetState {
  @override
  Widget buildContent(BuildContext context) {
    int fanStrengthLevel = BluetoothCommunicationService.fanStrengthLevel;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Spacer(),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Icon(
                Icons.air_outlined,
                color: const Color.fromARGB(255, 95, 95, 95),
                size: 90,
              ),
              Text(
                fanStrengthLevel == 0 ? "꺼짐" : "$fanStrengthLevel 단계",
                style: const TextStyle(
                  fontSize: 20,
                  color: Color.fromARGB(255, 71, 71, 71),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Spacer(),
                  Row(
                      children: List.generate(
                    4,
                    (index) => Icon(
                      index < fanStrengthLevel
                          ? Icons.circle
                          : Icons.circle_outlined,
                      color: Color.fromARGB(255, 126, 126, 126),
                      size: 30,
                    ),
                  )),
                  Spacer(),
                ],
              )
            ],
          ),
        ),
        Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  bluetoothService
                      .decreaseFanLevel()
                      .then((value) => setState(() {}));
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(40, 40),
                ),
                child: Icon(Icons.remove, size: 20),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: () async {
                    bluetoothService
                        .increaseFanLevel()
                        .then((value) => setState(() {}));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(40, 40),
                  ),
                  child: Icon(Icons.add, size: 20)),
            ],
          ),
        ),
        Spacer(),
      ],
    );
  }
}

class AttendCheckControlWidget extends RaspberryControlWidget {
  const AttendCheckControlWidget({super.key});

  @override
  _AttendCheckControlWidgetState createState() =>
      _AttendCheckControlWidgetState();
}

class _AttendCheckControlWidgetState extends RaspberryControlWidgetState {
  bool _isLoading = false;
  Widget? _currentWidget;

  @override
  Widget buildContent(BuildContext context) {
    Widget currentWidget =
        _currentWidget ??= showAttendControlWidget(true, null);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : currentWidget;
  }

  void doAttendCheck() {
    setState(() {
      _isLoading = true;
    });
    bluetoothService.doAttendCheck().then((value) => setState(() {
          _isLoading = false;
          _currentWidget = showAttendControlWidget(false, value);
        }));
  }

  Widget showAttendControlWidget(bool isStart, int? attendCheckResult) {
    if (isStart) {
      return Center(
          child: Column(
        children: [
          const Spacer(),
          Icon(
            Icons.people_alt_outlined,
            color: const Color.fromARGB(255, 95, 95, 95),
            size: 90,
          ),
          const Text(
            "출석체크를 수행하시겠습니까?",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: doAttendCheck,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(80, 40), // 정사각형 크기
            ),
            child: const Text('수행', style: TextStyle(fontSize: 18)),
          ),
          const Spacer(),
        ],
      ));
    }

    if (attendCheckResult == null) {
      return Container();
    }

    return Center(
      child: Column(
        children: [
          Spacer(),
          Icon(
            Icons.people_alt_outlined,
            color: const Color.fromARGB(255, 95, 95, 95),
            size: 90,
          ),
          Text(
            "강의실 총 인원은 $attendCheckResult명 입니다.",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          Spacer(),
        ],
      ),
    );
  }
}
