import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AssetIcon extends StatelessWidget {
  const AssetIcon(
    this.path, {
    this.size = 24,
    this.color,
    this.semanticLabel,
    super.key,
  });

  final String path;
  final double size;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final Widget image;
    if (path.toLowerCase().endsWith('.svg')) {
      image = SvgPicture.asset(
        path,
        width: size,
        height: size,
        colorFilter: color == null
            ? null
            : ColorFilter.mode(color!, BlendMode.srcIn),
      );
    } else {
      final ratio = MediaQuery.devicePixelRatioOf(context);
      image = Image.asset(
        path,
        width: size,
        height: size,
        cacheWidth: (size * ratio).round(),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        color: color,
        colorBlendMode: color == null ? null : BlendMode.srcIn,
      );
    }

    if (semanticLabel != null) {
      return Semantics(image: true, label: semanticLabel, child: image);
    }
    return ExcludeSemantics(child: image);
  }
}
