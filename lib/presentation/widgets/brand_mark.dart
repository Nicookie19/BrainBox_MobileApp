import 'package:flutter/material.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({required this.size, super.key});
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      gradient: AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(size * 0.25),
    ),
    child: Icon(
      Icons.psychology_alt_rounded,
      color: AppColors.textOnAccent,
      size: size * 0.55,
    ),
  );
}