import 'package:flutter/material.dart';

import 'package:brainbox/data/models/learning_models.dart';

/// Supplied artwork is kept in its original square aspect ratio.  Keeping the
/// image inside a bounded square prevents wide cards and compact phones from
/// stretching the illustrations.
class CourseArtwork extends StatelessWidget {
  const CourseArtwork({required this.category, this.size = 40, super.key});

  final LearningCategory category;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: Image.asset(
      _assetFor(category),
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    ),
  );

  static String _assetFor(LearningCategory category) {
    switch (category) {
      case LearningCategory.webDevelopment:
        return 'assets/ui/web.png';
      case LearningCategory.databases:
        return 'assets/ui/database.png';
      case LearningCategory.programmingLanguages:
      case LearningCategory.machineLearning:
        return 'assets/ui/python.png';
      case LearningCategory.mobileDevelopment:
      case LearningCategory.networking:
      case LearningCategory.devops:
      case LearningCategory.projectManagement:
        return 'assets/ui/javascript.png';
    }
  }
}
