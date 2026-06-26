import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ResumenCard extends StatelessWidget {
  final double ingresos;
  final double egresos;

  const ResumenCard({
    super.key,
    required this.ingresos,
    required this.egresos,
  });

  @override
  Widget build(BuildContext context) {
    final double balance = ingresos - egresos;
    final formatter = NumberFormat.currency(locale: 'es', symbol: '\$');
    final bool positivo = balance >= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Balance del mes',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              formatter.format(balance),
              style: TextStyle(
                color: positivo
                    ? const Color(0xFF69FF84)
                    : const Color(0xFFFF6B6B),
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Container(height: 1, color: Colors.white24),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _MontoColumna(
                  label: '↑ Ingresos',
                  monto: formatter.format(ingresos),
                  color: const Color(0xFF69FF84),
                ),
                Container(width: 1, height: 40, color: Colors.white24),
                _MontoColumna(
                  label: '↓ Egresos',
                  monto: formatter.format(egresos),
                  color: const Color(0xFFFF6B6B),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MontoColumna extends StatelessWidget {
  final String label;
  final String monto;
  final Color color;

  const _MontoColumna({
    required this.label,
    required this.monto,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          monto,
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
