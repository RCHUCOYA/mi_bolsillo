import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../database/database_helper.dart';
import '../models/movimiento_model.dart';
import '../theme/app_theme.dart';
import '../utils/categorias.dart';
import '../widgets/categoria_chart.dart';
import '../widgets/dashboard_skeleton.dart';
import '../widgets/movimiento_tile.dart';
import '../widgets/resumen_card.dart';
import '../widgets/tendencia_chart.dart';
import 'form_screen.dart';

enum _Orden { fecha, monto, alfabetico }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseHelper _db = DatabaseHelper();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();

  List<Movimiento> _movimientos = [];
  Map<String, double> _totalesPorCategoria = {};
  double _ingresos = 0;
  double _egresos = 0;
  double _ingresosAnterior = 0;
  double _egresosAnterior = 0;
  List<Map<String, dynamic>> _tendenciaDatos = [];
  bool _cargando = true;
  bool _mostrarFabExtendido = true;

  String _filtroActivo = 'Todos';
  String _busqueda = '';
  bool _buscando = false;
  _Orden _orden = _Orden.fecha;
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
    _searchCtrl.dispose();
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

    final mesPrevio = DateTime(
      _mesSeleccionado.year,
      _mesSeleccionado.month - 1,
    );

    final results = await Future.wait([
      _db.getMovimientosFiltrados(
        tipo: tipoFiltro,
        categoria: categoriaFiltro,
        mes: _mesSeleccionado,
      ),
      _db.getTotalByTipo('ingreso', mes: _mesSeleccionado),
      _db.getTotalByTipo('egreso', mes: _mesSeleccionado),
      _db.getTotalesPorCategoria(mes: _mesSeleccionado, tipo: 'egreso'),
      _db.getTotalByTipo('ingreso', mes: mesPrevio),
      _db.getTotalByTipo('egreso', mes: mesPrevio),
      _db.getTotalesPorUltimosMeses(6),
    ]);

    var movimientos = results[0] as List<Movimiento>;

    // Aplicar orden
    switch (_orden) {
      case _Orden.monto:
        movimientos = [...movimientos]
          ..sort((a, b) => b.monto.compareTo(a.monto));
      case _Orden.alfabetico:
        movimientos = [...movimientos]
          ..sort((a, b) => a.titulo.compareTo(b.titulo));
      case _Orden.fecha:
        break;
    }

    if (mounted) {
      setState(() {
        _movimientos = movimientos;
        _ingresos = results[1] as double;
        _egresos = results[2] as double;
        _totalesPorCategoria = results[3] as Map<String, double>;
        _ingresosAnterior = results[4] as double;
        _egresosAnterior = results[5] as double;
        _tendenciaDatos = results[6] as List<Map<String, dynamic>>;
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

  // ── Búsqueda y filtrado en memoria ────────────────────────────────────────

  List<Movimiento> get _movimientosFiltrados {
    if (_busqueda.trim().isEmpty) return _movimientos;
    final q = _busqueda.trim().toLowerCase();
    return _movimientos.where((m) {
      return m.titulo.toLowerCase().contains(q) ||
          m.categoria.toLowerCase().contains(q) ||
          m.notas.toLowerCase().contains(q);
    }).toList();
  }

  void _toggleSearch() {
    HapticFeedback.selectionClick();
    setState(() {
      _buscando = !_buscando;
      if (!_buscando) {
        _busqueda = '';
        _searchCtrl.clear();
      }
    });
  }

  Future<void> _exportarCSV() async {
    if (_movimientos.isEmpty) return;
    HapticFeedback.selectionClick();

    final mesLabel = DateFormat('MMMM_yyyy', 'es').format(_mesSeleccionado);
    final rows = [
      'Titulo,Monto,Tipo,Categoria,Fecha,Notas',
      ..._movimientos.map((m) {
        final titulo = '"${m.titulo.replaceAll('"', '""')}"';
        final notas = '"${m.notas.replaceAll('"', '""')}"';
        return '$titulo,${m.monto},${m.tipo},${m.categoria},${m.fecha},$notas';
      }),
    ];

    await SharePlus.instance.share(
      ShareParams(
        text: rows.join('\n'),
        subject: 'MiBolsillo - $mesLabel',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          if (_buscando) _buildBarraBusqueda(),
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
                          ResumenCard(
                            ingresos: _ingresos,
                            egresos: _egresos,
                            ingresosAnterior: _ingresosAnterior,
                            egresosAnterior: _egresosAnterior,
                          ),
                          CategoriaChart(
                            totales: _totalesPorCategoria,
                            egresos: _egresos,
                          ),
                          TendenciaChart(datos: _tendenciaDatos),
                          _buildInsight(),
                          _buildFiltros(),
                          const SizedBox(height: 10),
                        ],
                      ],
                    ),
                  ),
                  if (_cargando)
                    const DashboardSkeleton()
                  else if (_movimientosFiltrados.isEmpty)
                    SliverToBoxAdapter(child: _buildEstadoVacio())
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
    final lista = _movimientosFiltrados;
    final movimientosLabel =
        lista.length == 1 ? '1 movimiento' : '${lista.length} movimientos';

    return Container(
      decoration: BoxDecoration(gradient: colors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fila 1: icono + título + selector de mes
              Row(
                children: [
                  const _AppLogo(),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'MiBolsillo',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _MonthSelector(
                    label: mesCapitalizado,
                    onPrevious: () => _cambiarMes(-1),
                    onNext: () => _cambiarMes(1),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Fila 2: contador + filtro activo + acciones
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
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
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
                  // Exportar CSV
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      Icons.ios_share_rounded,
                      color: Colors.white.withValues(
                        alpha: _movimientos.isEmpty ? 0.38 : 0.85,
                      ),
                      size: 19,
                    ),
                    onPressed: _movimientos.isEmpty ? null : _exportarCSV,
                  ),
                  // Búsqueda
                  IconButton(
                    padding: const EdgeInsets.all(4),
                    constraints: const BoxConstraints(
                      minWidth: 32,
                      minHeight: 32,
                    ),
                    icon: Icon(
                      _buscando
                          ? Icons.search_off_rounded
                          : Icons.search_rounded,
                      color: Colors.white.withValues(alpha: 0.85),
                      size: 19,
                    ),
                    onPressed: _toggleSearch,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBarraBusqueda() {
    final colors = context.colors;
    return Container(
      color: colors.background,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
      child: TextField(
        controller: _searchCtrl,
        autofocus: true,
        onChanged: (v) => setState(() => _busqueda = v),
        decoration: InputDecoration(
          hintText: 'Buscar por título, categoría...',
          prefixIcon: Icon(Icons.search_rounded, color: colors.primary),
          suffixIcon: _busqueda.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: colors.textMuted,
                  ),
                  onPressed: () {
                    _searchCtrl.clear();
                    setState(() => _busqueda = '');
                  },
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: BorderSide(color: colors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: BorderSide(color: colors.primary),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            borderSide: BorderSide(color: colors.border),
          ),
          filled: true,
          fillColor: colors.surface,
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
      child: Row(
        children: [
          Expanded(
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
                  avatar: Icon(
                    icono,
                    size: 16,
                    color: activo ? Colors.white : color,
                  ),
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
          ),
          // Botón de ordenamiento
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<_Orden>(
              tooltip: 'Ordenar',
              icon: Icon(
                Icons.sort_rounded,
                color: _orden != _Orden.fecha
                    ? colors.primary
                    : colors.textMuted,
                size: 22,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              onSelected: (value) {
                HapticFeedback.selectionClick();
                setState(() => _orden = value);
                _cargarDatos();
              },
              itemBuilder: (_) => [
                _ordenItem(_Orden.fecha, Icons.access_time_rounded,
                    'Más reciente', colors),
                _ordenItem(_Orden.monto, Icons.attach_money_rounded,
                    'Mayor monto', colors),
                _ordenItem(_Orden.alfabetico, Icons.sort_by_alpha_rounded,
                    'Alfabético', colors),
              ],
            ),
          ),
        ],
      ),
    );
  }

  PopupMenuItem<_Orden> _ordenItem(
    _Orden value,
    IconData icon,
    String label,
    AppPalette colors,
  ) {
    final selected = _orden == value;
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: selected ? colors.primary : colors.textMuted,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: selected ? colors.primary : colors.text,
              fontWeight: selected ? FontWeight.w800 : FontWeight.normal,
            ),
          ),
          if (selected) ...[
            const Spacer(),
            Icon(Icons.check_rounded, size: 16, color: colors.primary),
          ],
        ],
      ),
    );
  }

  Widget _buildMovimientosAgrupados() {
    final lista = _movimientosFiltrados;
    final items = <Widget>[];

    // Solo agrupar por fecha cuando el orden es cronológico y no hay búsqueda activa
    if (_orden == _Orden.fecha && _busqueda.isEmpty) {
      String? ultimoGrupo;
      for (final movimiento in lista) {
        final grupo = _grupoFecha(movimiento.fecha);
        if (grupo != ultimoGrupo) {
          items.add(_SeccionFecha(titulo: grupo));
          ultimoGrupo = grupo;
        }
        items.add(
          MovimientoTile(movimiento: movimiento, onChanged: _cargarDatos),
        );
      }
    } else {
      for (final movimiento in lista) {
        items.add(
          MovimientoTile(movimiento: movimiento, onChanged: _cargarDatos),
        );
      }
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
    final hayBusqueda = _busqueda.isNotEmpty;
    final labelMes = DateFormat('MMMM yyyy', 'es').format(_mesSeleccionado);

    final titulo = hayBusqueda
        ? 'Sin resultados'
        : hayFiltro
            ? 'Sin resultados'
            : 'Sin movimientos';
    final mensaje = hayBusqueda
        ? 'No hay movimientos para "$_busqueda" en $labelMes.'
        : hayFiltro
            ? 'No hay movimientos para "$_filtroActivo" en $labelMes.'
            : 'Registra tu primer ingreso o gasto para ver el resumen de $labelMes.';

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 18, 28, 112),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                hayBusqueda
                    ? Icons.search_off_rounded
                    : hayFiltro
                        ? Icons.filter_alt_off_rounded
                        : Icons.receipt_long_rounded,
                size: 42,
                color: colors.primary,
              ),
            ),
            const SizedBox(height: 18),
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
              onPressed: hayBusqueda
                  ? () {
                      _searchCtrl.clear();
                      setState(() => _busqueda = '');
                    }
                  : hayFiltro
                      ? () {
                          setState(() => _filtroActivo = 'Todos');
                          _cargarDatos();
                        }
                      : () => _navegarAFormulario(),
              icon: Icon(
                hayBusqueda || hayFiltro
                    ? Icons.clear_rounded
                    : Icons.add_rounded,
              ),
              label: Text(
                hayBusqueda
                    ? 'Limpiar búsqueda'
                    : hayFiltro
                        ? 'Limpiar filtro'
                        : 'Agregar movimiento',
              ),
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

// ── App Logo animado ─────────────────────────────────────────────────────
class _AppLogo extends StatefulWidget {
  const _AppLogo();

  @override
  State<_AppLogo> createState() => _AppLogoState();
}

class _AppLogoState extends State<_AppLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _runShimmer();
  }

  void _runShimmer() {
    _ctrl.forward(from: 0).then((_) {
      if (!mounted) return;
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _runShimmer();
      });
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) {
        // posición del barrido: entra por la izquierda, sale por la derecha
        final sweep = Alignment(_ctrl.value * 4 - 2, 0);
        return Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0x55FFFFFF), // 0.33 white
                Color(0x1AFFFFFF), // 0.10 white
              ],
            ),
            border: Border.all(
              color: const Color(0x66FFFFFF), // 0.40 white
              width: 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 14,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Color(0x1AFFFFFF),
                blurRadius: 4,
                offset: Offset(-2, -2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14.5),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Barrido de shimmer
                Positioned.fill(
                  child: Align(
                    alignment: sweep,
                    child: Container(
                      width: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.0),
                            Colors.white.withValues(alpha: 0.28),
                            Colors.white.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // Ícono principal
                child!,
              ],
            ),
          ),
        );
      },
      child: const Icon(
        Icons.account_balance_wallet_rounded,
        color: Colors.white,
        size: 27,
        shadows: [
          Shadow(
            color: Color(0x44000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
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
