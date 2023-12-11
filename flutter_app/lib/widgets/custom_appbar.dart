import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text("스마트 강의실"),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
