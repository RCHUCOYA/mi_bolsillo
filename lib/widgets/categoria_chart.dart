import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../utils/categorias.dart';

class CategoriaChart extends StatelessWidget {
  final Map<String, double> totales;
  final double egresos;

  const CategoriaChart({
    super.key,
    required this.totales,
    required this.egresos,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formatter = NumberFormat.currency(locale: 'es', symbol: '\$');
    final entries = totales.entries.where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topEntries = entries.take(4).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
        boxShadow: context.softShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.donut_large_rounded, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Gastos por categoría',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                formatter.format(egresos),
                style: TextStyle(
                  color: colors.expense,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (topEntries.isEmpty)
            _ChartEmpty()
          else
            Row(
              children: [
                SizedBox(
                  width: 116,
                  height: 116,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      entries: topEntries,
                      total: egresos,
                      fallbackColor: colors.border,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${topEntries.length}',
                            style: TextStyle(
                              color: colors.text,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'top',
                            style: TextStyle(
                              color: colors.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: topEntries.map((entry) {
                      final color = getCategoriaColor(entry.key);
                      final percent = egresos == 0 ? 0 : entry.value / egresos;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _CategoryBar(
                          label: entry.key,
                          amount: formatter.format(entry.value),
                          percent: percent.clamp(0, 1).toDouble(),
                          color: color,
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _CategoryBar extends StatelessWidget {
  final String label;
  final String amount;
  final double percent;
  final Color color;

  const _CategoryBar({
    required this.label,
    required this.amount,
    required this.percent,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                color: colors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: percent,
            minHeight: 6,
            backgroundColor: colors.surfaceSoft,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

class _ChartEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Text(
        'Cuando registres egresos verás aquí tus categorías principales.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: colors.textMuted,
          height: 1.35,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<MapEntry<String, double>> entries;
  final double total;
  final Color fallbackColor;

  _DonutPainter({
    required this.entries,
    required this.total,
    required this.fallbackColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;

    paint.color = fallbackColor;
    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, paint);

    if (total <= 0) return;

    var start = -math.pi / 2;
    for (final entry in entries) {
      final sweep = (entry.value / total) * math.pi * 2;
      paint.color = getCategoriaColor(entry.key);
      canvas.drawArc(rect, start, math.max(0.08, sweep - 0.035), false, paint);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.entries != entries ||
        oldDelegate.total != total ||
        oldDelegate.fallbackColor != fallbackColor;
  }
}
