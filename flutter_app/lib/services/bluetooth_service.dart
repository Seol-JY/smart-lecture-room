import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:collection';

import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:serial_test/domains/temper_and_humid.dart';

class BluetoothCommunicationService {
  BluetoothCommunicationService._privateConstructor();
  static String messageBuffer = '';
  static final BluetoothCommunicationService _instance =
      BluetoothCommunicationService._privateConstructor();

  static BluetoothCommunicationService get instance => _instance;

  static Queue<int> increseFanQueue = Queue<int>();
  static Queue<int> decreseFanQueue = Queue<int>();
  static Queue<int> attendCheckQueue = Queue<int>();
  static Queue<TemperHumid> temperHumidQueue = Queue<TemperHumid>();

  static int fanStrengthLevel = 0;

  static BluetoothConnection? connection;

  void setLED(int value) {
    _sendMessage("s$value");
  }

  Future<TemperHumid> getTemperHumidFromCurrentClass() async {
    await _sendMessage("t");

    Completer<TemperHumid> completer = Completer<TemperHumid>();

    // 큐에 값이 들어오면 Completer를 완료시키는 로직
    void checkQueue() {
      if (temperHumidQueue.isNotEmpty) {
        TemperHumid result = temperHumidQueue.removeFirst();

        completer.complete(result);
      } else {
        // 큐가 비어있다면, 잠시 후 다시 확인
        Future.delayed(const Duration(milliseconds: 100), checkQueue);
      }
    }

    // 큐 확인 시작
    checkQueue();

    // Completer의 Future를 반환하고, 완료될 때까지 기다림
    return completer.future;
  }

  Future<void> disconnect() async {
    await _sendMessage("q");

    connection?.close();
  }

  Future<int> increaseFanLevel() async {
    if (fanStrengthLevel < 4) {
      fanStrengthLevel += 1;
    }
    await _sendMessage("i$fanStrengthLevel");

    Completer<int> completer = Completer<int>();

    // 큐에 값이 들어오면 Completer를 완료시키는 로직
    void checkQueue() {
      if (increseFanQueue.isNotEmpty) {
        fanStrengthLevel = increseFanQueue.removeFirst();
        completer.complete(fanStrengthLevel);
      } else {
        // 큐가 비어있다면, 잠시 후 다시 확인
        Future.delayed(const Duration(milliseconds: 100), checkQueue);
      }
    }

    // 큐 확인 시작
    checkQueue();

    // Completer의 Future를 반환하고, 완료될 때까지 기다림
    return completer.future;
  }

  Future<int> decreaseFanLevel() {
    if (fanStrengthLevel > 0) {
      fanStrengthLevel -= 1;
    }
    _sendMessage("d$fanStrengthLevel");
    Completer<int> completer = Completer<int>();

    // 큐에 값이 들어오면 Completer를 완료시키는 로직
    void checkQueue() {
      if (decreseFanQueue.isNotEmpty) {
        fanStrengthLevel = decreseFanQueue.removeFirst();
        completer.complete(fanStrengthLevel);
      } else {
        // 큐가 비어있다면, 잠시 후 다시 확인
        Future.delayed(const Duration(milliseconds: 100), checkQueue);
      }
    }

    // 큐 확인 시작
    checkQueue();

    // Completer의 Future를 반환하고, 완료될 때까지 기다림
    return completer.future;
  }

  Future<int> doAttendCheck() {
    _sendMessage("a");

    Completer<int> completer = Completer<int>();

    // 큐에 값이 들어오면 Completer를 완료시키는 로직
    void checkQueue() {
      if (attendCheckQueue.isNotEmpty) {
        int result = attendCheckQueue.removeFirst();

        completer.complete(result);
      } else {
        // 큐가 비어있다면, 잠시 후 다시 확인
        Future.delayed(const Duration(milliseconds: 100), checkQueue);
      }
    }

    // 큐 확인 시작
    checkQueue();

    // Completer의 Future를 반환하고, 완료될 때까지 기다림
    return completer.future;
  }

  Future<void> _sendMessage(String text) async {
    text = text.trim();

    if (text.isNotEmpty) {
      try {
        connection!.output.add(Uint8List.fromList(utf8.encode("$text\r\n")));
        await connection!.output.allSent;
      } catch (e) {}
    }
  }

  void onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    for (var byte in data) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    }
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      String message = backspacesCounter > 0
          ? messageBuffer.substring(0, messageBuffer.length - backspacesCounter)
          : messageBuffer + dataString.substring(0, index);

      messageBuffer = dataString.substring(index);

      _addResponseInQueue(message.trim());
    } else {
      messageBuffer = (backspacesCounter > 0
          ? messageBuffer.substring(0, messageBuffer.length - backspacesCounter)
          : messageBuffer + dataString);
    }
  }

  void _addResponseInQueue(String response) {
    if (response.startsWith(RegExp(r't\{([0-9.]+),([0-9.]+)\}'))) {
      RegExp exp2 = RegExp(r't\{([0-9.]+),([0-9.]+)\}');
      var matches2 = exp2.firstMatch(response);

      TemperHumid value = TemperHumid(
          temperature: double.parse(matches2?.group(1) ?? "0.0"),
          humidity: double.parse(matches2?.group(2) ?? "0.0"));

      temperHumidQueue.add(value);
      return;
    }

    RegExp lettersRegExp = RegExp(r'[a-zA-Z]+');
    RegExp digitsRegExp = RegExp(r'\d+');

    String command = lettersRegExp.stringMatch(response) ?? "";
    String value = digitsRegExp.stringMatch(response) ?? "";
    if (command == "i") {
      increseFanQueue.add(int.parse(value));
    }
    if (command == "d") {
      decreseFanQueue.add(int.parse(value));
    }
    if (command == "a") {
      attendCheckQueue.add(int.parse(value));
    }
  }
}
