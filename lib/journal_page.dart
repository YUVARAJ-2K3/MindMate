import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'journal_entry_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class JournalPage extends StatefulWidget {
  const JournalPage({Key? key}) : super(key: key);

  @override
  State<JournalPage> createState() => _JournalPageState();
}

class _JournalPageState extends State<JournalPage> {
  DateTime selectedDate = DateTime.now();
  final TextEditingController problemController = TextEditingController();
  String shoutout = '';
  String problem = '';
  String selectedIssue = 'Not Listening, Just Blaming';
  bool? feelBetter;
  bool showCongrats = false;
  bool hasEntry = false;
  String entryTitle = '';
  String entryDescription = '';
  int streak = 0;

  String? get userId {
    final user = FirebaseAuth.instance.currentUser;
    return user?.email?.split('@')[0];
  }

  @override
  void initState() {
    super.initState();
    _loadTodayJournal();
    _scheduleMidnightReset();
  }

  Future<void> _loadTodayJournal() async {
    if (userId == null) return;
    final todayKey = _dateKey(DateTime.now());
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(userId)
        .collection('journals').doc(todayKey).get();
    if (doc.exists) {
      setState(() {
        hasEntry = true;
        entryTitle = doc['title'] ?? '';
        entryDescription = doc['description'] ?? '';
        streak = doc['streak'] ?? 0;
        showCongrats = true;
      });
    } else {
      setState(() {
        hasEntry = false;
        entryTitle = '';
        entryDescription = '';
        showCongrats = false;
      });
    }
  }

  Future<void> _saveJournal(String title, String description, DateTime date) async {
    if (userId == null) return;
    final dateKey = _dateKey(date);
    int newStreak = await _calculateStreak(dateKey);
    await FirebaseFirestore.instance
        .collection('users').doc(userId)
        .collection('journals').doc(dateKey)
        .set({
      'title': title,
      'description': description,
      'date': dateKey,
      'streak': newStreak,
    });
    setState(() {
      hasEntry = true;
      entryTitle = title;
      entryDescription = description;
      streak = newStreak;
      showCongrats = true;
    });
  }

  Future<void> _loadJournalForDate(DateTime date) async {
    if (userId == null) return;
    final dateKey = _dateKey(date);
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(userId)
        .collection('journals').doc(dateKey).get();
    if (doc.exists) {
      setState(() {
        hasEntry = true;
        entryTitle = doc['title'] ?? '';
        entryDescription = doc['description'] ?? '';
        streak = doc['streak'] ?? 0;
        showCongrats = true;
      });
    } else {
      setState(() {
        hasEntry = false;
        entryTitle = '';
        entryDescription = '';
        showCongrats = false;
        streak = 0;
      });
    }
  }

  Future<int> _calculateStreak(String todayKey) async {
    if (userId == null) return 1;
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    final yesterdayKey = _dateKey(yesterday);
    final yesterdayDoc = await FirebaseFirestore.instance
        .collection('users').doc(userId)
        .collection('journals').doc(yesterdayKey).get();
    if (yesterdayDoc.exists) {
      int prevStreak = yesterdayDoc['streak'] ?? 0;
      // Check if yesterday's entry was consecutive
      return prevStreak + 1;
    } else {
      // Missed a day, reset streak
      return 1;
    }
  }

