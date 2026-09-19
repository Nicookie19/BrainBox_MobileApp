import 'package:flutter/material.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class SectionHeading extends StatelessWidget {
  const SectionHeading({
    required this.title,
    required this.action,
    required this.onPressed,
    super.key,
  });

  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
        ),
      ),
      const Spacer(),
      TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppColors.accentPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: Text(
          action,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );
}