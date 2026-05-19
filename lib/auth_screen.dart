import 'package:flutter/material.dart';
import 'services/google_auth_service.dart';
import 'theme/app_colors.dart';
import 'widgets/app_logo.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      await GoogleAuthService.instance.signInWithGoogle();
      // Navigation is handled by authStateChanges in UstaadAiApp.
    } on GoogleSignInCanceledException {
      // User dismissed the account picker — not an error.
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign-in failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            child: IgnorePointer(
              child: SizedBox(
                width: size.width,
                height: size.height,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0.0, -0.2),
                      radius: 1.8,
                      colors: [
                        kBlueMid.withValues(alpha: 0.95),
                        kBlue.withValues(alpha: 0.80),
                        kBlue.withValues(alpha: 0.45),
                        kBlue.withValues(alpha: 0.15),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.22, 0.45, 0.70, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(height: size.height * 0.15),
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: kBlue.withValues(alpha: 0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const AppLogo(size: 100),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Ustaad AI',
                  style: TextStyle(
                    fontFamily: 'Flaviotte',
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Har kaam ka ustaad',
                  style: TextStyle(
                    fontFamily: 'ClashDisplay',
                    fontSize: 18,
                    color: kGoldenBeige,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: kBlue)
                      : SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _signInWithGoogle,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: kText,
                              elevation: 3,
                              shadowColor: kBlue.withValues(alpha: 0.2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                                side: const BorderSide(
                                  color: kBorder,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: kBorder,
                                    ),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'G',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: kBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Continue with Google',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                SizedBox(height: size.height * 0.08),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