  void _scheduleMidnightReset() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);
    Future.delayed(duration, () async {
      setState(() {
        hasEntry = false;
        entryTitle = '';
        entryDescription = '';
        showCongrats = false;
        // Do not reset streak here, as it is managed by Firestore
      });
      _scheduleMidnightReset(); // Reschedule for the next day
      _loadTodayJournal(); // Load new day's journal
    });
  }

  String _dateKey(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  @override
  void dispose() {
    problemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 251, 213, 213),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Container(
                  width: double.infinity,
                  height: 180,
                  decoration: BoxDecoration(
                    color: Colors.pink[100],
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24),
                          child: Image.asset(
                            'assets/journal_bg.png',
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 45,
                        child: Center(
                          child: Text(
                            'Journal Space',
                            style: const TextStyle(
                              fontFamily: 'Puppies Play',
                              fontSize: 70,
                              color: Color(0xFF7B3F1D),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Journal Section
                    Row(
                      children: [
                        const Text(
                          'Journal',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color.fromARGB(255, 248, 200, 178),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star, color: Color(0xFFFFB300), size: 22),
                              SizedBox(width: 6),
                              Text(
                                'Write your heart out, this space\nhears without judgement',
                                style: TextStyle(fontSize: 12, color: Color(0xFF5A3A1B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFFDA8D7A),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      readOnly: true,
                                      controller: TextEditingController(
                                        text: DateFormat('MM/dd/yyyy').format(selectedDate),
                                      ),
                                      decoration: InputDecoration(
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: Color(0xFFDA8D7A), width: 1),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: Color(0xFFDA8D7A), width: 1),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(16),
                                          borderSide: const BorderSide(color: Color(0xFFDA8D7A), width: 2),
                                        ),
                                        suffixIcon: IconButton(
                                          icon: const Icon(Icons.calendar_today, size: 18, color: Color(0xFFDA8D7A)),
                                          onPressed: () async {
                                            DateTime? picked = await showDatePicker(
                                              context: context,
                                              initialDate: selectedDate,
                                              firstDate: DateTime(2000),
                                              lastDate: DateTime(2100),
                                            );
                                            if (picked != null) {
                                              setState(() {
                                                selectedDate = picked;
                                              });
                                              _loadJournalForDate(selectedDate);
                                            }
                                          },
                                        ),
                                      ),
                                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFDA8D7A),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                                      elevation: 0,
                                    ),
                                    onPressed: () {},
                                    child: const Text('View', style: TextStyle(fontSize: 15, color: Colors.white)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'MM/DD/YYYY',
                                style: TextStyle(fontSize: 10, color: Colors.black38, fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Scroll streak
                          LayoutBuilder(
                            builder: (context, constraints) {
                              double scrollWidth = constraints.maxWidth - 26; // 18px padding on each side
                              double scrollHeight = 1.5 * scrollWidth; // Adjust as needed for your image ratio

                              return Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Enlarged Scroll background
                                    Image.asset(
                                      'assets/scroll.png',
                                      width: scrollWidth,
                                      height: scrollHeight,
                                      fit: BoxFit.fill,
                                    ),
                                    // Content on top of scroll
                                    SizedBox(
                                      width: scrollWidth * 0.8, // Keep content within scroll area
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (showCongrats)
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(20),
                                                    border: Border.all(color: Colors.orange.shade200, width: 1),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: const [
                                                      Icon(Icons.local_fire_department, color: Colors.orange, size: 18),
                                                      SizedBox(width: 4),
                                                      Text('92', style: TextStyle(fontWeight: FontWeight.bold)),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                const Text(
                                                  'Great!\nEvery Feeling\nDeserves A Page',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                ),
                                              ],
                                            )
                                          else
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Fire streak
                                                Container(
                                                  margin: const EdgeInsets.only(bottom: 18),
                                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius: BorderRadius.circular(500),
                                                    border: Border.all(color: Colors.orange.shade200, width: 1),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: const [
                                                      Icon(Icons.local_fire_department, color: Colors.orange, size: 20),
                                                      SizedBox(width: 6),
                                                      Text('92', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                                    ],
                                                  ),
                                                ),
                                                const SizedBox(height: 18),
                                                const Text(
                                                  'Pending...\nLet\'s complete',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                                ),
                                              ],
                                            ),
                                          const SizedBox(height: 28),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFFD9A05B),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(80),
                                              ),
                                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 0),
                                            ),
                                            onPressed: () async {
                                              if (hasEntry) {
                                                // Edit mode
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => JournalEntryPage(
                                                      date: selectedDate,
                                                      title: entryTitle,
                                                      description: entryDescription,
                                                      readOnly: false,
                                                    ),
                                                  ),
                                                );
                                                if (result is Map) {
                                                  setState(() {
                                                    hasEntry = true;
                                                    entryTitle = result['title'] ?? '';
                                                    entryDescription = result['description'] ?? '';
                                                    showCongrats = true;
                                                  });
                                                  _saveJournal(entryTitle, entryDescription, selectedDate);
                                                }
                                              } else {
                                                // Write mode
                                                final result = await Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => JournalEntryPage(date: selectedDate),
                                                  ),
                                                );
                                                if (result is Map) {
                                                  setState(() {
                                                    hasEntry = true;
                                                    entryTitle = result['title'] ?? '';
                                                    entryDescription = result['description'] ?? '';
                                                    showCongrats = true;
                                                  });
                                                  _saveJournal(entryTitle, entryDescription, selectedDate);
                                                }
                                              }
                                            },
                                            child: Text(hasEntry ? 'Edit' : "Let's Write", style: const TextStyle(fontSize: 18, color: Colors.white)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Shoutout Section
                    Row(
                      children: [
                        const Text(
                          'Shoutout',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7C7B0),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            children: const [
                              Icon(Icons.star, color: Color(0xFFFFB300), size: 22),
                              SizedBox(width: 6),
                              Text(
                                'A safe space to unburden your\nheart.',
                                style: TextStyle(fontSize: 12, color: Color(0xFF5A3A1B)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Problem Corner',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            "What's Weighing on your Mind?",
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          TextField(
                            controller: problemController,
                            decoration: InputDecoration(
                              hintText: 'Type your problem here...',
                              filled: true,
                              fillColor: const Color(0xFFFFF8E1),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                  color: Color(0xFFDA8D7A),
                                  width: 2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
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
                              onPressed: () {},
                              child: const Text(
                                'Add',
                                style: TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Color(0xFFD9A05B)),
                            ),
                            child: Column(
                              children: [
                                const Text(
                                  'Do You Feel Better Now About',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedIssue,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFFD9A05B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDA8D7A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          feelBetter = true;
                                        });
                                      },
                                      child: const Text('Yes', style: TextStyle(fontSize: 15, color: Colors.white)),
                                    ),
                                    const SizedBox(width: 16),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFFDA8D7A),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(24),
                                        ),
                                        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          feelBetter = false;
                                        });
                                      },
                                      child: const Text('No', style: TextStyle(fontSize: 15, color: Colors.white)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 