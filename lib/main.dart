// lib/main.dart

import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(DayTaskApp());
}

class DayTaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DayTask App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LoginPage(),
    );
  }
}
