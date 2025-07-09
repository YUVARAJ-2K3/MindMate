import 'package:flutter/material.dart';

class VaultPasswordPage extends StatefulWidget {
  const VaultPasswordPage({Key? key}) : super(key: key);

  @override
  State<VaultPasswordPage> createState() => _VaultPasswordPageState();
}

class _VaultPasswordPageState extends State<VaultPasswordPage> {
  bool _obscureText = true;
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFEBEE),
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative leaves (optional, add if you have assets)
            Positioned(
              top: 0,
              left: 0,
              child: Image.asset(
                'assets/leaf_top_left.png',
                width: 120,
                height: 120,
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Image.asset(
                'assets/leaf_top_right.png',
                width: 120,
                height: 120,
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: Image.asset(
                'assets/leaf_bottom_left.png',
                width: 120,
                height: 120,
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Image.asset(
                'assets/leaf_bottom_right.png',
                width: 120,
                height: 120,
              ),
            ),
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title and subtitle
                    Row(
                      children: [
                        const Text(
                          'Vault',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFAD6C9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Treasures of your heart,\nprotected here 💖',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    // Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(32),
                      ),
                      child: Column(
                        children: [
                          // Panda user icon and welcome
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 32,
                                backgroundColor: const Color(0xFFD1A1A1),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/panda.png',
                                    width: 56,
                                    height: 56,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Text.rich(
                                  TextSpan(
                                    text: 'Welcome Back ',
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.black,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: 'Panda',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(text: ','),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Password field
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscureText,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFFFE0F0),
                              hintText: 'Password',
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFFB39DDB),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureText
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureText = !_obscureText;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 0,
                                horizontal: 16,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Unlock button
                          SizedBox(
                            width: double.infinity,
                            height: 48,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFDA8D7A),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                elevation: 0,
                              ),
                              child: const Text(
                                'Unlock Now',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Privacy note
                          const Row(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                size: 18,
                                color: Color(0xFFB0AEB1),
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Your information is private and protected.\nYour secrets are safe here. We\'ve got your back',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF7B7B7B),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Fingerprint icon
                          Icon(
                            Icons.fingerprint,
                            size: 48,
                            color: Colors.black87,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom navigation bar
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFFEBEE),
          border: Border(top: BorderSide(color: Color(0xFFDA8D7A), width: 1)),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavItem(Icons.home, 'Home', false),
            _buildNavItem(Icons.menu_book, 'Journal', false),
            _buildNavItem(Icons.safety_check, 'Vault', true),
            _buildNavItem(Icons.settings, 'Settings', false),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool selected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          size: 32,
          color: selected ? const Color(0xFFDA8D7A) : Colors.grey,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFFDA8D7A) : Colors.grey,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
