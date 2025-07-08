import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 209, 209),
      body: Center(
        child: Text('Settings Page', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
      ),
    );
  }
} 