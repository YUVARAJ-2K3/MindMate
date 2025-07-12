import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'homepage.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'dart:async';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';

part 'vault.g.dart';

Future<void> initHive() async {
  await Hive.initFlutter();
  Hive.registerAdapter(VoiceNoteAdapter());
  await Hive.openBox<VoiceNote>('voice_notes');
}

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

  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlaying = false;
  String? _currentPlayingId;
  bool _isFloatingRecording = false;
  Duration _recordDuration = Duration.zero;
  Timer? _timer;
  String? _currentRecordingPath;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startRecording() async {
    final hasPermission = await _recorder.hasPermission();
    if (!hasPermission) {
      print('No microphone permission!');
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${const Uuid().v4()}.m4a';
    await _recorder.start(const RecordConfig(), path: filePath);
    setState(() { _isRecording = true; });
  }

  Future<void> _stopRecordingAndSave() async {
    final path = await _recorder.stop();
    setState(() { _isRecording = false; });
    if (path == null) return;
    final file = File(path);
    final duration = await _audioPlayer.setSourceDeviceFile(path).then((_) => _audioPlayer.getDuration());
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;
    final username = user!.email!.split('@')[0];
    final id = const Uuid().v4();
    final title = 'Voice Note';
    // Upload to Firebase Storage
    final ref = FirebaseStorage.instance.ref().child('voice_notes/$username/$id.m4a');
    await ref.putFile(file);
    final url = await ref.getDownloadURL();
    final note = VoiceNote(
      id: id,
      title: title,
      url: url,
      localPath: path,
      date: DateTime.now(),
      duration: duration ?? Duration.zero,
    );
    await FirebaseFirestore.instance.collection('users').doc(username).collection('voice_notes').doc(id).set(note.toMap());
  }

  void _playVoiceNote(VoiceNote note) async {
    if (_currentPlayingId == note.id && _isPlaying) {
      await _audioPlayer.pause();
      setState(() { _isPlaying = false; });
      return;
    }
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(note.localPath));
    setState(() {
      _isPlaying = true;
      _currentPlayingId = note.id;
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() { _isPlaying = false; });
    });
  }

  void _showVoiceNoteMenu(VoiceNote note) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.edit),
            title: Text('Rename'),
            onTap: () async {
              Navigator.pop(context);
              final newTitle = await _showRenameDialog(note.title);
              if (newTitle != null && newTitle.isNotEmpty) {
                _renameVoiceNote(note, newTitle);
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.delete),
            title: Text('Delete'),
            onTap: () async {
              Navigator.pop(context);
              _deleteVoiceNote(note);
            },
          ),
          ListTile(
            leading: Icon(Icons.share),
            title: Text('Share'),
            onTap: () async {
              Navigator.pop(context);
              // Implement share logic here
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _showRenameDialog(String currentTitle) async {
    final controller = TextEditingController(text: currentTitle);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Rename Voice Note'),
        content: TextField(controller: controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: Text('Rename')),
        ],
      ),
    );
  }

  Future<void> _renameVoiceNote(VoiceNote note, String newTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;
    final username = user!.email!.split('@')[0];
    await FirebaseFirestore.instance.collection('users').doc(username).collection('voice_notes').doc(note.id).update({'title': newTitle});
  }

  Future<void> _deleteVoiceNote(VoiceNote note) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user?.email == null) return;
    final username = user!.email!.split('@')[0];
    await FirebaseFirestore.instance.collection('users').doc(username).collection('voice_notes').doc(note.id).delete();
    // Optionally delete from storage and local
    final ref = FirebaseStorage.instance.refFromURL(note.url);
    await ref.delete();
    final file = File(note.localPath);
    if (await file.exists()) await file.delete();
  }

  Future<void> _startFloatingRecording() async {
    final micStatus = await Permission.microphone.request();
    if (!micStatus.isGranted) {
      print("Microphone permission denied");
      return;
    }
    final dir = await getApplicationDocumentsDirectory();
    final filePath = '${dir.path}/${const Uuid().v4()}.m4a';
    await _recorder.start(const RecordConfig(), path: filePath);
    setState(() {
      _isFloatingRecording = true;
      _recordDuration = Duration.zero;
      _currentRecordingPath = filePath;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (_) {
      setState(() {
        _recordDuration += Duration(seconds: 1);
      });
    });
  }

  Future<void> _stopFloatingRecordingAndSave() async {
    print('Attempting to stop recording...');
    String? path;
    try {
      path = await _recorder.stop();
      print('Recorder stopped, path: $path');
    } catch (e) {
      print('Error stopping recorder: $e');
    } finally {
      _timer?.cancel();
      setState(() {
        _isFloatingRecording = false;
      });
    }
    if (path == null) {
      print('No path returned from recorder.stop()');
      return;
    }
    try {
      final file = File(path);
      print('File exists: ${await file.exists()}');
      final duration = await _audioPlayer.setSourceDeviceFile(path).then((_) => _audioPlayer.getDuration());
      print('Duration: $duration');
      final id = const Uuid().v4();
      final now = DateTime.now();
      final title = DateFormat('yyyyMMdd_HHmmss').format(now);
      final note = VoiceNote(
        id: id,
        title: title,
        url: path,
        localPath: path,
        date: now,
        duration: duration ?? Duration.zero,
      );
      await Hive.box<VoiceNote>('voice_notes').add(note);
      print('Voice note added to Hive');
    } catch (e) {
      print('Error saving voice note: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 230, 230),
      body: Stack(
        children: [
          SafeArea(
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
                        _SearchBar(
                          onAdd: () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['mp3', 'm4a', 'wav', 'aac','opus','ogg'],
                            );
                            print('File picker result: $result');
                            if (result != null && result.files.single.path != null) {
                              print('Picked file path: ${result.files.single.path}');
                              final file = File(result.files.single.path!);
                              final id = const Uuid().v4();
                              final audioPlayer = AudioPlayer();
                              final duration = await audioPlayer.setSourceDeviceFile(file.path).then((_) => audioPlayer.getDuration());
                              final note = VoiceNote(
                                id: id,
                                title: result.files.single.name,
                                url: file.path,
                                localPath: file.path,
                                date: DateTime.now(),
                                duration: duration ?? Duration.zero,
                              );
                              await Hive.box<VoiceNote>('voice_notes').add(note);
                              print('Voice note added to Hive from file picker');
                            }
                          },
                          isRecording: _isRecording,
                        ),
                        SizedBox(height: 8),
                        ValueListenableBuilder(
                          valueListenable: Hive.box<VoiceNote>('voice_notes').listenable(),
                          builder: (context, Box<VoiceNote> box, _) {
                            final notes = box.values.toList().reversed.toList();
                            if (notes.isEmpty) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(child: Text('No audio files uploaded')),
                              );
                            }
                            return Column(
                              children: [
                                ...notes.take(2).map((note) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: _VoiceNoteItem(
                                    note: note,
                                    isPlaying: _currentPlayingId == note.id && _isPlaying,
                                    onPlay: () => _playVoiceNote(note),
                                    onMenu: () => _showVoiceNoteMenu(note),
                                  ),
                                )),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _ViewAllButton(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AllVoiceNotesPage(
                                      notes: Hive.box<VoiceNote>('voice_notes').values.toList().reversed.toList(),
                                      onPlay: (note) => _playVoiceNote(note),
                                      onMenu: (note) => _showVoiceNoteMenu(note),
                                      currentPlayingId: _currentPlayingId,
                                      isPlaying: _isPlaying,
                                    ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(width: 20),
                            Column(
                              children: [
                                SizedBox(
                                  height: 48,
                                  width: 140,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      if (_isFloatingRecording) {
                                        _stopFloatingRecordingAndSave();
                                      } else {
                                        _startFloatingRecording();
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color.fromARGB(255, 234, 152, 115),
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(_isFloatingRecording ? Icons.stop : Icons.mic, color: Colors.white),
                                        SizedBox(width: 8),
                                        Text(_isFloatingRecording ? 'Stop' : 'Record', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      ],
                                    ),
                                  ),
                                ),
                                if (_isFloatingRecording)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      _formatDuration(_recordDuration),
                                      style: TextStyle(
                                        color: Color.fromARGB(255, 234, 152, 115),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
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
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
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
  final VoidCallback? onAdd;
  final bool isRecording;
  const _SearchBar({this.onAdd, this.isRecording = false});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search',
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
          filled: true,
          fillColor: Colors.white,
          contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: Icon(isRecording ? Icons.stop : Icons.add, color: Color.fromARGB(255, 234, 152, 115), size: 22),
            onPressed: onAdd,
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minHeight: 32, minWidth: 32),
          ),
        ),
        style: TextStyle(fontSize: 13),
      ),
    );
  }
}

class _VoiceNoteItem extends StatelessWidget {
  final VoiceNote note;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onMenu;
  const _VoiceNoteItem({required this.note, required this.isPlaying, required this.onPlay, required this.onMenu});
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
          IconButton(
            icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow, color: Color.fromARGB(255, 234, 152, 115)),
            onPressed: onPlay,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title.length > 10
                      ? note.title.substring(0, 10) + '...'
                      : note.title,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(DateFormat('dd-MM-yy').format(note.date), style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(_formatDuration(note.duration), style: TextStyle(fontSize: 12, color: Colors.grey)),
          SizedBox(width: 6),
          IconButton(
            icon: Icon(Icons.more_vert, color: Colors.grey),
            onPressed: onMenu,
          ),
        ],
      ),
    );
  }
  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return '${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}';
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
  final VoidCallback? onTap;
  const _ViewAllButton({this.onTap});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Center(
        child: ElevatedButton(
          onPressed: onTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 234, 152, 115),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            elevation: 0,
          ),
          child: Text(
            'View All',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}

class AllVoiceNotesPage extends StatefulWidget {
  final List<VoiceNote> notes;
  final Function(VoiceNote) onPlay;
  final Function(VoiceNote) onMenu;
  final String? currentPlayingId;
  final bool isPlaying;
  const AllVoiceNotesPage({
    required this.notes,
    required this.onPlay,
    required this.onMenu,
    required this.currentPlayingId,
    required this.isPlaying,
    Key? key,
  }) : super(key: key);

  @override
  State<AllVoiceNotesPage> createState() => _AllVoiceNotesPageState();
}

class _AllVoiceNotesPageState extends State<AllVoiceNotesPage> {
  String _search = '';
  String? _currentPlayingId;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playVoiceNote(VoiceNote note) async {
    if (_currentPlayingId == note.id && _isPlaying) {
      await _audioPlayer.pause();
      setState(() { _isPlaying = false; });
      return;
    }
    await _audioPlayer.stop();
    await _audioPlayer.play(DeviceFileSource(note.localPath));
    setState(() {
      _isPlaying = true;
      _currentPlayingId = note.id;
    });
    _audioPlayer.onPlayerComplete.listen((event) {
      setState(() { _isPlaying = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredNotes = (widget.notes.toList()..sort((a, b) => b.date.compareTo(a.date)))
        .where((n) => n.title.toLowerCase().contains(_search.toLowerCase())).toList();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 230, 230),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text('Voice Notes', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                height: 32,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: Icon(Icons.search, color: Colors.grey, size: 18),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 6),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.add, color: Color.fromARGB(255, 234, 152, 115), size: 22),
                      onPressed: null,
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(minHeight: 32, minWidth: 32),
                    ),
                  ),
                  style: TextStyle(fontSize: 13),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
            ),
            SizedBox(height: 12),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: _VaultSectionCard(
                  child: ListView.separated(
                    itemCount: filteredNotes.length,
                    separatorBuilder: (_, __) => SizedBox(height: 8),
                    itemBuilder: (context, i) => _VoiceNoteItem(
                      note: filteredNotes[i],
                      isPlaying: _currentPlayingId == filteredNotes[i].id && _isPlaying,
                      onPlay: () => _playVoiceNote(filteredNotes[i]),
                      onMenu: () => widget.onMenu(filteredNotes[i]),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@HiveType(typeId: 0)
class VoiceNote extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String url;
  @HiveField(3)
  final String localPath;
  @HiveField(4)
  final DateTime date;
  @HiveField(5)
  final Duration duration;

  VoiceNote({
    required this.id,
    required this.title,
    required this.url,
    required this.localPath,
    required this.date,
    required this.duration,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'url': url,
    'localPath': localPath,
    'date': date.toIso8601String(),
    'duration': duration.inSeconds,
  };

  static VoiceNote fromMap(Map<String, dynamic> map) => VoiceNote(
    id: map['id'],
    title: map['title'],
    url: map['url'],
    localPath: map['localPath'],
    date: DateTime.parse(map['date']),
    duration: Duration(seconds: map['duration']),
  );
} 