import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

/// Bold caption that introduces a group of items.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: AppTextStyles.title);
  }
}
