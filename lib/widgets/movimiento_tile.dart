import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/movimiento_model.dart';
import '../screens/form_screen.dart';
import '../screens/movimiento_detail_screen.dart';
import '../theme/app_theme.dart';
import '../utils/categorias.dart';

class MovimientoTile extends StatelessWidget {
  final Movimiento movimiento;
  final VoidCallback onChanged;

  const MovimientoTile({
    super.key,
    required this.movimiento,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'es', symbol: '\$');
    final colors = context.colors;
    final esIngreso = movimiento.tipo == 'ingreso';
    final iconoCategoria = getCategoriaIcono(movimiento.categoria);
    final colorCategoria = getCategoriaColor(movimiento.categoria);
    final montoColor = esIngreso ? colors.income : colors.expense;

    DateTime? fechaParseada;
    try {
      fechaParseada = DateTime.parse(movimiento.fecha);
    } catch (_) {}
    final fechaDisplay = fechaParseada != null
        ? DateFormat('dd MMM', 'es').format(fechaParseada)
        : movimiento.fecha;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Dismissible(
          key: ValueKey('movimiento-${movimiento.id}-${movimiento.fecha}'),
          confirmDismiss: (direction) async {
            if (direction == DismissDirection.startToEnd) {
              HapticFeedback.selectionClick();
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FormScreen(movimiento: movimiento),
                ),
              );
              if (result == true) onChanged();
              return false;
            }
            HapticFeedback.mediumImpact();
            return _confirmarEliminar(context);
          },
          background: _SwipeBackground(
            color: colors.primary,
            icon: Icons.edit_rounded,
            label: 'Editar',
            alignment: Alignment.centerLeft,
          ),
          secondaryBackground: _SwipeBackground(
            color: colors.expense,
            icon: Icons.delete_rounded,
            label: 'Eliminar',
            alignment: Alignment.centerRight,
          ),
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppRadius.md),
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () async {
                HapticFeedback.selectionClick();
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        MovimientoDetailScreen(movimiento: movimiento),
                  ),
                );
                if (result == true) onChanged();
              },
              onLongPress: () async {
                HapticFeedback.mediumImpact();
                await _confirmarEliminar(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: colors.border),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: colorCategoria.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(AppRadius.md),
                      ),
                      child: Icon(
                        iconoCategoria,
                        color: colorCategoria,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            movimiento.titulo,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: colors.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 5),
                          Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            spacing: 7,
                            runSpacing: 4,
                            children: [
                              _MetaChip(
                                label: movimiento.categoria,
                                color: colorCategoria,
                              ),
                              Text(
                                fechaDisplay,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: colors.textMuted,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          esIngreso ? 'Ingreso' : 'Egreso',
                          style: TextStyle(
                            color: montoColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${esIngreso ? '+' : '-'}${formatter.format(movimiento.monto)}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: montoColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _confirmarEliminar(BuildContext context) async {
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return false;
    await DatabaseHelper().deleteMovimiento(movimiento.id!);
    onChanged();
    return true;
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MetaChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SwipeBackground extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String label;
  final Alignment alignment;

  const _SwipeBackground({
    required this.color,
    required this.icon,
    required this.label,
    required this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    final isLeft = alignment == Alignment.centerLeft;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: alignment,
      child: Row(
        mainAxisAlignment: isLeft
            ? MainAxisAlignment.start
            : MainAxisAlignment.end,
        children: [
          if (isLeft) ...[
            Icon(icon, color: Colors.white),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (!isLeft) ...[
            const SizedBox(width: 8),
            Icon(icon, color: Colors.white),
          ],
        ],
      ),
    );
  }
}
