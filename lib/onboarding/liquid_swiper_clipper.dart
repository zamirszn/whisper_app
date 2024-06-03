

import 'package:flutter/material.dart';

import 'liquid_swipe_data.dart';

class LiquidSwipeClipper extends CustomClipper<Path> {
  /// Clipper that uses a liquid swipe path.
  LiquidSwipeClipper({required this.data});

  /// The calculation needed to get the path.
  final LiquidSwipeData data;

  @override
  Path getClip(size) {
    return data.liquidSwipePath;
  }

  @override
  bool shouldReclip(LiquidSwipeClipper oldClipper) => data != oldClipper.data;
}
