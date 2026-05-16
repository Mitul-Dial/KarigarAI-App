import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// Display and storage size for profile avatars (1:1, 64×64 px).
const int kProfileAvatarSize = 64;

class ProfileImageProcessor {
  ProfileImageProcessor._();

  /// Center-crops to square, then resizes to [kProfileAvatarSize]×[kProfileAvatarSize] JPEG.
  static Future<Uint8List> processFile(File file) async {
    final raw = await file.readAsBytes();
    return processBytes(raw);
  }

  static Uint8List processBytes(List<int> raw) {
    final decoded = img.decodeImage(Uint8List.fromList(raw));
    if (decoded == null) {
      throw Exception('Could not read image');
    }

    final side = decoded.width < decoded.height ? decoded.width : decoded.height;
    final x = (decoded.width - side) ~/ 2;
    final y = (decoded.height - side) ~/ 2;

    var square = img.copyCrop(decoded, x: x, y: y, width: side, height: side);
    square = img.copyResize(
      square,
      width: kProfileAvatarSize,
      height: kProfileAvatarSize,
      interpolation: img.Interpolation.average,
    );

    return Uint8List.fromList(img.encodeJpg(square, quality: 82));
  }
}
