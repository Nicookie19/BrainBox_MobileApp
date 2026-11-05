import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import '../../data/models/learning_models.dart';
import 'asset_icon.dart';

class CourseIcon extends StatelessWidget {
  const CourseIcon({
    required this.courseId,
    this.size = 40,
    this.fallback,
    this.category,
    super.key,
  });

  final String courseId;
  final double size;
  final Widget? fallback;
  final LearningCategory? category;

  static const _courseAssets = <String, String>{
    'frontend-foundations': AppAssets.javascript,
    'python-essentials': AppAssets.python,
    'data-structures': AppAssets.dataStructures,
    'sql-basics': AppAssets.database,
    'networking-fundamentals': AppAssets.networking,
    'flutter-from-zero': AppAssets.flutter,
    'machine-learning-basics': AppAssets.machineLearning,
  };

  @override
  Widget build(BuildContext context) {
    final asset = _courseAssets[courseId];
    if (asset != null) {
      return AssetIcon(asset, size: size);
    }
    if (fallback != null) return fallback!;
    return Icon(category?.icon ?? Icons.school_outlined, size: size);
  }
}
