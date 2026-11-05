import 'package:flutter/material.dart';

import '../../core/constants/app_assets.dart';
import 'asset_icon.dart';

class LevelBadge extends StatelessWidget {
  const LevelBadge({required this.levelNumber, this.size = 28, super.key});

  final int levelNumber;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = switch (levelNumber) {
      <= 3 => AppAssets.badgeBronze,
      <= 6 => AppAssets.badgeSilver,
      _ => AppAssets.crown,
    };
    return AssetIcon(asset, size: size);
  }
}
