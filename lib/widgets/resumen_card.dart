import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';

class ResumenCard extends StatelessWidget {
  final double ingresos;
  final double egresos;
  final double? ingresosAnterior;
  final double? egresosAnterior;

  const ResumenCard({
    super.key,
    required this.ingresos,
    required this.egresos,
    this.ingresosAnterior,
    this.egresosAnterior,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final balance = ingresos - egresos;
    final formatter = NumberFormat.currency(locale: 'es', symbol: '\$');
    final positivo = balance >= 0;
    final total = ingresos + egresos;
    final gastoRatio = total == 0 ? 0.0 : (egresos / total).clamp(0.0, 1.0);

    double? cambioIngresos;
    if (ingresosAnterior != null && ingresosAnterior! > 0) {
      cambioIngresos = ((ingresos - ingresosAnterior!) / ingresosAnterior!) * 100;
    }
    double? cambioEgresos;
    if (egresosAnterior != null && egresosAnterior! > 0) {
      cambioEgresos = ((egresos - egresosAnterior!) / egresosAnterior!) * 100;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        gradient: colors.primaryGradient,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: context.softShadow(colors.primary),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -40,
            top: -36,
            child: Container(
              width: 132,
              height: 132,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.09),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.16),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        positivo
                            ? Icons.trending_up_rounded
                            : Icons.trending_down_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Balance del mes',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _EstadoBalance(positivo: positivo),
                  ],
                ),
                const SizedBox(height: 18),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _AnimatedAmount(
                    value: balance,
                    formatter: formatter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  child: _AnimatedProgressBar(
                    value: gastoRatio,
                    backgroundColor: Colors.white.withValues(alpha: 0.18),
                    valueColor: positivo ? colors.accent : colors.warning,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: _MontoColumna(
                        icono: Icons.arrow_upward_rounded,
                        label: 'Ingresos',
                        monto: ingresos,
                        formatter: formatter,
                        color: const Color(0xFF8FF4C2),
                        cambio: cambioIngresos,
                        positiveIsGood: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MontoColumna(
                        icono: Icons.arrow_downward_rounded,
                        label: 'Egresos',
                        monto: egresos,
                        formatter: formatter,
                        color: const Color(0xFFFFA3A3),
                        cambio: cambioEgresos,
                        positiveIsGood: false,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EstadoBalance extends StatelessWidget {
  final bool positivo;

  const _EstadoBalance({required this.positivo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        positivo ? 'En orden' : 'Atencion',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MontoColumna extends StatelessWidget {
  final IconData icono;
  final String label;
  final double monto;
  final NumberFormat formatter;
  final Color color;
  final double? cambio;
  final bool positiveIsGood;

  const _MontoColumna({
    required this.icono,
    required this.label,
    required this.monto,
    required this.formatter,
    required this.color,
    this.cambio,
    this.positiveIsGood = true,
  });

  @override
  Widget build(BuildContext context) {
    final hasCambio = cambio != null && cambio!.abs() >= 1;
    final isUp = cambio != null && cambio! > 0;
    final isGood = isUp ? positiveIsGood : !positiveIsGood;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          Icon(icono, size: 17, color: color),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                    if (hasCambio) ...[
                      const SizedBox(width: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: (isGood ? Colors.greenAccent : Colors.redAccent)
                              .withValues(alpha: 0.28),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: Text(
                          '${isUp ? '▲' : '▼'} ${cambio!.abs().toStringAsFixed(0)}%',
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: _AnimatedAmount(
                    value: monto,
                    formatter: formatter,
                    style: TextStyle(
                      color: color,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedProgressBar extends StatelessWidget {
  final double value;
  final Color backgroundColor;
  final Color valueColor;

  const _AnimatedProgressBar({
    required this.value,
    required this.backgroundColor,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOutCubic,
      builder: (_, val, _) => LinearProgressIndicator(
        value: val,
        minHeight: 7,
        backgroundColor: backgroundColor,
        valueColor: AlwaysStoppedAnimation<Color>(valueColor),
      ),
    );
  }
}

class _AnimatedAmount extends StatefulWidget {
  final double value;
  final TextStyle style;
  final NumberFormat formatter;

  const _AnimatedAmount({
    required this.value,
    required this.style,
    required this.formatter,
  });

  @override
  State<_AnimatedAmount> createState() => _AnimatedAmountState();
}

class _AnimatedAmountState extends State<_AnimatedAmount>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _animation = Tween<double>(begin: 0, end: widget.value).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedAmount oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      final current = _animation.value;
      _animation = Tween<double>(begin: current, end: widget.value).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
      );
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, _) => Text(
        widget.formatter.format(_animation.value),
        style: widget.style,
      ),
    );
  }
}
