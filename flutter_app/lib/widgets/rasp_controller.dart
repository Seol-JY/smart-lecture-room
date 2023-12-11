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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "선풍기 현재 단계 : ${BluetoothCommunicationService.fanStrengthLevel}단계",
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        Expanded(
          child: Center(
            child: Row(
              children: [
                const Text(
                  "선풍기 세기 제어",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () async {
                    bluetoothService
                        .increaseFanLevel()
                        .then((value) => setState(() {}));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 50), // 정사각형 크기
                  ),
                  child: const Text('+', style: TextStyle(fontSize: 20)),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () async {
                    bluetoothService
                        .decreaseFanLevel()
                        .then((value) => setState(() {}));
                  },
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(50, 50), // 정사각형 크기
                  ),
                  child: const Text('-', style: TextStyle(fontSize: 20)),
                ),
              ],
            ),
          ),
        ),
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
          child: Row(
        children: [
          const Text(
            "출석체크를 수행하시겠습니까?",
            style: TextStyle(fontSize: 20),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: doAttendCheck,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(30, 30), // 정사각형 크기
            ),
            child: const Text('OK', style: TextStyle(fontSize: 15)),
          ),
        ],
      ));
    }

    if (attendCheckResult == null) {
      return Container();
    }

    return Center(
      child: Text(
        "출석 체크한 인원은 $attendCheckResult명 입니다.",
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
