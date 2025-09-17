import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const FFAAApp());
}

class FFAAApp extends StatelessWidget {
  const FFAAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlutterFAA(随时随地查找)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
