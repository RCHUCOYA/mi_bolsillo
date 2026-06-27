import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/movimiento_model.dart';
import '../theme/app_theme.dart';
import '../utils/categorias.dart';
import 'form_screen.dart';

class MovimientoDetailScreen extends StatelessWidget {
  final Movimiento movimiento;

  const MovimientoDetailScreen({super.key, required this.movimiento});

  Future<void> _editar(BuildContext context) async {
    HapticFeedback.selectionClick();
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormScreen(movimiento: movimiento)),
    );
    if (context.mounted) Navigator.pop(context, result == true);
  }

  Future<void> _eliminar(BuildContext context) async {
    HapticFeedback.mediumImpact();
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: const Text('Eliminar movimiento'),
        content: Text(
          'Deseas eliminar "${movimiento.titulo}"? Esta accion no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.expense,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;
    await DatabaseHelper().deleteMovimiento(movimiento.id!);
    if (context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final formatter = NumberFormat.currency(locale: 'es', symbol: '\$');
    final esIngreso = movimiento.tipo == 'ingreso';
    final colorTipo = esIngreso ? colors.income : colors.expense;
    final categoriaColor = getCategoriaColor(movimiento.categoria);
    final categoriaIcon = getCategoriaIcono(movimiento.categoria);
    final fecha = DateTime.tryParse(movimiento.fecha);

    return Scaffold(
      body: Column(
        children: [
          Container(
            decoration: BoxDecoration(gradient: colors.primaryGradient),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 16, 22),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Expanded(
                      child: Text(
                        'Detalle',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => _editar(context),
                      icon: const Icon(Icons.edit_rounded, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                    border: Border.all(color: colors.border),
                    boxShadow: context.softShadow(),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Hero(
                            tag: 'cat-icon-${movimiento.id}',
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: categoriaColor.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(AppRadius.lg),
                              ),
                              child: Icon(
                                categoriaIcon,
                                color: categoriaColor,
                                size: 28,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  movimiento.titulo,
                                  style: TextStyle(
                                    color: colors.text,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  movimiento.categoria,
                                  style: TextStyle(
                                    color: colors.textMuted,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${esIngreso ? '+' : '-'}${formatter.format(movimiento.monto)}',
                          style: TextStyle(
                            color: colorTipo,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                _DetailRow(
                  icon: esIngreso
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  label: 'Tipo',
                  value: esIngreso ? 'Ingreso' : 'Egreso',
                  color: colorTipo,
                ),
                _DetailRow(
                  icon: Icons.calendar_today_rounded,
                  label: 'Fecha',
                  value: fecha == null
                      ? movimiento.fecha
                      : DateFormat('EEEE d MMMM yyyy', 'es').format(fecha),
                  color: colors.primary,
                ),
                if (movimiento.notas.trim().isNotEmpty)
                  _PostItNotes(notes: movimiento.notas)
                else
                  _DetailRow(
                    icon: Icons.notes_rounded,
                    label: 'Notas',
                    value: 'Sin notas',
                    color: colors.accent,
                  ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _editar(context),
                        icon: const Icon(Icons.edit_rounded),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => _eliminar(context),
                        icon: const Icon(Icons.delete_rounded),
                        label: const Text('Eliminar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: colors.expense,
                          foregroundColor: Colors.white,
                        ),
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

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
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

class _PostItNotes extends StatelessWidget {
  final String notes;

  const _PostItNotes({required this.notes});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2E2B1A) : const Color(0xFFFFFDE7),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? const Color(0xFF6D5E20) : const Color(0xFFFFEE58),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFEB3B).withValues(alpha: 0.14),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.sticky_note_2_rounded,
            color: isDark ? const Color(0xFFFFD54F) : const Color(0xFFFFB300),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Notas',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFFFD54F)
                        : const Color(0xFFFF8F00),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  notes,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFFFFE082)
                        : const Color(0xFF5D4037),
                    fontSize: 14,
                    height: 1.45,
                    fontStyle: FontStyle.italic,
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
