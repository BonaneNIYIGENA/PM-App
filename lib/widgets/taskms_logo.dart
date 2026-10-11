import 'package:flutter/material.dart';

// The taskMS mark: a tick breaking out of a box. Same shapes as
// assets/icon/taskms_logo.svg, drawn on a 256 x 256 artboard.
class TaskMsLogo extends StatelessWidget {
  const TaskMsLogo({super.key, this.size = 64});
  final double size;

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: const _LogoPainter());
}

class _LogoPainter extends CustomPainter {
  const _LogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 256;
    final shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFFFB13D), Color(0xFFF26A0E)],
    ).createShader(Offset.zero & size);

    Paint line(double width, {BlendMode? mode}) => Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = width * s
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = mode == null ? shader : null
      ..blendMode = mode ?? BlendMode.srcOver;

    final tick = Path()
      ..moveTo(83 * s, 135 * s)
      ..lineTo(115 * s, 167 * s)
      ..lineTo(196 * s, 71 * s);
    final gap = Path()
      ..moveTo(148 * s, 128 * s)
      ..lineTo(196 * s, 71 * s);
    final box = RRect.fromRectAndRadius(
      Rect.fromLTWH(57 * s, 70 * s, 120 * s, 120 * s),
      Radius.circular(26 * s),
    );

    // The box is drawn in its own layer so the gap can be cut out of it.
    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRRect(box, line(15));
    canvas.drawPath(gap, line(40, mode: BlendMode.clear));
    canvas.restore();

    canvas.drawPath(tick, line(23));
  }

  @override
  bool shouldRepaint(_LogoPainter oldDelegate) => false;
}
