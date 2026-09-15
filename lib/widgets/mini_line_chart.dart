import 'package:flutter/material.dart';

class MiniLineChart extends StatelessWidget {
  const MiniLineChart({
    super.key,
    required this.values,
    this.height = 150,
  });

  final List<double> values;
  final double height;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _MiniLineChartPainter(
          values: values,
          lineColor: scheme.primary,
          gridColor: scheme.outlineVariant.withOpacity(0.55),
          pointColor: scheme.primary,
        ),
      ),
    );
  }
}

class _MiniLineChartPainter extends CustomPainter {
  _MiniLineChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
    required this.pointColor,
  });

  final List<double> values;
  final Color lineColor;
  final Color gridColor;
  final Color pointColor;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;

    for (var i = 0; i <= 4; i++) {
      final y = size.height * i / 4;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final pointPaint = Paint()
      ..color = pointColor
      ..style = PaintingStyle.fill;

    Offset pointFor(int index) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * index / (values.length - 1);
      final value = values[index].clamp(0, 100).toDouble();
      final y = size.height - (value / 100) * size.height;
      return Offset(x, y);
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final point = pointFor(i);
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }

    canvas.drawPath(path, linePaint);

    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(pointFor(i), 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _MiniLineChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}
