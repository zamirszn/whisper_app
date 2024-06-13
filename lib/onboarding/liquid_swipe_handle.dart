import 'package:flutter/material.dart';

class LiquidSwipeHandle extends StatelessWidget {
  /// A circular handle for the liquid swipe curtain
  /// that has a right chevron and an [InkWell] based
  /// tap handler.
  const LiquidSwipeHandle({
    super.key,
    required this.diameter,
    required this.onTap,
  });

  /// The diameter of the handle
  final double diameter;

  /// Fires when tapping the handle
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      height: diameter,
      width: diameter,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: const StadiumBorder(),
          child: const Icon(
            Icons.chevron_right,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
