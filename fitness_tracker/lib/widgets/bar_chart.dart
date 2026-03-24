import 'package:flutter/material.dart';
import '../utils/constants.dart';

class BarChartData {
  final String label;
  final double value;
  final Color? color;

  const BarChartData({
    required this.label,
    required this.value,
    this.color,
  });
}

class SimpleBarChart extends StatelessWidget {
  final List<BarChartData> data;
  final double height;
  final Color defaultColor;
  final String? unit;
  final bool showValues;

  const SimpleBarChart({
    super.key,
    required this.data,
    this.height = 200,
    this.defaultColor = AppColors.primary,
    this.unit,
    this.showValues = true,
  });

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

    final maxValue = data.fold<double>(
        0, (max, item) => item.value > max ? item.value : max);
    final safeMax = maxValue > 0 ? maxValue : 1;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: data.map((item) {
          final barHeight = (item.value / safeMax) * (height - 40);
          final color = item.color ?? defaultColor;
          final isToday = data.indexOf(item) == data.length - 1;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (showValues && item.value > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        _formatValue(item.value),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isToday ? color : AppColors.textSecondary,
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    height: barHeight.clamp(4.0, height - 40),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          color.withValues(alpha: isToday ? 1.0 : 0.5),
                          color.withValues(alpha: isToday ? 0.8 : 0.3),
                        ],
                      ),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                      color: isToday
                          ? AppColors.textPrimary
                          : AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _formatValue(double value) {
    if (value >= 10000) return '${(value / 1000).toStringAsFixed(1)}k';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }
}
