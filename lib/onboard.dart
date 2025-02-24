import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutterappmedigo/Login.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnBoarding {
  final String title;
  final String image;
  final String body;
  final String textButton;

  OnBoarding(this.title, this.image, this.body, this.textButton);
}

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  List<OnBoarding> getOnboardList() {
    return [
      OnBoarding(
        'Welcome to MediGO',
        'Images/image1.png',
        'Your personal health assistant. Manage your medical records with ease and security',
        'Next',
      ),
      OnBoarding(
        'Track and Analyze',
        'Images/image2.png',
        'Keep track of your vital signs, symptoms, and more. Get actionable health insights anytime, anywhere',
        'Next',
      ),
      OnBoarding(
        'Secure and Private',
        'Images/image3.png',
        'Your data is safe with us. We prioritize security and privacy for all users',
        'Get Started',
      ),
    ];
  }

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int newIndex = _pageController.page!.round();
      if (newIndex != currentIndex) {
        setState(() {
          currentIndex = newIndex;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // Build page content without heartbeat animation
  Widget buildPageContent(OnBoarding data) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        final slideAnimation = Tween<Offset>(
          begin: const Offset(0.0, 0.2),
          end: Offset.zero,
        ).animate(animation);
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: slideAnimation,
            child: child,
          ),
        );
      },
      child: Container(
        key: ValueKey<String>(data.title),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Removed heartbeat animation, now just a plain image
            Image.asset(data.image),
            const SizedBox(height: 10),
            Text(
              data.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0288D1),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              data.body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0277BD),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final onboardList = getOnboardList();
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text(
            '${currentIndex + 1}/${onboardList.length}',
            style: const TextStyle(color: Color(0xFF0288D1)),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => LoginScreen(text1: '')),
                );
              },
              // Updated Skip button color to match the Prev button color
              child: const Text(
                'Skip',
                style: TextStyle(color: Color(0xFF0288D1), fontSize: 18),
              ),
            ),
          ],
          iconTheme: const IconThemeData(color: Colors.black),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFE3F2FD), // Light blue
              Color(0xFFBBDEFB), // Soft blue
              Color(0xFFFFFFFF), // White
            ],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardList.length,
                itemBuilder: (context, index) {
                  return Center(
                    child: buildPageContent(onboardList[index]),
                  );
                },
              ),
            ),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (currentIndex != 0)
                    TextButton(
                      onPressed: () {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text(
                        'Prev',
                        style: TextStyle(color: Color(0xFF0288D1), fontSize: 18),
                      ),
                    )
                  else
                    const SizedBox(width: 55),
                  AnimatedSmoothIndicator(
                    activeIndex: currentIndex,
                    count: onboardList.length,
                    effect: const ExpandingDotsEffect(
                      dotHeight: 10,
                      dotWidth: 12,
                      activeDotColor: Color(0xFF0288D1),
                      dotColor: Colors.grey,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (currentIndex == onboardList.length - 1) {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  LoginScreen(text1: '')),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      onboardList[currentIndex].textButton,
                      style:
                      const TextStyle(color: Color(0xFF0288D1), fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
