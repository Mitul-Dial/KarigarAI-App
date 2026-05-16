import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Square profile photo at [size] (default 64×64 logical pixels).
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    this.imageUrl,
    this.imageBytes,
    this.size = 64,
    this.onTap,
    this.showCameraHint = false,
  });

  final String? imageUrl;
  final Uint8List? imageBytes;
  final double size;
  final VoidCallback? onTap;
  final bool showCameraHint;

  bool get _hasImage =>
      imageBytes != null ||
      (imageUrl != null && imageUrl!.trim().isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final avatar = CircleAvatar(
      radius: size / 2,
      backgroundColor: kBlueLight,
      backgroundImage: imageBytes != null
          ? MemoryImage(imageBytes!)
          : (imageUrl != null && imageUrl!.trim().isNotEmpty
              ? NetworkImage(imageUrl!.trim())
              : null),
      child: !_hasImage && showCameraHint
          ? Icon(Icons.camera_alt, color: kBlue, size: size * 0.45)
          : null,
    );

    if (onTap == null) return avatar;
    return GestureDetector(onTap: onTap, child: avatar);
  }
}
