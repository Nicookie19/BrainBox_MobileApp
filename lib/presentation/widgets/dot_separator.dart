import 'package:flutter/material.dart';

class DotSeparator extends StatelessWidget {
  const DotSeparator({super.key});

  @override
  Widget build(BuildContext context) => const SizedBox.square(
    dimension: 3,
    child: DecoratedBox(
      decoration: BoxDecoration(
        color: Color(0xFF747474),
        shape: BoxShape.circle,
      ),
    ),
  );
}
