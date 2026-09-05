import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const KurdSportApp());
}

class KurdSportApp extends StatelessWidget {
  const KurdSportApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kurd Sport Live',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  int userPoints = 120; // خاڵەکانی بەکارهێنەر

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const LiveStreamPage(),
      PredictionsPage(onAddPoints: (points) {
        setState(() {
          userPoints += points;
        });
      }),
      RewardsPage(userPoints: userPoints),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurd Sport Live'),
        backgroundColor: Colors.black87,
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.green),
                ),
                child: Text(
                  'خاڵ: $userPoints',
                  style: const TextStyle(color: Colors.greenAccent, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        backgroundColor: Colors.black87,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            // نوێکردنەوەی خاڵەکان لە پەڕەی خەڵاتدا ئەگەر گۆڕانکاری بەسەردا هات
            _pages[2] = RewardsPage(userPoints: userPoints);
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.live_tv),
            label: 'پەخش',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_football),
            label: 'پێشبینی',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'خەڵات',
          ),
        ],
      ),
    );
  }
}

// 1. بەشی پەخشی ڕاستەوخۆ (لیستی یارییەکان)
class LiveStreamPage extends StatefulWidget {
  const LiveStreamPage({super.key});

  @override
  State<LiveStreamPage> createState() => _LiveStreamPageState();
}

class _LiveStreamPageState extends State<LiveStreamPage> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  int _selectedMatchIndex = 0;

  final List<Map<String, String>> matches = [
    {
      'title': 'بارسێلۆنا × ڕیاڵ مەدرید',
      'url': 'https://sample.vodobox.com/plan_b_intros/plan_b_intros.m3u8',
    },
    {
      'title': 'مانچێستەر یونایتد × لیدز',
      'url': 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStream(matches[0]['url']!);
  }

  void _loadStream(String url) {
    _controller?.dispose();
    setState(() {
      _isInitialized = false;
    });

    _controller = VideoPlayerController.networkUrl(Uri.parse(url))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller!.play();
      });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'یارییە ڕاستەوخۆکان',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          height: 220,
          color: Colors.black,
          child: _isInitialized && _controller != null
              ? AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                )
              : const Center(
                  child: CircularProgressIndicator(color: Colors.greenAccent),
                ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: ListView.builder(
            itemCount: matches.length,
            itemBuilder: (context, index) {
              return Card(
                color: _selectedMatchIndex == index ? Colors.green.withOpacity(0.3) : Colors.grey[850],
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 30),
                  title: Text(
                    matches[index]['title']!,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Text('پەخش', style: TextStyle(color: Colors.greenAccent)),
                  onTap: () {
                    setState(() {
                      _selectedMatchIndex = index;
                    });
                    _loadStream(matches[index]['url']!);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// 2. بەشی پێشبینییەکان و وەرگرتنی خاڵ
class PredictionsPage extends StatefulWidget {
  final Function(int) onAddPoints;

  const PredictionsPage({super.key, required this.onAddPoints});

  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  final TextEditingController _predictionController = TextEditingController();
  bool _hasVoted = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'پێشبینی ئەنجامی یارییەکان',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            color: Colors.grey[850],
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'بارسێلۆنا × ڕیاڵ مەدرید',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ئەنجامی چاوەڕوانکراو بنووسە (بۆ نموونە: 2-1) و 50 خاڵ بەدەستبهێنە!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _predictionController,
                    enabled: !_hasVoted,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'لێرە ئەنجام بنووسە...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black45,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: _hasVoted
                          ? null
                          : () {
                              if (_predictionController.text.isNotEmpty) {
                                setState(() {
                                  _hasVoted = true;
                                });
                                widget.onAddPoints(50); // زیادکردنی 50 خاڵ
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('پێشبینیەکەت بە سەرکەوتوویی تۆمارکرا و 50 خاڵت پێدرا!')),
                                );
                              }
                            },
                      child: Text(_hasVoted ? 'پێشبینی تۆمارکراوە' : 'ناردنی پێشبینی'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. بەشی خەڵاتەکان
class RewardsPage extends StatelessWidget {
  final int userPoints;

  const RewardsPage({super.key, required this.userPoints});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'سیستەمی خەڵات و بەدیهێنان',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'کۆی خاڵە بەدەستهاتووەکانت:',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                Text(
                  '$userPoints خاڵ',
                  style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'دیارییە بەردەستەکان:',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: const [
                Card(
                  color: Colors.grey,
                  child: ListTile(
                    leading: Icon(Icons.card_giftcard, color: Colors.amber),
                    title: Text('بەشداریکردن لە تیروپشکدا', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('پێویستە 200 خاڵت هەبێت'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
