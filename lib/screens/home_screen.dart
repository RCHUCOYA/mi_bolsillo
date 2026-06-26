import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/movimiento_model.dart';
import '../utils/categorias.dart';
import '../widgets/resumen_card.dart';
import '../widgets/movimiento_tile.dart';
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
      MaterialPageRoute(
        builder: (_) => FormScreen(movimiento: movimiento),
      ),
    );
    if (result == true) _cargarDatos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFF6C63FF),
              onRefresh: _cargarDatos,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        const SizedBox(height: 8),
                        ResumenCard(
                          ingresos: _ingresos,
                          egresos: _egresos,
                        ),
                        const SizedBox(height: 8),
                        _buildFiltros(),
                        const SizedBox(height: 4),
                      ],
                    ),
                  ),
                  if (_cargando)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF6C63FF),
                        ),
                      ),
                    )
                  else if (_movimientos.isEmpty)
                    SliverFillRemaining(
                      child: _buildEstadoVacio(),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          if (index == _movimientos.length) {
                            return const SizedBox(height: 100);
                          }
                          return MovimientoTile(
                            movimiento: _movimientos[index],
                            onChanged: _cargarDatos,
                          );
                        },
                        childCount: _movimientos.length + 1,
                      ),
                    ),
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
    final mesCapitalizado =
        mesAnio[0].toUpperCase() + mesAnio.substring(1);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'MiBolsillo',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  mesCapitalizado,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
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
      {'label': 'Todos', 'icono': null},
      {'label': 'Ingresos', 'icono': Icons.arrow_upward},
      {'label': 'Egresos', 'icono': Icons.arrow_downward},
      ...categorias.map((c) => {'label': c['nombre'], 'icono': c['icono']}),
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
          final icono = filtro['icono'] as IconData?;
          final activo = _filtroActivo == label;

          return GestureDetector(
            onTap: () {
              setState(() => _filtroActivo = label);
              _cargarDatos();
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: activo ? const Color(0xFF6C63FF) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: activo
                      ? const Color(0xFF6C63FF)
                      : const Color(0xFF6C63FF).withValues(alpha: 0.4),
                ),
                boxShadow: activo
                    ? [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        )
                      ]
                    : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icono != null) ...[
                    Icon(
                      icono,
                      size: 14,
                      color: activo ? Colors.white : const Color(0xFF6C63FF),
                    ),
                    const SizedBox(width: 5),
                  ],
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: activo ? Colors.white : const Color(0xFF6C63FF),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEstadoVacio() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No hay movimientos aún',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Presiona el botón + para agregar\ntu primer movimiento',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: _navegarAFormulario,
      child: Container(
        width: 58,
        height: 58,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.45),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
