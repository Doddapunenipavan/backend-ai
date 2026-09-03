import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String _status = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    setState(() => _status = 'Loading...');

    bool loggedIn = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      loggedIn = prefs.getBool('logged_in') ?? false;
    } catch (_) {
      // Corrupt/unavailable prefs — fall back to treating the merchant
      // as signed out so they land on the login screen.
    }

    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Already signed in on this device -> straight to the dashboard.
    // Otherwise -> the login screen (which itself links out to the
    // "create account" onboarding flow for brand-new merchants).
    final String destination = loggedIn ? '/dashboard' : '/login';

    setState(() => _status = 'Navigating...');

    try {
      context.go(destination);
    } catch (e) {
      if (mounted) setState(() => _status = 'ERROR: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A56DB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Color(0xFF1A56DB), size: 44),
            ),
            const SizedBox(height: 20),
            Text(
              'FlexTenure',
              style: GoogleFonts.sora(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 40),
            const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation(Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _status,
              style: GoogleFonts.dmSans(
                fontSize: 12,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 20),
            // Manual fallback in case something goes wrong loading prefs.
            TextButton(
              onPressed: () => context.go('/login'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              child: const Text('Continue Manually',
                  style: TextStyle(color: Color(0xFF1A56DB))),
            ),
          ],
        ),
      ),
    );
  }
}
