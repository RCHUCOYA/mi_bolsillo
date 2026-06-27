import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class TendenciaChart extends StatelessWidget {
  /// Lista de mapas con claves 'mes' (DateTime), 'ingresos' (double), 'egresos' (double).
  final List<Map<String, dynamic>> datos;

  const TendenciaChart({super.key, required this.datos});

  @override
  Widget build(BuildContext context) {
    if (datos.isEmpty) return const SizedBox.shrink();

    final colors = context.colors;

    // Solo mostrar si hay al menos un mes con datos
    final hayDatos = datos.any(
      (d) => (d['ingresos'] as double) > 0 || (d['egresos'] as double) > 0,
    );
    if (!hayDatos) return const SizedBox.shrink();

    final maxVal = datos.fold<double>(1, (m, d) {
      return [m, d['ingresos'] as double, d['egresos'] as double]
          .reduce((a, b) => a > b ? a : b);
    });

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
              Icon(Icons.bar_chart_rounded, color: colors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Tendencia de 6 meses',
                style: TextStyle(
                  color: colors.text,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 96,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: datos.map((d) {
                final mes = d['mes'] as DateTime;
                final ingresos = d['ingresos'] as double;
                final egresos = d['egresos'] as double;
                final label =
                    DateFormat('MMM', 'es').format(mes).substring(0, 3);

                return Expanded(
                  child: _MesBar(
                    label: label,
                    ingresos: ingresos,
                    egresos: egresos,
                    maxVal: maxVal,
                    incomeColor: colors.income,
                    expenseColor: colors.expense,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _Leyenda(color: colors.income, label: 'Ingresos'),
              const SizedBox(width: 18),
              _Leyenda(color: colors.expense, label: 'Egresos'),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _MesBar extends StatelessWidget {
  final String label;
  final double ingresos;
  final double egresos;
  final double maxVal;
  final Color incomeColor;
  final Color expenseColor;

  const _MesBar({
    required this.label,
    required this.ingresos,
    required this.egresos,
    required this.maxVal,
    required this.incomeColor,
    required this.expenseColor,
  });

  @override
  Widget build(BuildContext context) {
    final ingRatio = maxVal > 0 ? (ingresos / maxVal).clamp(0.0, 1.0) : 0.0;
    final egsRatio = maxVal > 0 ? (egresos / maxVal).clamp(0.0, 1.0) : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Barra de ingresos
                Flexible(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: ingRatio),
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, _) => FractionallySizedBox(
                      heightFactor: val,
                      child: Container(
                        margin: const EdgeInsets.only(right: 1),
                        decoration: BoxDecoration(
                          color: incomeColor.withValues(alpha: 0.72),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Barra de egresos
                Flexible(
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: egsRatio),
                    duration: const Duration(milliseconds: 750),
                    curve: Curves.easeOutCubic,
                    builder: (_, val, _) => FractionallySizedBox(
                      heightFactor: val,
                      child: Container(
                        margin: const EdgeInsets.only(left: 1),
                        decoration: BoxDecoration(
                          color: expenseColor.withValues(alpha: 0.72),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: context.colors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  final Color color;
  final String label;

  const _Leyenda({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: context.colors.textMuted,
          ),
        ),
      ],
    );
  }
}
