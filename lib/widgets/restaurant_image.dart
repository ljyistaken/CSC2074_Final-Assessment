import 'dart:convert';

import 'package:flutter/material.dart';

class RestaurantImage extends StatelessWidget {
  const RestaurantImage({
    super.key,
    required this.imageKey,
    this.imageData,
    this.height,
    this.width,
    this.borderRadius = 18,
  });

  final String imageKey;

  /// Optional base64-encoded photo. When present and decodable, this is
  /// shown instead of the generated style icon below.
  final String? imageData;
  final double? height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final data = imageData;
    if (data != null && data.isNotEmpty) {
      try {
        final bytes = base64Decode(data);
        return ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: Image.memory(
            bytes,
            height: height,
            width: width,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _StyleImage(
              imageKey: imageKey,
              height: height,
              width: width,
              borderRadius: borderRadius,
            ),
          ),
        );
      } catch (_) {
        // Corrupted/undecodable base64 — fall through to the style image
        // rather than crashing the card.
      }
    }
    return _StyleImage(
      imageKey: imageKey,
      height: height,
      width: width,
      borderRadius: borderRadius,
    );
  }
}

class _StyleImage extends StatelessWidget {
  const _StyleImage({
    required this.imageKey,
    required this.height,
    required this.width,
    required this.borderRadius,
  });

  final String imageKey;
  final double? height;
  final double? width;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (imageKey == 'italian') {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Image.asset(
          'assets/images/olive_kitchen.png',
          height: height,
          width: width,
          fit: BoxFit.cover,
        ),
      );
    }
    final style = switch (imageKey) {
      'sushi' => (
          const Color(0xFF46211A),
          const Color(0xFFD98B5F),
          Icons.set_meal_rounded,
        ),
      'spice' => (
          const Color(0xFF7F1D1D),
          const Color(0xFFF59E0B),
          Icons.ramen_dining_rounded,
        ),
      'dessert' => (
          const Color(0xFF9D174D),
          const Color(0xFFF9A8D4),
          Icons.cake_rounded,
        ),
      _ => (
          const Color(0xFF2F1B16),
          const Color(0xFFB86B3D),
          Icons.local_pizza_rounded,
        ),
    };
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [style.$1, style.$2],
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: .15,
              child: CustomPaint(painter: _RestaurantPatternPainter()),
            ),
            Center(
              child: Icon(style.$3, color: Colors.white, size: 58),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestaurantPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3;
    for (double y = 14; y < size.height; y += 26) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y - 20), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}