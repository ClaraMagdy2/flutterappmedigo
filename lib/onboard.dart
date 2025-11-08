import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:provider/provider.dart';
import 'translation_provider.dart';
import 'Login.dart';

class OnBoarding {
  final String title;
  final String body;
  final String image;

  OnBoarding(this.title, this.body, this.image);
}

class OnBoardingScreen extends StatefulWidget {
  const OnBoardingScreen({super.key});

  @override
  _OnBoardingScreenState createState() => _OnBoardingScreenState();
}

class _OnBoardingScreenState extends State<OnBoardingScreen> {
  final PageController _pageController = PageController();
  int currentIndex = 0;

  List<OnBoarding> getOnboardList(BuildContext context) {
    final t = Provider.of<TranslationProvider>(context, listen: false).t;

    return [
      OnBoarding(t("onboarding_title_1"), t("onboarding_body_1"), 'Images/image1.png'),
      OnBoarding(t("onboarding_title_2"), t("onboarding_body_2"), 'Images/image2.png'),
      OnBoarding(t("onboarding_title_3"), t("onboarding_body_3"), 'Images/image3.png'),
    ];
  }

  bool isArabicText(String text) {
    return RegExp(r'[\u0600-\u06FF]').hasMatch(text);
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

  Widget buildPageContent(OnBoarding data) {
    final bool isArabic = isArabicText(data.title);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Container(
        key: ValueKey<String>(data.title),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        padding: const EdgeInsets.all(16.0),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(data.image),
            const SizedBox(height: 10),
            Text(
              data.title,
              textAlign: TextAlign.center,
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
              textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
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
    final t = Provider.of<TranslationProvider>(context).t;
    final onboardList = getOnboardList(context);
    final isArabic = isArabicText(onboardList[0].title);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: AppBar(
          title: Text(
            '${currentIndex + 1}/${onboardList.length}',
            style: const TextStyle(color: Color(0xFF0288D1)),
          ),
          backgroundColor: Colors.white,
          elevation: 1,
          actions: [
            IconButton(
              icon: const Icon(Icons.language, color: Color(0xFF0288D1)),
              tooltip: 'Switch Language',
              onPressed: () async {
                final provider = Provider.of<TranslationProvider>(context, listen: false);
                final newLocale = isArabic ? 'en' : 'ar';
                await provider.load(newLocale);
                setState(() {});
              },
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text(
                t("skip"),
                style: const TextStyle(color: Color(0xFF0288D1), fontSize: 18),
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
              Color(0xFFE3F2FD),
              Color(0xFFBBDEFB),
              Color(0xFFFFFFFF),
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
                  return Center(child: buildPageContent(onboardList[index]));
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
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
                      child: Text(
                        t("previous"),
                        style: const TextStyle(color: Color(0xFF0288D1), fontSize: 18),
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
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                        );
                      } else {
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(
                      currentIndex == onboardList.length - 1
                          ? t("get_started")
                          : t("next"),
                      style: const TextStyle(color: Color(0xFF0288D1), fontSize: 18),
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
