import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/app_colors.dart';

/// Renders an unDraw illustration from [asset].
///
/// [asset] is resolved through `SvgPicture.asset`. While the SVG is fetched and
/// decoded, `placeholderBuilder` draws the fallback below, so the surrounding
/// layout keeps its height and the screen never collapses.
///
/// The fallback - a groups icon in a soft tinted circle - is the documented
/// stand-in used when an illustration cannot be shown:
///
/// ```dart
/// const UndrawIllustration('assets/illustrations/team_collaboration.svg');
/// ```
///
/// Dropping in the real SVG later needs no other change, because the widget API
/// stays the same.
class UndrawIllustration extends StatelessWidget {
  const UndrawIllustration(
    this.asset, {
    super.key,
    this.height,
    this.fit = BoxFit.contain,
  });

  final String asset;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      asset,
      height: height,
      fit: fit,
      placeholderBuilder: (BuildContext context) => _fallback(),
    );
  }

  // TODO: delete once every screen ships its final unDraw SVG.
  Widget _fallback() {
    final double diameter = height ?? 200;
    return Container(
      width: diameter,
      height: diameter,
      decoration: const BoxDecoration(
        color: AppColors.statTotalBg,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.groups_rounded,
        size: diameter * 0.6,
        color: AppColors.primary,
      ),
    );
  }
}
