import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String? profileImageUrl;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final username = user.email?.split('@')[0];
        if (username != null) {
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(username)
              .get();
          
          if (userDoc.exists && userDoc.data() != null) {
            setState(() {
              profileImageUrl = userDoc.data()!['profileImage'];
              isLoading = false;
            });
          } else {
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 209, 209),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isLoading)
                const CircularProgressIndicator()
              else
                CircleAvatar(
                  radius: 80,
                  backgroundColor: const Color(0xFFE7BFA7),
                  backgroundImage: profileImageUrl != null && profileImageUrl!.isNotEmpty
                      ? NetworkImage(profileImageUrl!)
                      : const AssetImage('assets/logo.png') as ImageProvider,
                ),
              const SizedBox(height: 20),
              const Text(
                'Settings Page',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 