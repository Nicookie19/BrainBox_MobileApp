import 'package:flutter/material.dart';

import 'package:brainbox/core/constants/app_assets.dart';
import 'package:brainbox/data/models/learning_models.dart';
import 'package:brainbox/presentation/widgets/asset_icon.dart';

/// Supplied artwork is kept in its original square aspect ratio.  Keeping the
/// image inside a bounded square prevents wide cards and compact phones from
/// stretching the illustrations.
class CourseArtwork extends StatelessWidget {
  const CourseArtwork({required this.category, this.size = 40, super.key});

  final LearningCategory category;
  final double size;

  @override
  Widget build(BuildContext context) =>
      AssetIcon(_assetFor(category), size: size);

  static String _assetFor(LearningCategory category) {
    switch (category) {
      case LearningCategory.webDevelopment:
        return AppAssets.web;
      case LearningCategory.databases:
        return AppAssets.database;
      case LearningCategory.programmingLanguages:
        return AppAssets.python;
      case LearningCategory.machineLearning:
        return AppAssets.machineLearning;
      case LearningCategory.mobileDevelopment:
        return AppAssets.flutter;
      case LearningCategory.networking:
        return AppAssets.networking;
      case LearningCategory.devops:
      case LearningCategory.projectManagement:
        return AppAssets.javascript;
    }
  }
}
