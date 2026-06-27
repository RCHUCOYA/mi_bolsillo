import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../database/database_helper.dart';
import '../models/movimiento_model.dart';
import '../theme/app_theme.dart';
import '../utils/categorias.dart';
import '../widgets/categoria_chart.dart';
import '../widgets/dashboard_skeleton.dart';
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
  final ScrollController _scrollController = ScrollController();

  List<Movimiento> _movimientos = [];
  Map<String, double> _totalesPorCategoria = {};
  double _ingresos = 0;
  double _egresos = 0;
  bool _cargando = true;
  bool _mostrarFabExtendido = true;

  String _filtroActivo = 'Todos';
  DateTime _mesSeleccionado = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_actualizarFab);
    _cargarDatos();
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_actualizarFab)
      ..dispose();
    super.dispose();
  }

  void _actualizarFab() {
    final debeMostrar =
        !_scrollController.hasClients || _scrollController.offset < 80;
    if (debeMostrar != _mostrarFabExtendido) {
      setState(() => _mostrarFabExtendido = debeMostrar);
    }
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
      mes: _mesSeleccionado,
    );
    final ingresos = await _db.getTotalByTipo('ingreso', mes: _mesSeleccionado);
    final egresos = await _db.getTotalByTipo('egreso', mes: _mesSeleccionado);
    final totalesPorCategoria = await _db.getTotalesPorCategoria(
      mes: _mesSeleccionado,
      tipo: 'egreso',
    );

    if (mounted) {
      setState(() {
        _movimientos = movimientos;
        _ingresos = ingresos;
        _egresos = egresos;
        _totalesPorCategoria = totalesPorCategoria;
        _cargando = false;
      });
    }
  }

  void _cambiarMes(int delta) {
    HapticFeedback.selectionClick();
    final nuevoMes = DateTime(
      _mesSeleccionado.year,
      _mesSeleccionado.month + delta,
    );
    setState(() => _mesSeleccionado = nuevoMes);
    _cargarDatos();
  }

  Future<void> _navegarAFormulario([Movimiento? movimiento]) async {
    HapticFeedback.selectionClick();
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
              color: context.colors.primary,
              onRefresh: _cargarDatos,
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        if (!_cargando) ...[
                          Transform.translate(
                            offset: const Offset(0, -10),
                            child: ResumenCard(
                              ingresos: _ingresos,
                              egresos: _egresos,
                            ),
                          ),
                          CategoriaChart(
                            totales: _totalesPorCategoria,
                            egresos: _egresos,
                          ),
                          _buildInsight(),
                          _buildFiltros(),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  if (_cargando)
                    const DashboardSkeleton()
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
    final colors = context.colors;
    final mesAnio = DateFormat('MMMM yyyy', 'es').format(_mesSeleccionado);
    final mesCapitalizado = mesAnio[0].toUpperCase() + mesAnio.substring(1);
    final movimientosLabel = _movimientos.length == 1
        ? '1 movimiento'
        : '${_movimientos.length} movimientos';

    return Container(
      decoration: BoxDecoration(gradient: colors.primaryGradient),
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
                  _MonthSelector(
                    label: mesCapitalizado,
                    onPrevious: () => _cambiarMes(-1),
                    onNext: () => _cambiarMes(1),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      movimientosLabel,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  if (_filtroActivo != 'Todos')
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: Text(
                        _filtroActivo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFiltros() {
    final colors = context.colors;
    final filtros = [
      {'label': 'Todos', 'icono': Icons.auto_awesome_rounded, 'color': null},
      {
        'label': 'Ingresos',
        'icono': Icons.arrow_upward_rounded,
        'color': colors.income,
      },
      {
        'label': 'Egresos',
        'icono': Icons.arrow_downward_rounded,
        'color': colors.expense,
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
          final color = filtro['color'] as Color? ?? colors.primary;
          final activo = _filtroActivo == label;

          return ChoiceChip(
            selected: activo,
            showCheckmark: false,
            avatar: Icon(icono, size: 16, color: activo ? Colors.white : color),
            label: Text(label),
            labelStyle: TextStyle(
              color: activo ? Colors.white : colors.text,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            selectedColor: color,
            backgroundColor: colors.surface,
            side: BorderSide(color: activo ? color : colors.border),
            shape: const StadiumBorder(),
            onSelected: (_) {
              HapticFeedback.selectionClick();
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

  Widget _buildInsight() {
    final colors = context.colors;
    final balance = _ingresos - _egresos;
    final topCategoria = _totalesPorCategoria.entries.isEmpty
        ? null
        : (_totalesPorCategoria.entries.toList()
                ..sort((a, b) => b.value.compareTo(a.value)))
              .first;

    late final IconData icon;
    late final String titulo;
    late final String detalle;
    late final Color color;

    if (_ingresos == 0 && _egresos == 0) {
      icon = Icons.lightbulb_rounded;
      titulo = 'Mes listo para empezar';
      detalle = 'Agrega movimientos para generar insights automáticos.';
      color = colors.primary;
    } else if (balance >= 0) {
      icon = Icons.savings_rounded;
      titulo = 'Balance positivo';
      detalle = topCategoria == null
          ? 'Tus ingresos cubren tus gastos este mes.'
          : 'Tu mayor gasto fue ${topCategoria.key}.';
      color = colors.income;
    } else {
      icon = Icons.priority_high_rounded;
      titulo = 'Gastos por encima';
      detalle = topCategoria == null
          ? 'Revisa tus egresos para recuperar margen.'
          : '${topCategoria.key} concentra el gasto más alto.';
      color = colors.warning;
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
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
                  titulo,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  detalle,
                  style: TextStyle(
                    color: colors.textMuted,
                    fontSize: 12,
                    height: 1.25,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEstadoVacio() {
    final colors = context.colors;
    final hayFiltro = _filtroActivo != 'Todos';
    final labelMes = DateFormat('MMMM yyyy', 'es').format(_mesSeleccionado);
    final titulo = hayFiltro ? 'Sin resultados' : 'Sin movimientos';
    final mensaje = hayFiltro
        ? 'No hay movimientos para "$_filtroActivo" en $labelMes.'
        : 'Registra tu primer ingreso o gasto para ver el resumen de $labelMes.';

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
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                hayFiltro
                    ? Icons.filter_alt_off_rounded
                    : Icons.receipt_long_rounded,
                size: 52,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              titulo,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              mensaje,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.4,
                color: colors.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: hayFiltro
                  ? () {
                      setState(() => _filtroActivo = 'Todos');
                      _cargarDatos();
                    }
                  : () => _navegarAFormulario(),
              icon: Icon(hayFiltro ? Icons.clear_rounded : Icons.add_rounded),
              label: Text(hayFiltro ? 'Limpiar filtro' : 'Agregar movimiento'),
              style: FilledButton.styleFrom(
                backgroundColor: colors.primary,
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      child: _mostrarFabExtendido || _movimientos.isEmpty
          ? FloatingActionButton.extended(
              key: const ValueKey('extended-fab'),
              onPressed: _navegarAFormulario,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Movimiento'),
            )
          : FloatingActionButton(
              key: const ValueKey('compact-fab'),
              onPressed: _navegarAFormulario,
              shape: const CircleBorder(),
              child: const Icon(Icons.add_rounded, size: 30),
            ),
    );
  }
}

class _MonthSelector extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _MonthSelector({
    required this.label,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MonthButton(icon: Icons.chevron_left_rounded, onPressed: onPrevious),
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 96, maxWidth: 126),
            child: Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          _MonthButton(icon: Icons.chevron_right_rounded, onPressed: onNext),
        ],
      ),
    );
  }
}

class _MonthButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MonthButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 32,
      child: IconButton(
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
      ),
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
        style: TextStyle(
          color: context.colors.textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}
