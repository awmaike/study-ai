import 'package:flutter/material.dart';

enum StudyGlyphKind {
  book,
  summary,
  explanation,
  quiz,
  cards,
  home,
  progress,
  settings
}

/// A small set of matching line illustrations for the StudyAI interface.
class StudyGlyph extends StatelessWidget {
  const StudyGlyph(this.kind, {super.key, this.color, this.size = 26});
  final StudyGlyphKind kind;
  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) => SizedBox.square(
        dimension: size,
        child: CustomPaint(
            painter: _GlyphPainter(
                kind,
                color ??
                    IconTheme.of(context).color ??
                    Theme.of(context).colorScheme.primary)),
      );
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter(this.kind, this.color);
  final StudyGlyphKind kind;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 32, size.height / 32);
    final pen = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.9
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), pen);
    void box(double left, double top, double width, double height) =>
        canvas.drawRRect(
            RRect.fromRectAndRadius(Rect.fromLTWH(left, top, width, height),
                const Radius.circular(3)),
            pen);
    switch (kind) {
      case StudyGlyphKind.book:
        canvas.drawPath(
            Path()
              ..moveTo(16, 10)
              ..quadraticBezierTo(10, 5, 3, 7)
              ..lineTo(3, 25)
              ..quadraticBezierTo(10, 23, 16, 28)
              ..quadraticBezierTo(22, 23, 29, 25)
              ..lineTo(29, 7)
              ..quadraticBezierTo(22, 5, 16, 10)
              ..lineTo(16, 28),
            pen);
        line(7, 12, 12, 14);
        line(7, 17, 12, 19);
        line(21, 13, 25, 11);
        break;
      case StudyGlyphKind.summary:
        box(6, 3, 20, 26);
        line(11, 10, 21, 10);
        line(11, 15, 21, 15);
        line(11, 20, 17, 20);
        break;
      case StudyGlyphKind.explanation:
        canvas.drawPath(
            Path()
              ..moveTo(11, 23)
              ..lineTo(11, 20)
              ..cubicTo(2, 12, 10, 4, 16, 4)
              ..cubicTo(24, 4, 28, 13, 21, 20)
              ..lineTo(21, 23)
              ..close(),
            pen);
        line(12, 27, 20, 27);
        line(16, 22, 16, 15);
        line(12, 13, 16, 16);
        line(20, 13, 16, 16);
        line(2, 4, 4, 6);
        line(28, 6, 30, 4);
        break;
      case StudyGlyphKind.quiz:
        box(5, 5, 23, 23);
        canvas.drawPath(
            Path()
              ..moveTo(10, 17)
              ..lineTo(14, 21)
              ..lineTo(23, 12),
            pen);
        line(11, 3, 20, 3);
        break;
      case StudyGlyphKind.cards:
        canvas.save();
        canvas.translate(15, 15);
        canvas.rotate(-.18);
        box(-11, -12, 20, 24);
        canvas.restore();
        canvas.drawRRect(
            RRect.fromRectAndRadius(
                const Rect.fromLTWH(10, 7, 18, 23), const Radius.circular(3)),
            Paint()..color = color.withValues(alpha: .13));
        box(10, 7, 18, 23);
        line(15, 15, 23, 15);
        line(15, 20, 20, 20);
        break;
      case StudyGlyphKind.home:
        canvas.drawPath(
            Path()
              ..moveTo(3, 15)
              ..lineTo(16, 4)
              ..lineTo(29, 15)
              ..moveTo(7, 13)
              ..lineTo(7, 28)
              ..lineTo(25, 28)
              ..lineTo(25, 13),
            pen);
        box(13, 20, 6, 8);
        break;
      case StudyGlyphKind.progress:
        line(5, 4, 5, 28);
        line(5, 28, 29, 28);
        canvas.drawPath(
            Path()
              ..moveTo(10, 21)
              ..lineTo(16, 14)
              ..lineTo(21, 17)
              ..lineTo(28, 7),
            pen);
        line(22, 7, 28, 7);
        line(28, 7, 28, 13);
        break;
      case StudyGlyphKind.settings:
        for (var i = 0; i < 3; i++) {
          final y = 8.0 + i * 8;
          final x = i == 1 ? 21.0 : 11.0;
          line(4, y, x - 3, y);
          line(x + 3, y, 28, y);
          canvas.drawCircle(Offset(x, y), 3, pen);
        }
        break;
    }
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) =>
      kind != oldDelegate.kind || color != oldDelegate.color;
}
