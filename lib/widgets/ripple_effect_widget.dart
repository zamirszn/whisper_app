import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:whisper/globals.dart';

class Ripples extends StatefulWidget {
  const Ripples({
    super.key,
    this.size = 150.0,
  });

  final double size;

  @override
  RipplesState createState() => RipplesState();
}

class RipplesState extends State<Ripples> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }

  void updateAnimationDuration(Duration duration) {
    _controller.duration = duration;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CirclePainter(
        _controller,
      ),
      size: Size.square(widget.size * 2.125),
    );
  }
}

class _CirclePainter extends CustomPainter {
  _CirclePainter(
    this._animation,
  ) : super(repaint: _animation);

  final Animation<double> _animation;

  void circle(Canvas canvas, Rect rect, double value, Color rippleColor) {
    final area = math.pow(rect.width / 2, 2);
    final radius = math.sqrt(area * value / 4);

    final opacity = (1.0 - (value / 4.0)).clamp(0.0, 1.0);
    rippleColor = rippleColor.withOpacity(opacity); // Use custom rippleColor
    canvas.drawCircle(rect.center, radius, Paint()..color = rippleColor);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Custom app color
    Color customRippleColor = appColor1;

    for (int wave = 3; wave >= 0; wave--) {
      circle(canvas, rect, wave + _animation.value, customRippleColor);
    }
  }

  @override
  bool shouldRepaint(_CirclePainter oldDelegate) => false;
}
