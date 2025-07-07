import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'scheduler_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Checklist state
  List<bool> checklist = [false, false, false, false, false];
  List<String> checklistItems = [
    'Drank enough water 💧',
    'Slept well last night 🛌',
    'Did one thing just for me 😉',
    'Got some fresh air and sunlight 🏝️',
    'Exercised well 🧘‍♂️',
  ];

  // Scheduler state
  List<String> times = ['9.00', '10.00', '11.00'];
  Map<String, String> schedule = {};
  final Map<String, TextEditingController> controllers = {
    '9.00': TextEditingController(),
    '10.00': TextEditingController(),
    '11.00': TextEditingController(),
  };

  // Calendar state
  DateTime selectedDate = DateTime.now();
  Map<int, Map<String, dynamic>> moodData = {
    1: {'emoji': '😃', 'percent': 90},
    2: {'emoji': '😡', 'percent': 60},
    3: {'emoji': '😕', 'percent': 35},
    4: {'emoji': '😊', 'percent': 85},
    5: {'emoji': '😁', 'percent': 95},
    6: {'emoji': '😃', 'percent': 90},
    7: {'emoji': '😡', 'percent': 60},
    8: {'emoji': '😕', 'percent': 35},
    9: {'emoji': '😊', 'percent': 85},
    10: {'emoji': '😁', 'percent': 95},
    11: {'emoji': '😢', 'percent': 90},
  };

  // 1. Add state for selected month and year
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;

  // 2. Helper for month name
  String getMonthName(int month) {
    return DateFormat('MMMM').format(DateTime(0, month));
  }

  // 3. Mood chart mapping
  final List<Map<String, dynamic>> moodChart = [
    {'min': 0, 'max': 10, 'emoji': '😭'},
    {'min': 10, 'max': 20, 'emoji': '😳'},
    {'min': 20, 'max': 30, 'emoji': '😨'},
    {'min': 30, 'max': 40, 'emoji': '😟'},
    {'min': 40, 'max': 50, 'emoji': '😐'},
    {'min': 50, 'max': 60, 'emoji': '🙂'},
    {'min': 60, 'max': 70, 'emoji': '😊'},
    {'min': 70, 'max': 80, 'emoji': '😃'},
    {'min': 80, 'max': 90, 'emoji': '😄'},
    {'min': 90, 'max': 101, 'emoji': '🥳'},
  ];
  String getEmojiForPercent(int percent) {
    for (final entry in moodChart) {
      if (percent >= entry['min'] && percent < entry['max']) {
        return entry['emoji'];
      }
    }
    return '';
  }

  // 4. Mood data per day (key: yyyy-mm-dd)
  Map<String, int> moodPercentData = {};

  // Add state for calendar half view
  bool showFirstHalf = true;

  // Helper to get days in current half
  List<int> getVisibleDays(int year, int month, bool firstHalf) {
    int daysInMonth = DateUtils.getDaysInMonth(year, month);
    if (firstHalf) {
      return List.generate(15, (i) => i + 1);
    } else {
      return List.generate(daysInMonth - 15, (i) => i + 16);
    }
  }

  String getGreetingImage() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return 'assets/goodmorning.png';
    } else if (hour >= 12 && hour < 17) {
      return 'assets/goodafternoon.png';
    } else if (hour >= 17 && hour < 20) {
      return 'assets/goodevening.png';
    } else {
      return 'assets/goodnight.png';
    }
  }

  void _showMoodDialog(int day) async {
    String? selectedEmoji;
    int? selectedPercent;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select your mood'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Wrap(
                spacing: 10,
                children: [
                  '😃', '😊', '😁', '😡', '😕', '😢'
                ].map((emoji) => GestureDetector(
                  onTap: () {
                    selectedEmoji = emoji;
                    setState(() {});
                  },
                  child: Text(
                    emoji,
                    style: TextStyle(fontSize: 28, backgroundColor: selectedEmoji == emoji ? Colors.orange[100] : null),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 10),
              TextField(
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Percent'),
                onChanged: (val) {
                  selectedPercent = int.tryParse(val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (selectedEmoji != null && selectedPercent != null) {
                  setState(() {
                    moodData[day] = {'emoji': selectedEmoji, 'percent': selectedPercent};
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _scheduleMidnightReset();
  }

  void _scheduleMidnightReset() async {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final duration = tomorrow.difference(now);
    Future.delayed(duration, () {
      setState(() {
        checklist = List.filled(checklist.length, false);
      });
      _scheduleMidnightReset(); // Reschedule for the next day
    });
  }

  void _showChecklistSummary() {
    int completed = checklist.where((v) => v).length;
    int total = checklist.length;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(32),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$completed/$total',
                    style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    '💗',
                    style: TextStyle(fontSize: 36),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Great work!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/star.png', width: 20, height: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Every tick is a win!',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 250, 209, 209),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Good Morning Image Section
                Container(
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
                            getGreetingImage(),
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: 180,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Checklist Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 247, 234),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Checklist', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 248, 200, 178),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/star.png', width: 20, height: 20),
                                    const SizedBox(width: 6),
                                    const Flexible(
                                      child: Text(
                                        "Turn your chaos into calm\nLet's tick things off together",
                                        style: TextStyle(fontSize: 11, color: Color.fromARGB(255, 0, 0, 0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(checklistItems.length, (i) =>
                        Theme(
                          data: Theme.of(context).copyWith(
                            checkboxTheme: CheckboxThemeData(
                              shape: const CircleBorder(),
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity(horizontal: -2, vertical: -2),
                            ),
                          ),
                          child: CheckboxListTile(
                            value: checklist[i],
                            onChanged: (val) {
                              setState(() {
                                checklist[i] = val ?? false;
                              });
                            },
                            title: Text(
                              checklistItems[i],
                              style: const TextStyle(fontSize: 15),
                            ),
                            controlAffinity: ListTileControlAffinity.leading,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFDA8D7A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () {
                            _showChecklistSummary();
                            setState(() {
                              checklist = List.filled(checklist.length, false);
                            });
                          },
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Scheduler Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 247, 234),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Scheduler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 248, 200, 178),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/star.png', width: 20, height: 20),
                                    const SizedBox(width: 6),
                                    const Flexible(
                                      child: Text(
                                        "Plan peacefully,live mindfully!",
                                        style: TextStyle(fontSize: 11, color: Color.fromARGB(255, 0, 0, 0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ...times.map((t) => Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 255, 230, 230),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: const BoxDecoration(
                                          color: Color.fromARGB(255, 248, 200, 178),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        t,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    schedule[t] ?? '',
                                    style: const TextStyle(fontSize: 15),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(
                            thickness: 1,
                            color: Color(0xFFFFBFAE),
                            height: 1,
                          ),
                        ],
                      )),
                      const SizedBox(height: 8),
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFFDA8D7A),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: () async {
                            for (var t in times) {
                              schedule[t] = controllers[t]?.text ?? '';
                            }
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SchedulerDetailsPage(
                                  initialSchedule: times.map((t) => {'time': t, 'desc': schedule[t] ?? ''}).toList(),
                                ),
                              ),
                            );
                            if (result != null && result is List) {
                              setState(() {
                                for (int i = 0; i < result.length && i < times.length; i++) {
                                  times[i] = result[i]['time'] ?? times[i];
                                  schedule[times[i]] = result[i]['desc'] ?? '';
                                  controllers[times[i]]?.text = result[i]['desc'] ?? '';
                                }
                              });
                            }
                          },
                          child: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Calendar Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 247, 234),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text('Calendar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
                          SizedBox(width: 8),
                          Expanded(
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 248, 200, 178),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset('assets/star.png', width: 20, height: 20),
                                    const SizedBox(width: 6),
                                    const Flexible(
                                      child: Text(
                                        "Feel it , track it ,understand it",
                                        style: TextStyle(fontSize: 11, color: Color.fromARGB(255, 0, 0, 0)),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Add extra spacing before month/year selector row
                      const SizedBox(height: 12),
                      // Month and year selector row with calendar icon and arrows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!showFirstHalf)
                            IconButton(
                              icon: const Icon(Icons.arrow_left),
                              onPressed: () {
                                setState(() {
                                  showFirstHalf = true;
                                });
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime(selectedYear, selectedMonth),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                                initialEntryMode: DatePickerEntryMode.calendarOnly,
                                selectableDayPredicate: (date) => date.day == 1,
                              );
                              if (picked != null) {
                                setState(() {
                                  selectedYear = picked.year;
                                  selectedMonth = picked.month;
                                  DateTime today = DateTime.now();
                                  showFirstHalf = (today.year == selectedYear && today.month == selectedMonth && today.day <= 15) || !(today.year == selectedYear && today.month == selectedMonth);
                                });
                              }
                            },
                          ),
                          Text(
                            '${getMonthName(selectedMonth)} $selectedYear',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          if (showFirstHalf && DateTime.now().year == selectedYear && DateTime.now().month == selectedMonth && DateTime.now().day > 15)
                            IconButton(
                              icon: const Icon(Icons.arrow_right),
                              onPressed: () {
                                setState(() {
                                  showFirstHalf = false;
                                });
                              },
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        getMonthName(selectedMonth),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 4,
                          mainAxisSpacing: 4,
                        ),
                        itemCount: getVisibleDays(selectedYear, selectedMonth, showFirstHalf).length,
                        itemBuilder: (context, i) {
                          int day = getVisibleDays(selectedYear, selectedMonth, showFirstHalf)[i];
                          DateTime cellDate = DateTime(selectedYear, selectedMonth, day);
                          DateTime today = DateTime.now();
                          DateTime yesterday = today.subtract(const Duration(days: 1));
                          String key = '${selectedYear.toString().padLeft(4, '0')}-${selectedMonth.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                          bool isToday = cellDate.year == today.year && cellDate.month == today.month && cellDate.day == today.day;
                          bool isYesterday = cellDate.year == yesterday.year && cellDate.month == yesterday.month && cellDate.day == yesterday.day;
                          int? percent = moodPercentData[key];
                          bool canEdit = isToday || isYesterday;
                          bool isPast = cellDate.isBefore(DateTime(today.year, today.month, today.day));
                          return GestureDetector(
                            onTap: canEdit ? () async {
                              int? entered = await showDialog<int>(
                                context: context,
                                builder: (context) {
                                  int? tempPercent = percent;
                                  return AlertDialog(
                                    title: Text('Enter mood % for $day ${getMonthName(selectedMonth)}'),
                                    content: TextField(
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Percent (0-100)'),
                                      onChanged: (val) {
                                        tempPercent = int.tryParse(val);
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          if (tempPercent != null && tempPercent! >= 0 && tempPercent! <= 100) {
                                            Navigator.pop(context, tempPercent);
                                          } else {
                                            Navigator.pop(context);
                                          }
                                        },
                                        child: const Text('Save'),
                                      ),
                                    ],
                                  );
                                },
                              );
                              if (entered != null) {
                                setState(() {
                                  moodPercentData[key] = entered;
                                });
                              }
                            } : null,
                            child: Container(
                              height: 80,
                              decoration: BoxDecoration(
                                color: Color.fromARGB(255, 255, 230, 230),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  if (isPast && percent == null)
                                    const Text(
                                      'Missed',
                                      style: TextStyle(fontSize: 10, color: Colors.red),
                                      textAlign: TextAlign.center,
                                    ),
                                  if (percent != null)
                                    Text(
                                      getEmojiForPercent(percent),
                                      style: const TextStyle(fontSize: 24),
                                      textAlign: TextAlign.center,
                                    ),
                                  if (canEdit && percent == null)
                                    const Text(
                                      'Click to enter',
                                      style: TextStyle(fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  if (percent != null)
                                    Text(
                                      '$percent%',
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
                                      textAlign: TextAlign.center,
                                    ),
                                  Text(
                                    day.toString(),
                                    style: const TextStyle(fontSize: 8, color: Color.fromARGB(255, 0, 0, 0)),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 