import 'package:flutter/material.dart';
import 'custom_snackbar.dart';
import 'mom_page.dart';
import 'dad_page.dart';

class RegFavPage extends StatefulWidget {
  const RegFavPage({super.key});

  @override
  State<RegFavPage> createState() => _RegFavPageState();
}

class _RegFavPageState extends State<RegFavPage> {
  String? _selectedPerson;
  final TextEditingController _otherController = TextEditingController();

  final List<Map<String, String>> _options = [
    {'label': 'Mom', 'emoji': '👩‍👧'},
    {'label': 'Dad', 'emoji': '👨‍👧'},
    {'label': 'Siblings', 'emoji': '👫'},
    {'label': 'Best Friend', 'emoji': '🧑‍🤝‍🧑'},
    {'label': 'Love', 'emoji': '💑'},
    {'label': 'Grandparents', 'emoji': '👵👴'},
    {'label': 'Others', 'emoji': ''},
  ];

  @override
  void dispose() {
    _otherController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE), // Light pink
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 37),
                const Center(
                  child: Text(
                    'Select Your Comfort Person',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 29),
                ..._options.map(
                  (option) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3.0),
                    child: Row(
                      children: [
                        Radio<String>(
                          value: option['label']!,
                          groupValue: _selectedPerson,
                          onChanged: (value) {
                            setState(() {
                              _selectedPerson = value;
                            });
                          },
                        ),
                        Text(
                          option['label']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 9),
                        Text(
                          option['emoji']!,
                          style: const TextStyle(fontSize: 23),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_selectedPerson == 'Others')
                  Padding(
                    padding: const EdgeInsets.only(top: 9.0, bottom: 5.0),
                    child: TextField(
                      controller: _otherController,
                      style: const TextStyle(fontSize: 11),
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Color(0xFFFFF8E1),
                        hintText: 'If others, please enter the person',
                        hintStyle: TextStyle(fontSize: 11),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(16)),
                          borderSide: BorderSide(
                            color: Color(0xFFDA8D7A),
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 21),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDA8D7A),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 57,
                        vertical: 13,
                      ),
                    ),
                    onPressed: () {
                      String selected = _selectedPerson == 'Others'
                          ? _otherController.text.trim()
                          : _selectedPerson ?? '';
                      if (selected.isEmpty) {
                        showCustomSnackBar(
                          context,
                          'Please select or enter a person.',
                          icon: Icons.info_outline,
                        );
                      } else if (selected == 'Dad') {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const DadPage()),
                        );
                      } else {
                        showCustomSnackBar(
                          context,
                          'You selected: ' + selected,
                          icon: Icons.check_circle_outline,
                        );
                      }
                    },
                    child: const Text(
                      'Done',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 29),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline,
                      size: 16,
                      color: Color(0xFF7B7B7B),
                    ),
                    SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        'Your information is private and protected.\n We\'re here for your peace of mind.',
                        style: TextStyle(
                          fontSize: 10,
                          color: Color(0xFF7B7B7B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
