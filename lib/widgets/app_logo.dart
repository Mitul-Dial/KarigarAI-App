import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Brand logo — not used in chat "U" avatar bubbles.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 80, this.circular = true});

  final double size;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      'assets/app_logo.png',
      width: size,
      height: size,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: kBlue,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'U',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
    if (!circular) return image;
    return ClipOval(child: image);
  }
}
