import 'package:flutter/material.dart';
import 'landing_page1.dart';
import 'landing_page2.dart';
import 'landing_page3.dart';

class LandingPager extends StatefulWidget {
  const LandingPager({super.key});

  @override
  State<LandingPager> createState() => _LandingPagerState();
}

class _LandingPagerState extends State<LandingPager> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      int next = _pageController.page!.round();
      if (_currentPage != next) {
        setState(() {
          _currentPage = next;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const BouncingScrollPhysics(),
        children: const [
          LandingPage1(),
          LandingPage2(),
          LandingPage3(),
        ],
      ),
    );
  }
}