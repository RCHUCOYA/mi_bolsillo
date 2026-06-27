import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/movimiento_model.dart';
import '../theme/app_theme.dart';
import '../utils/categorias.dart';
import '../widgets/movimiento_tile.dart';
import '../widgets/resumen_card.dart';
import 'form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper();

  List<Movimiento> _movimientos = [];
  double _ingresos = 0;
  double _egresos = 0;
  bool _cargando = true;

  String _filtroActivo = 'Todos';

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _cargando = true);

    String? tipoFiltro;
    String? categoriaFiltro;

    if (_filtroActivo == 'Ingresos') {
      tipoFiltro = 'ingreso';
    } else if (_filtroActivo == 'Egresos') {
      tipoFiltro = 'egreso';
    } else if (_filtroActivo != 'Todos') {
      categoriaFiltro = _filtroActivo;
    }

    final movimientos = await _db.getMovimientosFiltrados(
      tipo: tipoFiltro,
      categoria: categoriaFiltro,
    );
    final ingresos = await _db.getTotalByTipo('ingreso');
    final egresos = await _db.getTotalByTipo('egreso');

    if (mounted) {
      setState(() {
        _movimientos = movimientos;
        _ingresos = ingresos;
        _egresos = egresos;
        _cargando = false;
      });
    }
  }

  Future<void> _navegarAFormulario([Movimiento? movimiento]) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormScreen(movimiento: movimiento)),
    );
    if (result == true) _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _cargarDatos,
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: ResumenCard(
                            ingresos: _ingresos,
                            egresos: _egresos,
                          ),
                        ),
                        _buildFiltros(),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  if (_cargando)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  else if (_movimientos.isEmpty)
                    SliverFillRemaining(child: _buildEstadoVacio())
                  else
                    _buildMovimientosAgrupados(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildHeader() {
    final now = DateTime.now();
    final mesAnio = DateFormat('MMMM yyyy', 'es').format(now);
    final mesCapitalizado = mesAnio[0].toUpperCase() + mesAnio.substring(1);
    final movimientosLabel = _movimientos.length == 1
        ? '1 movimiento'
        : '${_movimientos.length} movimientos';

    return Container(
      decoration: const BoxDecoration(gradient: AppGradients.primary),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Colors.white,
                      size: 23,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'MiBolsillo',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                    ),
                    child: Text(
                      mesCapitalizado,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                movimientosLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    final filtros = [
      {'label': 'Todos', 'icono': Icons.auto_awesome_rounded, 'color': null},
      {
        'label': 'Ingresos',
        'icono': Icons.arrow_upward_rounded,
        'color': AppColors.income,
      },
      {
        'label': 'Egresos',
        'icono': Icons.arrow_downward_rounded,
        'color': AppColors.expense,
      },
      ...categorias.map(
        (c) => {'label': c['nombre'], 'icono': c['icono'], 'color': c['color']},
      ),
    ];

    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filtros.length,
        separatorBuilder: (_, x) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filtro = filtros[index];
          final label = filtro['label'] as String;
          final icono = filtro['icono'] as IconData;
          final color = filtro['color'] as Color? ?? AppColors.primary;
          final activo = _filtroActivo == label;

          return ChoiceChip(
            selected: activo,
            showCheckmark: false,
            avatar: Icon(icono, size: 16, color: activo ? Colors.white : color),
            label: Text(label),
            labelStyle: TextStyle(
              color: activo ? Colors.white : AppColors.text,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            selectedColor: color,
            backgroundColor: AppColors.surface,
            side: BorderSide(color: activo ? color : AppColors.border),
            shape: const StadiumBorder(),
            onSelected: (_) {
              setState(() => _filtroActivo = label);
              _cargarDatos();
            },
          );
        },
      ),
    );
  }

  Widget _buildMovimientosAgrupados() {
    final items = <Widget>[];
    String? ultimoGrupo;

    for (final movimiento in _movimientos) {
      final grupo = _grupoFecha(movimiento.fecha);
      if (grupo != ultimoGrupo) {
        items.add(_SeccionFecha(titulo: grupo));
        ultimoGrupo = grupo;
      }
      items.add(
        MovimientoTile(movimiento: movimiento, onChanged: _cargarDatos),
      );
    }

    items.add(const SizedBox(height: 96));

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => items[index],
        childCount: items.length,
      ),
    );
  }

  String _grupoFecha(String fecha) {
    DateTime parsed;
    try {
      parsed = DateTime.parse(fecha);
    } catch (_) {
      return fecha;
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(parsed.year, parsed.month, parsed.day);
    final diff = today.difference(day).inDays;

    if (diff == 0) return 'Hoy';
    if (diff == 1) return 'Ayer';
    if (parsed.year == now.year && parsed.month == now.month) {
      return 'Este mes';
    }
    final label = DateFormat('MMMM yyyy', 'es').format(parsed);
    return label[0].toUpperCase() + label.substring(1);
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 52,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Sin movimientos',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Registra tu primer ingreso o gasto para ver el resumen del mes.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => _navegarAFormulario(),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Agregar movimiento'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: _navegarAFormulario,
      shape: const CircleBorder(),
      child: const Icon(Icons.add_rounded, size: 30),
    );
  }
}

class _SeccionFecha extends StatelessWidget {
  final String titulo;

  const _SeccionFecha({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        titulo,
        style: const TextStyle(
          color: AppColors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
