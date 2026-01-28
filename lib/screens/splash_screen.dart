import 'package:flutter/material.dart';
import '../datasources/local_storage.dart';
import 'home_screen.dart';
import 'onboarding_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  final LocalStorageService storageService;
  const SplashScreen({super.key, required this.storageService});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkNavigation();
  }

  Future<void> _checkNavigation() async {
    // Artificial delay for branding
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (widget.storageService.seenOnboarding) {
      if (widget.storageService.isLoggedIn) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginScreen(storageService: widget.storageService)),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) =>
                OnboardingScreen(storageService: widget.storageService)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0F172A),
              Color(0xFF020617),
            ],
          ),
        ),
        child: Center(
          child: TweenAnimationBuilder<double>(
            duration: const Duration(seconds: 2),
            tween: Tween(begin: 0.8, end: 1.0),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) {
              return Opacity(
                opacity: (scale - 0.8) / 0.2, // Maps 0.8-1.0 to 0.0-1.0
                child: Transform.scale(
                  scale: scale,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.03),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: const Icon(
                          Icons.photo_library_outlined,
                          size: 64,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        "ALBUMIX",
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                              letterSpacing: 8,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "MEMORIES IN MOTION",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              letterSpacing: 2,
                              color: Colors.white.withOpacity(0.3),
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
