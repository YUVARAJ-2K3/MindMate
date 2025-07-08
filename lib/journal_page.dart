import 'package:flutter/material.dart';

class JournalPage extends StatelessWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 209, 209),
      body: Center(
        child: Text('Journal Page', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      ),
    );
  }
} 