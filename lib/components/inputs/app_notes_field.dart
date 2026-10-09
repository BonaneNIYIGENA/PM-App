import 'package:flutter/material.dart';

import '../../core/theme/app_text_styles.dart';

/// Bordered multi-line text area used for task notes.
class AppNotesField extends StatelessWidget {
  const AppNotesField({
    super.key,
    this.hint = 'Add any additional notes...',
    this.controller,
    this.minLines = 3,
  });

  final String hint;
  final TextEditingController? controller;

  /// Minimum number of visible lines; the field grows with its content.
  final int minLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      minLines: minLines,
      maxLines: null,
      keyboardType: TextInputType.multiline,
      style: AppTextStyles.body,
      decoration: InputDecoration(hintText: hint),
    );
  }
}
