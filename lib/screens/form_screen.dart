import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/movimiento_model.dart';
import '../database/database_helper.dart';
import '../theme/app_theme.dart';
import '../utils/categorias.dart';

class FormScreen extends StatefulWidget {
  final Movimiento? movimiento;

  const FormScreen({super.key, this.movimiento});

  @override
  State<FormScreen> createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _montoController = TextEditingController();
  final _notasController = TextEditingController();

  String _tipo = 'egreso';
  String? _categoriaSeleccionada;
  DateTime _fechaSeleccionada = DateTime.now();
  bool _guardando = false;

  bool get _esEdicion => widget.movimiento != null;

  List<Map<String, dynamic>> get _categoriasDisponibles {
    if (_tipo == 'ingreso') {
      return categorias
          .where((c) => ['Salario', 'Trabajo', 'Otros'].contains(c['nombre']))
          .toList();
    }
    return categorias.where((c) => !['Salario'].contains(c['nombre'])).toList();
  }

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final m = widget.movimiento!;
      _tituloController.text = m.titulo;
      _montoController.text = m.monto.toString();
      _notasController.text = m.notas;
      _tipo = m.tipo;
      _categoriaSeleccionada = m.categoria;
      try {
        _fechaSeleccionada = DateTime.parse(m.fecha);
      } catch (_) {
        _fechaSeleccionada = DateTime.now();
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _montoController.dispose();
    _notasController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        final colors = context.colors;
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: colors.primary,
              onPrimary: Colors.white,
              surface: colors.surface,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _fechaSeleccionada = picked);
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una categoría')),
      );
      return;
    }

    setState(() => _guardando = true);
    HapticFeedback.mediumImpact();

    final db = DatabaseHelper();
    final fechaStr = DateFormat('yyyy-MM-dd').format(_fechaSeleccionada);
    final monto = double.parse(_montoController.text.replaceAll(',', '.'));

    final nuevo = Movimiento(
      id: widget.movimiento?.id,
      titulo: _tituloController.text.trim(),
      monto: monto,
      categoria: _categoriaSeleccionada!,
      fecha: fechaStr,
      tipo: _tipo,
      notas: _notasController.text.trim(),
    );

    if (_esEdicion) {
      await db.updateMovimiento(nuevo);
    } else {
      await db.insertMovimiento(nuevo);
    }

    if (mounted) {
      setState(() => _guardando = false);
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildToggleTipo(),
                    const SizedBox(height: 16),
                    _buildCampoTitulo(),
                    const SizedBox(height: 16),
                    _buildCampoMonto(),
                    const SizedBox(height: 16),
                    _buildSelectorCategoria(),
                    const SizedBox(height: 16),
                    _buildSelectorFecha(),
                    const SizedBox(height: 16),
                    _buildCampoNotas(),
                    const SizedBox(height: 24),
                    _buildBotonGuardar(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final colors = context.colors;
    return Container(
      decoration: BoxDecoration(gradient: colors.primaryGradient),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 20, 18),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _esEdicion ? 'Editar movimiento' : 'Nuevo movimiento',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _esEdicion
                          ? 'Actualiza los detalles guardados'
                          : 'Registra una entrada clara y rapida',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.72),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTipo() {
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de movimiento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BotonTipo(
                    label: 'Ingreso',
                    icono: Icons.arrow_upward_rounded,
                    activo: _tipo == 'ingreso',
                    colorActivo: colors.income,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _tipo = 'ingreso';
                        if (!_categoriasDisponibles.any(
                          (c) => c['nombre'] == _categoriaSeleccionada,
                        )) {
                          _categoriaSeleccionada = null;
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BotonTipo(
                    label: 'Egreso',
                    icono: Icons.arrow_downward_rounded,
                    activo: _tipo == 'egreso',
                    colorActivo: colors.expense,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _tipo = 'egreso';
                        if (!_categoriasDisponibles.any(
                          (c) => c['nombre'] == _categoriaSeleccionada,
                        )) {
                          _categoriaSeleccionada = null;
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCampoTitulo() {
    return _CampoCard(
      titulo: 'Título',
      child: TextFormField(
        controller: _tituloController,
        decoration: _inputDecoration(
          'Ej: Almuerzo, renta, salario...',
          icono: Icons.edit_note_rounded,
        ),
        textCapitalization: TextCapitalization.sentences,
        validator: (v) =>
            (v == null || v.trim().isEmpty) ? 'El título es requerido' : null,
      ),
    );
  }

  Widget _buildCampoMonto() {
    return _CampoCard(
      titulo: 'Monto',
      child: TextFormField(
        controller: _montoController,
        decoration: _inputDecoration('0.00', icono: Icons.payments_rounded),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
        ],
        validator: (v) {
          if (v == null || v.trim().isEmpty) return 'El monto es requerido';
          final parsed = double.tryParse(v.replaceAll(',', '.'));
          if (parsed == null || parsed <= 0) {
            return 'Ingresa un monto válido mayor a 0';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSelectorCategoria() {
    final disponibles = _categoriasDisponibles;
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Categoría',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 10,
                crossAxisSpacing: 8,
                childAspectRatio: 0.78,
              ),
              itemCount: disponibles.length,
              itemBuilder: (context, index) {
                final cat = disponibles[index];
                final nombre = cat['nombre'] as String;
                final icono = cat['icono'] as IconData;
                final color = cat['color'] as Color;
                final seleccionada = _categoriaSeleccionada == nombre;

                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _categoriaSeleccionada = nombre);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: seleccionada
                              ? color
                              : color.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: seleccionada
                              ? Border.all(color: colors.primary, width: 2)
                              : null,
                          boxShadow: seleccionada
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Icon(
                          icono,
                          color: seleccionada ? Colors.white : color,
                          size: 20,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nombre,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: seleccionada
                              ? FontWeight.w800
                              : FontWeight.normal,
                          color: seleccionada ? colors.primary : colors.text,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorFecha() {
    final colors = context.colors;
    return _CampoCard(
      titulo: 'Fecha',
      child: InkWell(
        onTap: _seleccionarFecha,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: colors.border),
            borderRadius: BorderRadius.circular(AppRadius.md),
            color: colors.surfaceSoft,
          ),
          child: Row(
            children: [
              Icon(
                Icons.calendar_today_rounded,
                color: colors.primary,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                style: TextStyle(
                  fontSize: 15,
                  color: colors.text,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Icon(Icons.keyboard_arrow_down_rounded, color: colors.textMuted),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCampoNotas() {
    return _CampoCard(
      titulo: 'Notas (opcional)',
      child: TextFormField(
        controller: _notasController,
        decoration: _inputDecoration(
          'Agrega una descripción adicional...',
          icono: Icons.notes_rounded,
        ),
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildBotonGuardar() {
    final colors = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: colors.primaryGradient,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: context.softShadow(colors.primary),
        ),
        child: ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          child: _guardando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  _esEdicion ? 'Actualizar' : 'Guardar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, {IconData? icono}) {
    final colors = context.colors;
    return InputDecoration(
      hintText: hint,
      prefixIcon: icono == null ? null : Icon(icono, color: colors.primary),
    );
  }
}

class _BotonTipo extends StatelessWidget {
  final String label;
  final IconData icono;
  final bool activo;
  final Color colorActivo;
  final VoidCallback onTap;

  const _BotonTipo({
    required this.label,
    required this.icono,
    required this.activo,
    required this.colorActivo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: activo ? colorActivo : colors.surfaceSoft,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: activo ? colorActivo : colors.border),
          boxShadow: activo ? context.softShadow(colorActivo) : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icono,
              color: activo ? Colors.white : colors.textMuted,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: activo ? Colors.white : colors.textMuted,
                fontWeight: FontWeight.w800,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoCard extends StatelessWidget {
  final String titulo;
  final Widget child;

  const _CampoCard({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: colors.text,
              ),
            ),
            const SizedBox(height: 10),
            child,
          ],
        ),
      ),
    );
  }
}
