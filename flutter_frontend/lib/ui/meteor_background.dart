import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

class MeteorBackground extends StatefulWidget {
  final Widget child;
  const MeteorBackground({super.key, required this.child});

  @override
  State<MeteorBackground> createState() => _MeteorBackgroundState();
}

class _MeteorBackgroundState extends State<MeteorBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_Meteor> _meteors = [];
  final List<_Star> _stars = [];
  final Random _random = Random();

  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    // Runs the animation loop indefinitely
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  void _initSpace(Size size) {
    if (_screenSize == size) return;
    _screenSize = size;
    _meteors.clear();
    _stars.clear();

    // Generate static background stars
    for (int i = 0; i < 50; i++) {
      _stars.add(_Star.random(size, _random));
    }

    // Generate moving meteors
    for (int i = 0; i < 8; i++) {
      _meteors.add(_Meteor.random(size, _random));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _initSpace(Size(constraints.maxWidth, constraints.maxHeight));

        return Stack(
          fit: StackFit.expand,
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                // Update meteor positions every frame
                for (var m in _meteors) {
                  m.update(_screenSize, _random);
                }
                return CustomPaint(
                  size: Size.infinite,
                  painter: _SpacePainter(
                    meteors: _meteors,
                    stars: _stars,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                );
              },
            ),
            widget.child, // The chat UI sits on top of the animation
          ],
        );
      },
    );
  }
}

// --- Data Models for Space Objects ---

class _Star {
  final double x;
  final double y;
  final double size;
  final double opacity;

  _Star(this.x, this.y, this.size, this.opacity);

  factory _Star.random(Size size, Random random) {
    return _Star(
      random.nextDouble() * size.width,
      random.nextDouble() * size.height,
      random.nextDouble() * 1.5 + 0.5,
      random.nextDouble() * 0.5 + 0.1,
    );
  }
}

class _Meteor {
  double x;
  double y;
  double speed;
  double length;
  double thickness;
  double opacity;

  _Meteor({
    required this.x,
    required this.y,
    required this.speed,
    required this.length,
    required this.thickness,
    required this.opacity,
  });

  factory _Meteor.random(
    Size size,
    Random random, {
    bool startOffscreen = false,
  }) {
    // Meteors travel diagonally down and to the left
    return _Meteor(
      x:
          random.nextDouble() * size.width +
          (startOffscreen ? size.width * 0.5 : 0),
      y: random.nextDouble() * size.height * (startOffscreen ? -0.5 : 1) - 100,
      speed: random.nextDouble() * 8 + 6,
      length: random.nextDouble() * 80 + 40,
      thickness: random.nextDouble() * 1.5 + 0.5,
      opacity: random.nextDouble() * 0.6 + 0.2,
    );
  }

  void update(Size size, Random random) {
    // Move down and left (45 degree angle)
    x -= speed;
    y += speed;

    // Respawn at the top/right when it goes completely off screen
    if (x < -length || y > size.height + length) {
      final newMeteor = _Meteor.random(size, random, startOffscreen: true);
      x = newMeteor.x;
      y = newMeteor.y;
      speed = newMeteor.speed;
      length = newMeteor.length;
      thickness = newMeteor.thickness;
      opacity = newMeteor.opacity;
    }
  }
}

// --- The Custom Painter ---

class _SpacePainter extends CustomPainter {
  final List<_Meteor> meteors;
  final List<_Star> stars;
  final bool isDark;

  _SpacePainter({
    required this.meteors,
    required this.stars,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseColor = isDark ? Colors.white : Colors.black87;

    // Draw static stars
    for (var star in stars) {
      final paint = Paint()
        ..color = baseColor.withValues(alpha: star.opacity)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }

    // Draw shooting meteors
    for (var m in meteors) {
      final paint = Paint()
        ..strokeWidth = m.thickness
        ..strokeCap = StrokeCap.round;

      // Calculate tail position (trailing up and to the right)
      final tailX = m.x + m.length;
      final tailY = m.y - m.length;

      // Gradient gives the "shooting star" fading tail effect
      paint.shader = ui.Gradient.linear(
        Offset(m.x, m.y), // Bright head
        Offset(tailX, tailY), // Faded tail
        [
          baseColor.withValues(alpha: m.opacity),
          baseColor.withValues(alpha: 0.0),
        ],
      );

      canvas.drawLine(Offset(m.x, m.y), Offset(tailX, tailY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
