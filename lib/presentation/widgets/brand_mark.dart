import 'package:flutter/material.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({required this.size, super.key});
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: size,
    height: size,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Image.asset('assets/ui/brand_cube.png', fit: BoxFit.contain),
        FractionallySizedBox(
          widthFactor: 0.62,
          heightFactor: 0.62,
          child: Image.asset('assets/ui/brand_brain.png', fit: BoxFit.contain),
        ),
      ],
    ),
  );
}
