import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_role.dart';
import '../services/profile_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/app_logo.dart';

class RoleSelectionScreen extends StatelessWidget {
  const RoleSelectionScreen({super.key, required this.onSelected});

  final VoidCallback onSelected;

  Future<void> _pick(BuildContext context, UserRole role) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await ProfileRepository.instance.setRole(uid, role);
    if (context.mounted) onSelected();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 24),
              const AppLogo(size: 88),
              const SizedBox(height: 16),
              const Text(
                'Ustaad AI',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: kBlue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Salam, ${user?.displayName?.split(' ').first ?? 'there'}!',
                textAlign: TextAlign.center,
                style: const TextStyle(color: kTextMuted, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                'How do you want to use the app?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: kText,
                ),
              ),
              const Spacer(),
              _RoleCard(
                icon: Icons.person_outline,
                title: 'Customer',
                subtitle: 'Find labour & book services',
                color: kBlue,
                onTap: () => _pick(context, UserRole.customer),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                icon: Icons.handyman_outlined,
                title: 'Provider',
                subtitle: 'Accept jobs & manage requests',
                color: kSuccess,
                onTap: () => _pick(context, UserRole.provider),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: kSurface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kBorder),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(color: kTextMuted, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
