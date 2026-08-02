import 'dart:convert';
import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

/// Picks a photo and prepares it for storage directly inside a Firestore
/// document as base64.
///
/// Firestore caps documents at 1 MiB, and base64 inflates raw bytes by
/// roughly 33%, so images are resized and re-compressed client-side before
/// encoding — a raw phone photo (often several MB) would blow the limit
/// otherwise.
class ImageUtils {
  static const _maxDimension = 800;
  static const _jpegQuality = 70;

  /// Firestore's hard document cap is 1 MiB; this leaves comfortable room
  /// for the rest of the restaurant's fields plus encoding overhead.
  static const _maxEncodedBytes = 700 * 1024;

  static Future<String?> pickAndEncodeImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85, // light pre-compression from the OS picker itself
    );
    if (picked == null) return null;

    final bytes = await picked.readAsBytes();
    return compressAndEncode(bytes);
  }

  /// Resizes [bytes] so its longer side is at most [_maxDimension]px,
  /// re-encodes as JPEG at [_jpegQuality], and returns the result as
  /// base64. Throws a [StateError] if the image is still too large after
  /// compression (e.g. an unusually detailed or oddly-shaped photo).
  static String? compressAndEncode(Uint8List bytes) {
    final decoded = img.decodeImage(bytes);
    if (decoded == null) return null;

    final resized = decoded.width >= decoded.height
        ? img.copyResize(decoded, width: _maxDimension)
        : img.copyResize(decoded, height: _maxDimension);

    final jpeg = img.encodeJpg(resized, quality: _jpegQuality);
    final encoded = base64Encode(jpeg);

    if (encoded.length > _maxEncodedBytes) {
      throw StateError(
        'This image is too large even after compression. Try a simpler photo.',
      );
    }
    return encoded;
  }
}