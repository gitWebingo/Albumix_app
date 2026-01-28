import 'package:flutter/material.dart';
import '../datasources/local_storage.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final LocalStorageService storageService;
  const LoginScreen({super.key, required this.storageService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = "Please enter both email and password");
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Artificial delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == "info@webingo.in" && password == "Webingo@12345") {
      await widget.storageService.setLoggedIn(true);
      await widget.storageService.setGuest(false);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = "Invalid email or password";
      });
    }
  }

  void _guestLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    await widget.storageService
        .setLoggedIn(true); // Treat guest as logged in for simple routing
    await widget.storageService.setGuest(true);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo / Icon Section
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF6366F1).withOpacity(0.05),
                      border: Border.all(
                          color: const Color(0xFF6366F1).withOpacity(0.1)),
                    ),
                    child: const Icon(
                      Icons.lock_rounded,
                      size: 64,
                      color: Color(0xFF6366F1),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Welcome back",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: -1,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Secure access to your memories",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 48),
                  // Login Form Card
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A).withOpacity(0.5),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: "Email Address",
                            prefixIcon: Icon(Icons.email_outlined, size: 20),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: "Password",
                            prefixIcon: Icon(Icons.key_outlined, size: 20),
                          ),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 32),
                        SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 3,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text("SIGN IN"),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            const Expanded(
                                child: Divider(color: Colors.white10)),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                "OR",
                                style: Theme.of(context)
                                    .textTheme
                                    .labelSmall
                                    ?.copyWith(
                                      color: Colors.white24,
                                      letterSpacing: 2,
                                    ),
                              ),
                            ),
                            const Expanded(
                                child: Divider(color: Colors.white10)),
                          ],
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: _isLoading ? null : _guestLogin,
                          child: Text(
                            "CONTINUE AS GUEST",
                            style: TextStyle(
                              color: const Color(0xFF6366F1).withOpacity(0.8),
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
