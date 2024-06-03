import 'package:flutter/material.dart';

class LiquidSwipeCard extends StatelessWidget {
  const LiquidSwipeCard({
    super.key,
    required this.gradient,
    required this.buttonColor,
    required this.name,
    required this.action,
    required this.image,
    required this.title,
    required this.titleColor,
    required this.subtitle,
    required this.subtitleColor,
    required this.body,
    required this.bodyColor,
    required this.onTapName,
    required this.onSkip,
  });

  final Gradient gradient;
  final Color buttonColor;
  final String name;
  final String action;
  final ImageProvider image;
  final String title;
  final Color titleColor;
  final String subtitle;
  final Color subtitleColor;
  final String body;
  final Color bodyColor;
  final VoidCallback onTapName;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
      ),
      child: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Builder(
              builder: (context) {
                var style = TextStyle(
                  color: buttonColor,
                  fontSize: 15,
                  fontWeight: FontWeight.normal,
                );

                return Row(
                  children: [
                    TextButton(
                      onPressed: onTapName,
                      child: Text(
                        name,
                        style: style,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: onSkip,
                      child: Text(
                        action,
                        style: style,
                      ),
                    ),
                    const SizedBox(width: 16.0 * 2),
                  ],
                );
              },
            ),
            const Spacer(),
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image(
                  image: image,
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              style: TextStyle(
                fontSize: 32,
                color: titleColor,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 38,
                height: 1.0,
                color: subtitleColor,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            FractionallySizedBox(
              widthFactor: 0.7,
              alignment: Alignment.centerLeft,
              child: Text(
                body,
                style: TextStyle(
                  fontSize: 16,
                  color: bodyColor,
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
