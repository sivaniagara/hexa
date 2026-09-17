import 'package:flutter/material.dart';
import 'draw_your_site.dart';

void main() {
  runApp(const PumpConfigApp());
}

class PumpConfigApp extends StatelessWidget {
  const PumpConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Draw Your Site',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF1565C0),
        useMaterial3: true,
      ),
      home: const DrawYourSiteScreen(),
    );
  }
}
