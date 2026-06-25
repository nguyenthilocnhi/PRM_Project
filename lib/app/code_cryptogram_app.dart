import 'package:flutter/material.dart';
import 'package:project/features/screens/home_screen.dart';

class CryptogramApp extends StatelessWidget {
  const CryptogramApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Code Busters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
      ),
      home: const HomeScreen(),
    );
  }
}
