import 'package:flutter/material.dart';

class VaultPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vault'),
      ),
      body: Center(
        child: Text(
          'Welcome to your Vault!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
} 