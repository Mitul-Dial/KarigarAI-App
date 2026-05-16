import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/preferences_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.onComplete});

  final VoidCallback onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();
    if (name.isEmpty || phone.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your name and valid phone number')),
      );
      return;
    }
    setState(() => _saving = true);
    final uid = FirebaseAuth.instance.currentUser!.uid;
    await PreferencesRepository.instance.completeOnboarding(
      uid: uid,
      name: name,
      phone: phone,
    );
    if (mounted) widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              const SizedBox(height: 24),
              const AppLogo(size: 100),
              const SizedBox(height: 20),
              const Text(
                'Assalamu Alaikum!',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: kBlue),
              ),
              const SizedBox(height: 8),
              const Text(
                'Welcome to Ustaad AI. Tell us about yourself.',
                textAlign: TextAlign.center,
                style: TextStyle(color: kTextMuted, fontSize: 15),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: _nameCtrl,
                decoration: InputDecoration(
                  labelText: 'Full name',
                  filled: true,
                  fillColor: kSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'Phone number',
                  hintText: '+92 3XX XXXXXXX',
                  filled: true,
                  fillColor: kSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kBlue,
                    foregroundColor: kWhite,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2, color: kWhite),
                        )
                      : const Text('Continue', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
