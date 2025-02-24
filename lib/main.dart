import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutterappmedigo/Onboard.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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

    // Timer to animate the letters
    letterTimer = Timer.periodic(Duration(milliseconds: 300), (timer) {
      setState(() {
        if (currentLetterIndex < letters.length - 1) {
          currentLetterIndex++;
        } else {
          letterTimer.cancel();
        }
      });
    });

    // Navigate to OnBoardingScreen after 4 seconds
    Future.delayed(Duration(seconds: 4), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => OnBoardingScreen()),
      );
    });
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
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF64B5F6), // Light blue
                    Color(0xFF1976D2), // Medium blue
                    Color(0xFF0D47A1), // Dark blue
                  ],
                ),
              ),
            ),
            // Animated "MediG" with heartbeat image and heart
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Display "Medi"
                    ...List.generate(letters.length, (index) {
                      return AnimatedDefaultTextStyle(
                        duration: Duration(milliseconds: 300),
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
                    // Heartbeat image
                    AnimatedOpacity(
                      duration: Duration(milliseconds: 300),
                      opacity: currentLetterIndex >= letters.length - 1 ? 1.0 : 0.0,
                      child: Image.asset(
                        'Images/heart_beats.png',
                        width: 50,
                        height: 70,
                      ),
                    ),
                    // Display "G"
                    AnimatedDefaultTextStyle(
                      duration: Duration(milliseconds: 400),
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        color: currentLetterIndex >= letters.length - 1
                            ? Colors.white
                            : Colors.transparent,
                      ),
                      child: Text('GO'),
                    ),
                    // Heartbeat image
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

  HeartbeatImage({required this.controller});

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
