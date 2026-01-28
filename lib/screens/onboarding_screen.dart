import 'package:flutter/material.dart';
import '../datasources/local_storage.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  final LocalStorageService storageService;
  const OnboardingScreen({super.key, required this.storageService});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "title": "Welcome to Albumix",
      "subtitle": "Your personal, secure, and offline photo gallery.",
      "icon": "assets/icon_gallery.png"
    },
    {
      "title": "Organize Smartly",
      "subtitle": "Tag your photos, create albums, and keep everything tidy.",
      "icon": "assets/icon_organize.png"
    },
    {
      "title": "Privacy First",
      "subtitle": "Your photos stay on your device. No cloud, no tracking.",
      "icon": "assets/icon_privacy.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFF0F172A), Color(0xFF020617)],
              ),
            ),
          ),
          Column(
            children: [
              // Top Split - Visuals
              Expanded(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.02),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      bottomRight: Radius.circular(60),
                    ),
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Center(
                        child: TweenAnimationBuilder<double>(
                          duration: const Duration(milliseconds: 600),
                          tween: Tween(begin: 0.8, end: 1.0),
                          curve: Curves.easeOutBack,
                          builder: (context, scale, child) {
                            return Transform.scale(
                              scale: scale,
                              child: Container(
                                padding: const EdgeInsets.all(40),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color(0xFF6366F1)
                                          .withOpacity(0.1),
                                      blurRadius: 40,
                                      spreadRadius: 10,
                                    )
                                  ],
                                ),
                                child: Icon(
                                  index == 0
                                      ? Icons.auto_awesome_motion_rounded
                                      : index == 1
                                          ? Icons.grid_view_rounded
                                          : Icons.shield_rounded,
                                  size: 120,
                                  color: const Color(0xFF6366F1),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
              // Bottom Split - Text & Controls
              Expanded(
                flex: 4,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _pages[_currentPage]['title']!,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _pages[_currentPage]['subtitle']!,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: const Color(0xFF94A3B8),
                              height: 1.5,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const Spacer(),
                      // Bottom Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Indicators
                          Row(
                            children: List.generate(
                              _pages.length,
                              (index) => AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: const EdgeInsets.only(right: 8),
                                height: 6,
                                width: _currentPage == index ? 24 : 6,
                                decoration: BoxDecoration(
                                  color: _currentPage == index
                                      ? const Color(0xFF6366F1)
                                      : Colors.white10,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              ),
                            ),
                          ),
                          // Premium Button
                          GestureDetector(
                            onTap: () {
                              if (_currentPage < _pages.length - 1) {
                                _controller.nextPage(
                                  duration: const Duration(milliseconds: 500),
                                  curve: Curves.easeInOutCubic,
                                );
                              } else {
                                _finishOnboarding();
                              }
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              padding: EdgeInsets.symmetric(
                                horizontal:
                                    _currentPage == _pages.length - 1 ? 24 : 16,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6366F1),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF6366F1)
                                        .withOpacity(0.3),
                                    blurRadius: 15,
                                    offset: const Offset(0, 5),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  if (_currentPage == _pages.length - 1) ...[
                                    const Text(
                                      "GET STARTED",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Icon(
                                    _currentPage == _pages.length - 1
                                        ? Icons.rocket_launch_rounded
                                        : Icons.arrow_forward_ios_rounded,
                                    size: 18,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _finishOnboarding() async {
    await widget.storageService.setOnboardingSeen();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                LoginScreen(storageService: widget.storageService)),
      );
    }
  }
}
