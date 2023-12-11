import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      title: const Text(
        "스마트 강의실",
        style: TextStyle(
          fontWeight: FontWeight.w600, // 굵게 설정

          fontSize: 18.0, // 글꼴 크기 설정
          // 기타 텍스트 스타일 속성들...
        ),
      ),
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
