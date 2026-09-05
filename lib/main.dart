import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void main() {
  runApp(const KurdSportApp());
}

class KurdSportApp extends StatefulWidget {
  const KurdSportApp({super.key});

  @override
  State<KurdSportApp> createState() => _KurdSportAppState();
}

class _KurdSportAppState extends State<KurdSportApp> {
  bool _isDarkMode = true; // دۆخی تاریک و ڕوون

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kurd Sport Live',
      theme: ThemeData(
        brightness: _isDarkMode ? Brightness.dark : Brightness.light,
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.grey[100],
      ),
      home: HomeScreen(isDarkMode: _isDarkMode, onToggleTheme: _toggleTheme),
    );
  }
}

class HomeScreen extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onToggleTheme;

  const HomeScreen({super.key, required this.isDarkMode, required this.onToggleTheme});

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
      const NewsPage(),
      NotificationsPage(),
      AboutPage(userPoints: userPoints),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kurd Sport Live'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: widget.onToggleTheme,
            tooltip: 'گۆڕینی ڕەنگ',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.greenAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _pages[4] = AboutPage(userPoints: userPoints);
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
            icon: Icon(Icons.article),
            label: 'هەواڵ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'ئاگاداری',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'دەربارە',
          ),
        ],
      ),
    );
  }
}

// 1. بەشی پەخشی ڕاستەوخۆ
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.play_circle_fill, color: Colors.greenAccent, size: 30),
                  title: Text(
                    matches[index]['title']!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
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

// 2. بەشی پێشبینییەکان
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
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'بارسێلۆنا × ڕیاڵ مەدرید',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'ئەنجامی چاوەڕوانکراو بنووسە و 50 خاڵ بەدەستبهێنە!',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: _predictionController,
                    enabled: !_hasVoted,
                    decoration: InputDecoration(
                      hintText: 'لێرە ئەنجام بنووسە (بۆ نموونە: 2-1)...',
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
                                widget.onAddPoints(50);
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

// 3. بەشی هەواڵە وەرزشییەکان
class NewsPage extends StatelessWidget {
  const NewsPage({super.key});

  final List<Map<String, String>> newsList = const [
    {
      'title': 'دەستپێکردنەوەی خولی یانە پاڵەوانەکانی ئەوروپا',
      'date': 'ئەمڕۆ',
      'desc': 'ئەمشەو چەندین یاری بەهێز لە چامپیۆنزلیگ بەڕێوەدەچن و یانە گەورەکان ڕووبەڕووی یەکدی دەبنەوە.'
    },
    {
      'title': 'ئامادەکاری بۆ جامی نەتەوەکانی ئەوروپا',
      'date': 'دوێنێ',
      'desc': 'هەڵبژاردەکان لیستی سەرەتایی یاریزانانی خۆیان ڕاگەیاند بۆ مۆندیالی داهاتوو.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'دوایین هەواڵە وەرزشییەکان',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: newsList.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                newsList[index]['title']!,
                                style: const TextStyle(color: Colors.greenAccent, fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                            Text(
                              newsList[index]['date']!,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          newsList[index]['desc']!,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 4. بەشی ئاگادارییەکان (نوێ)
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  final List<Map<String, String>> notifications = const [
    {
      'title': 'یاری نوێ دەستی پێکرد!',
      'desc': 'ئێستا دەتوانیت پەخشی ڕاستەوخۆی یاری بارسێلۆنا و ڕیاڵ مەدرید ببینیت.',
      'time': 'پێش 10 خولەک'
    },
    {
      'title': 'خەڵاتی پێشبینی',
      'desc': 'پێشبینیەکەی پێشووت سەرکەوتوو بوو، 50 خاڵت بۆ هەژمارکرا.',
      'time': 'دوێنێ'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ئاگادارییەکانی ئەپ',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Expanded(
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active, color: Colors.greenAccent),
                    title: Text(notifications[index]['title']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(notifications[index]['desc']!),
                    trailing: Text(notifications[index]['time']!, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// 5. بەشی دەربارە و پەیوەندی
class AboutPage extends StatelessWidget {
  final int userPoints;

  const AboutPage({super.key, required this.userPoints});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          const Text(
            'دەربارەی ئەپڵیکەیشن',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 15),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.green.withOpacity(0.5)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kurd Sport Live ⚽️📺',
                  style: TextStyle(color: Colors.greenAccent, fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'ئەپێکی پێشکەوتووە بۆ پەخشی ڕاستەوخۆ، پێشبینی، هەواڵە وەرزشییەکان و ئاگادارییەکان بە شێوازی تاریک و ڕوون.',
                  style: TextStyle(fontSize: 14, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'پەیوەندی کردن:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Card(
            child: ListTile(
              leading: Icon(Icons.email, color: Colors.greenAccent),
              title: Text('پۆستی ئەلیکترۆنی'),
              subtitle: Text('support@kurdsport.com'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.telegram, color: Colors.blueAccent),
              title: Text('کەناڵی تێلیگرام'),
              subtitle: Text('@KurdSportLive'),
            ),
          ),
        ],
      ),
    );
  }
}
