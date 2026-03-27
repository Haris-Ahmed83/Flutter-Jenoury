import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LineChartPoint {
  final String label;
  final double value;

  const LineChartPoint({required this.label, required this.value});
}

class SimpleLineChart extends StatelessWidget {
  final List<LineChartPoint> data;
  final double height;
  final Color lineColor;
  final Color fillColor;
  final bool showDots;
  final bool showGrid;
  final String? unit;

  const SimpleLineChart({
    super.key,
    required this.data,
    this.height = 200,
    this.lineColor = AppColors.primary,
    Color? fillColor,
    this.showDots = true,
    this.showGrid = true,
    this.unit,
  }) : fillColor = fillColor ?? const Color(0x206C63FF);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text('No data available', style: AppTextStyles.bodySecondary),
        ),
      );
    }

    return SizedBox(
      height: height,
      child: Column(
        children: [
          Expanded(
            child: CustomPaint(
              size: Size.infinite,
              painter: _LineChartPainter(
                data: data,
                lineColor: lineColor,
                fillColor: fillColor,
                showDots: showDots,
                showGrid: showGrid,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: data.map((p) {
              return Expanded(
                child: Text(
                  p.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<LineChartPoint> data;
  final Color lineColor;
  final Color fillColor;
  final bool showDots;
  final bool showGrid;

  _LineChartPainter({
    required this.data,
    required this.lineColor,
    required this.fillColor,
    required this.showDots,
    required this.showGrid,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final maxVal =
        data.fold<double>(0, (m, p) => p.value > m ? p.value : m);
    final minVal =
        data.fold<double>(double.infinity, (m, p) => p.value < m ? p.value : m);
    final range = maxVal - minVal;
    final safeRange = range > 0 ? range : 1;
    final padding = size.height * 0.1;

    // Draw grid lines
    if (showGrid) {
      final gridPaint = Paint()
        ..color = const Color(0xFFE5E7EB)
        ..strokeWidth = 0.5;

      for (int i = 0; i <= 4; i++) {
        final y = padding + (size.height - 2 * padding) * i / 4;
        canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
      }
    }

    // Calculate points
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = data.length > 1
          ? i * size.width / (data.length - 1)
          : size.width / 2;
      final normalizedY = (data[i].value - minVal) / safeRange;
      final y = size.height - padding - normalizedY * (size.height - 2 * padding);
      points.add(Offset(x, y));
    }

    // Draw fill
    if (points.length > 1) {
      final fillPath = Path()..moveTo(points.first.dx, size.height);
      for (final point in points) {
        fillPath.lineTo(point.dx, point.dy);
      }
      fillPath.lineTo(points.last.dx, size.height);
      fillPath.close();

      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            fillColor,
            fillColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

      canvas.drawPath(fillPath, fillPaint);

      // Draw line
      final linePath = Path()..moveTo(points.first.dx, points.first.dy);
      for (int i = 1; i < points.length; i++) {
        // Smooth curve using cubic bezier
        final prev = points[i - 1];
        final curr = points[i];
        final cpx = (prev.dx + curr.dx) / 2;
        linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
      }

      final linePaint = Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawPath(linePath, linePaint);
    }

    // Draw dots
    if (showDots) {
      for (int i = 0; i < points.length; i++) {
        final isLast = i == points.length - 1;
        canvas.drawCircle(
          points[i],
          isLast ? 5 : 3,
          Paint()..color = lineColor,
        );
        if (isLast) {
          canvas.drawCircle(
            points[i],
            3,
            Paint()..color = Colors.white,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
