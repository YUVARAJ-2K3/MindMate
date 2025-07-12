import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';


class VaultPage extends StatefulWidget {
  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  Future<String> getLastViewed() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return 'Never';
    final username = user!.email!.split('@')[0];
    final doc = await FirebaseFirestore.instance.collection('users').doc(username).get();
    final ts = doc.data()?['vaultLastViewed'];
    if (ts == null) return 'Never';
    DateTime dt;
    if (ts is Timestamp) {
      dt = ts.toDate();
    } else if (ts is DateTime) {
      dt = ts;
    } else {
      return 'Never';
    }
    return DateFormat('dd MMMM, yyyy | HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 230, 230),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Header image
              Stack(
                children: [
                  Container(
                    width: double.infinity,
                    height: 180,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/vaultbg.png'),
                        fit: BoxFit.cover,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Column(
                      children: [
                        Material(
                          color: Color.fromARGB(255, 254, 230, 230),
                          borderRadius: BorderRadius.circular(8),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (context) => HomePage()),
                                (route) => false,
                              );
                            },
                            child: SizedBox(
                              width: 30,
                              height: 30,
                              child: Center(
                                child: Icon(Icons.logout, color: Colors.pinkAccent, size: 25),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text('Logout', style: TextStyle(color: Color.fromARGB(255, 254, 230, 230), fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ],
              ),
              // Vault and last viewed
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Text(
                      'Vault',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFF8E1),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: FutureBuilder<String>(
                        future: getLastViewed(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text('Last viewed : ...', style: TextStyle(fontSize: 14, color: Colors.black87));
                          }
                          return Text(
                            'Last viewed : ${snapshot.data ?? 'Never'}',
                            style: TextStyle(fontSize: 14, color: Colors.black87),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              // Voice Notes Section
              _SectionHeader(
                icon: Icons.star,
                text: '    The things you say today \n become memories tomorrow',
                title: 'Voice Notes',
                color: Color(0xFFFAD6C9),
              ),
              _VaultSectionCard(
                child: Column(
                  children: [
                    _SearchBar(),
                    SizedBox(height: 8),
                    _VoiceNoteItem(title: 'Harini Voice', date: '22-06-25', duration: '0:10'),
                    SizedBox(height: 8),
                    _VoiceNoteItem(title: 'Sree Voice', date: '22-06-25', duration: '1:20'),
                    SizedBox(height: 8),
                    _ViewAllButton(),
                  ],
                ),
              ),
              // Images Section
              _SectionHeader(
                icon: Icons.star,
                text: 'A picture that heals,\nA memory that hugs',
                title: 'Images',
                color: Color(0xFFFAD6C9),
              ),
              _VaultSectionCard(
                child: Column(
                  children: [
                    _SearchBar(),
                    SizedBox(height: 8),
                    _HorizontalList(
                      items: [
                        _ImageItem(label: 'Panda', date: '22 Jun,2025', asset: 'assets/panda.png'),
                        _ImageItem(label: 'Kitty', date: '22 Jun,2025', asset: 'assets/kitty.png'),
                        _ImageItem(label: 'Monkey', date: '22 Jun,2025', asset: 'assets/monkey.png'),
                        _ImageItem(label: 'Iron man', date: '22 Jun,2025', asset: 'assets/ironman.png'),
                      ],
                    ),
                    _ViewAllButton(),
                  ],
                ),
              ),
              // Videos Section
              _SectionHeader(
                icon: Icons.star,
                text: "Your life's best scenes,\nsaved securely",
                title: 'Videos',
                color: Color(0xFFFAD6C9),
              ),
              _VaultSectionCard(
                child: Column(
                  children: [
                    _SearchBar(),
                    SizedBox(height: 8),
                    _HorizontalList(
                      items: [
                        _VideoItem(label: 'Panda', date: '22 Jun,2025', asset: 'assets/panda.png'),
                        _VideoItem(label: 'Kitty', date: '22 Jun,2025', asset: 'assets/kitty.png'),
                        _VideoItem(label: 'Monkey', date: '22 Jun,2025', asset: 'assets/monkey.png'),
                        _VideoItem(label: 'Iron man', date: '22 Jun,2025', asset: 'assets/ironman.png'),
                      ],
                    ),
                    _ViewAllButton(),
                  ],
                ),
              ),
              SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String text;
  final String title;
  final Color color;
  const _SectionHeader({required this.icon, required this.text, required this.title, required this.color});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, top: 18, bottom: 4),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: Colors.amber),
                SizedBox(width: 4),
                Text(
                  text,
                  style: TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _VaultSectionCard extends StatelessWidget {
  final Widget child;
  const _VaultSectionCard({required this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(24),
      ),
      child: child,
    );
  }
}

class _SearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: Icon(Icons.search, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(vertical: 3, horizontal: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        suffixIcon: Icon(Icons.add, color: Colors.pinkAccent),
      ),
      style: TextStyle(fontSize: 14),
    );
  }
}

class _VoiceNoteItem extends StatelessWidget {
  final String title;
  final String date;
  final String duration;
  const _VoiceNoteItem({required this.title, required this.date, required this.duration});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Color(0xFFFDE7EF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.play_arrow, color: Colors.pinkAccent),
          SizedBox(width: 10),
          Expanded(
            child: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          Text(date, style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(width: 10),
          Text(duration, style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(width: 6),
          Icon(Icons.more_vert, color: Colors.grey),
        ],
      ),
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final List<Widget> items;
  const _HorizontalList({required this.items});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => SizedBox(width: 12),
        itemBuilder: (context, i) => items[i],
      ),
    );
  }
}

class _ImageItem extends StatelessWidget {
  final String label;
  final String date;
  final String asset;
  const _ImageItem({required this.label, required this.date, required this.asset});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFFFDE7EF),
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
        Text(date, style: TextStyle(fontSize: 10, color: Colors.grey)),
      ],
    );
  }
}

class _VideoItem extends StatelessWidget {
  final String label;
  final String date;
  final String asset;
  const _VideoItem({required this.label, required this.date, required this.asset});
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Color(0xFFFDE7EF),
            borderRadius: BorderRadius.circular(16),
            image: DecorationImage(
              image: AssetImage(asset),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Icon(Icons.play_circle_fill, color: Colors.black54, size: 32),
        Positioned(
          bottom: 0,
          child: Column(
            children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
              Text(date, style: TextStyle(fontSize: 10, color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ViewAllButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: Text(
          'View All',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
} 