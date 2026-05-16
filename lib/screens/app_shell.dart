import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../models/user_role.dart';
import '../services/notification_service.dart';
import '../services/preferences_repository.dart';
import '../services/profile_repository.dart';
import '../theme/app_colors.dart';
import 'customer_home_screen.dart';
import 'onboarding_screen.dart';
import 'provider_home_screen.dart';
import 'role_selection_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  UserProfile? _profile;
  bool _onboardingDone = false;
  bool _checking = true;

  @override
  void initState() {
    super.initState();
    NotificationService.instance.init();
    _load();
  }

  Future<void> _load() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final onboarded = await PreferencesRepository.instance.isOnboardingComplete(uid);
    final profile = await ProfileRepository.instance.load(uid);
    if (mounted) {
      setState(() {
        _onboardingDone = onboarded;
        _profile = profile;
        _checking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_checking || _profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: kBlue)),
      );
    }

    if (!_onboardingDone) {
      return OnboardingScreen(onComplete: _load);
    }

    if (_profile!.role == null) {
      return RoleSelectionScreen(onSelected: _load);
    }

    if (_profile!.role == UserRole.provider) {
      return ProviderHomeScreen(
        profile: _profile!,
        onProfileChanged: (p) => setState(() => _profile = p),
        onSwitchRole: () async {
          await ProfileRepository.instance.setRole(
            FirebaseAuth.instance.currentUser!.uid,
            UserRole.customer,
          );
          _load();
        },
      );
    }

    return CustomerHomeScreen(
      profile: _profile!,
      onProfileChanged: (p) => setState(() => _profile = p),
      onSwitchRole: () async {
        await ProfileRepository.instance.setRole(
          FirebaseAuth.instance.currentUser!.uid,
          UserRole.provider,
        );
        _load();
      },
    );
  }
}
