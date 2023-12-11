import 'package:flutter/material.dart';

import 'main_page.dart';

void main() => runApp(const SmartClassApplication());

class SmartClassApplication extends StatelessWidget {
  const SmartClassApplication({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(home: MainPage());
  }
}
