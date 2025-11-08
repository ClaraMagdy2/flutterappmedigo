import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'Onboard.dart';
import 'translation_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => TranslationProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<String> letters;
  late int currentLetterIndex;
  late Timer letterTimer;

  @override
  void initState() {
    super.initState();

    letters = ["M", "e", "d", "i"];
    currentLetterIndex = 0;

    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    letterTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        if (currentLetterIndex < letters.length - 1) {
          currentLetterIndex++;
        } else {
          letterTimer.cancel();
        }
      });
    });

    loadTranslationsAndNavigate();
  }

  Future<void> loadTranslationsAndNavigate() async {
    final provider = Provider.of<TranslationProvider>(context, listen: false);

    try {
      await uploadTranslationsToFirestore(); // 🔁 Upload translations
      await provider.load('ar'); // 🌐 Load language ('en' or 'ar')
    } catch (e) {
      print("❌ Translation load failed: $e");
    }

    await Future.delayed(Duration(seconds: 2));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => OnBoardingScreen()),
    );
  }

  Future<void> uploadTranslationsToFirestore() async {
    final url = Uri.parse('http://10.0.2.2:8000/translations/upload_all');
    try {
      final response = await http.post(url);
      if (response.statusCode == 200) {
        print("✅ Translations uploaded: ${response.body}");
      } else {
        print("❌ Upload failed: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("🔥 Upload error: $e");
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    letterTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF64B5F6),
                    Color(0xFF1976D2),
                    Color(0xFF0D47A1),
                  ],
                ),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ...List.generate(letters.length, (index) {
                      return AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 300),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: index <= currentLetterIndex
                              ? Colors.white
                              : Colors.transparent,
                        ),
                        child: Text(letters[index]),
                      );
                    }),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 300),
                      opacity: currentLetterIndex >= letters.length - 1 ? 1.0 : 0.0,
                      child: Image.asset(
                        'Images/heart_beats.png',
                        width: 50,
                        height: 70,
                      ),
                    ),
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 400),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: currentLetterIndex >= letters.length - 1
                            ? Colors.white
                            : Colors.transparent,
                      ),
                      child: const Text('GO'),
                    ),
                    HeartbeatImage(controller: _controller),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HeartbeatImage extends StatelessWidget {
  final AnimationController controller;

  const HeartbeatImage({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + controller.value * 0.2,
          child: Image.asset(
            'Images/heart1.png',
            width: 80,
            height: 90,
          ),
        );
      },
    );
  }
}
