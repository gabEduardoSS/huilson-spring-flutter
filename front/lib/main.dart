import 'package:flutter/material.dart';
import 'package:front/loginPage.dart';

void main() {
  runApp(const PdvApp());
}

class PdvApp extends StatelessWidget {
  const PdvApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDV',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x008071C5)),
      ),
      home: const LoginPage(),
    );
  }
}
