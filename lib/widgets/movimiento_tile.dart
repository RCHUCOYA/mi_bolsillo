import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/movimiento_model.dart';
import '../utils/categorias.dart';
import '../database/database_helper.dart';
import '../screens/form_screen.dart';

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
    final esIngreso = movimiento.tipo == 'ingreso';
    final iconoCategoria = getCategoriaIcono(movimiento.categoria);
    final colorCategoria = getCategoriaColor(movimiento.categoria);

    DateTime? fechaParseada;
    try {
      fechaParseada = DateTime.parse(movimiento.fecha);
    } catch (_) {}
    final fechaDisplay = fechaParseada != null
        ? DateFormat('dd/MM/yyyy').format(fechaParseada)
        : movimiento.fecha;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => FormScreen(movimiento: movimiento),
            ),
          );
          if (result == true) onChanged();
        },
        onLongPress: () => _confirmarEliminar(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: colorCategoria.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconoCategoria, color: colorCategoria, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      movimiento.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                        color: Color(0xFF1A1A2E),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${movimiento.categoria}  ·  $fechaDisplay',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${esIngreso ? '+' : '-'}${formatter.format(movimiento.monto)}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: esIngreso
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFE53935),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmarEliminar(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar movimiento'),
        content: Text(
            '¿Deseas eliminar "${movimiento.titulo}"? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await DatabaseHelper().deleteMovimiento(movimiento.id!);
              onChanged();
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
