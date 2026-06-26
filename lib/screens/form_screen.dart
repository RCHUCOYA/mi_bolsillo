import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/movimiento_model.dart';
import '../database/database_helper.dart';
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
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF6C63FF),
              onPrimary: Colors.white,
              surface: Colors.white,
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
        const SnackBar(
          content: Text('Por favor selecciona una categoría'),
          backgroundColor: Color(0xFF6C63FF),
        ),
      );
      return;
    }

    setState(() => _guardando = true);

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
      backgroundColor: const Color(0xFFF4F6FF),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
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
                    const SizedBox(height: 28),
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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(width: 4),
              Text(
                _esEdicion ? 'Editar movimiento' : 'Nuevo movimiento',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTipo() {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tipo de movimiento',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _BotonTipo(
                    label: 'Ingreso',
                    icono: Icons.arrow_upward,
                    activo: _tipo == 'ingreso',
                    colorActivo: const Color(0xFF4CAF50),
                    onTap: () => setState(() => _tipo = 'ingreso'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _BotonTipo(
                    label: 'Egreso',
                    icono: Icons.arrow_downward,
                    activo: _tipo == 'egreso',
                    colorActivo: const Color(0xFFE53935),
                    onTap: () => setState(() => _tipo = 'egreso'),
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
        decoration: _inputDecoration('Ej: Almuerzo, Renta, Salario...'),
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
        decoration: _inputDecoration('0.00'),
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Categoría',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 5,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 0.75,
              ),
              itemCount: categorias.length,
              itemBuilder: (context, index) {
                final cat = categorias[index];
                final nombre = cat['nombre'] as String;
                final icono = cat['icono'] as IconData;
                final color = cat['color'] as Color;
                final seleccionada = _categoriaSeleccionada == nombre;

                return GestureDetector(
                  onTap: () =>
                      setState(() => _categoriaSeleccionada = nombre),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: seleccionada
                              ? color
                              : color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: seleccionada
                              ? Border.all(
                                  color: const Color(0xFF6C63FF), width: 2)
                              : null,
                          boxShadow: seleccionada
                              ? [
                                  BoxShadow(
                                    color: color.withValues(alpha: 0.5),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
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
                          fontSize: 9,
                          fontWeight: seleccionada
                              ? FontWeight.bold
                              : FontWeight.normal,
                          color: seleccionada
                              ? const Color(0xFF6C63FF)
                              : const Color(0xFF1A1A2E),
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
    return _CampoCard(
      titulo: 'Fecha',
      child: InkWell(
        onTap: _seleccionarFecha,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey.shade50,
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_today,
                  color: Color(0xFF6C63FF), size: 20),
              const SizedBox(width: 10),
              Text(
                DateFormat('dd/MM/yyyy').format(_fechaSeleccionada),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const Spacer(),
              const Icon(Icons.arrow_drop_down, color: Colors.grey),
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
        decoration: _inputDecoration('Agrega una descripción adicional...'),
        maxLines: 3,
        textCapitalization: TextCapitalization.sentences,
      ),
    );
  }

  Widget _buildBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6C63FF), Color(0xFF3D5AF1)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF6C63FF).withValues(alpha: 0.4),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _guardando ? null : _guardar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFF6C63FF), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Color(0xFFE53935)),
      ),
      filled: true,
      fillColor: Colors.grey.shade50,
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: activo ? colorActivo : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: activo ? colorActivo : Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: activo
              ? [
                  BoxShadow(
                    color: colorActivo.withValues(alpha: 0.35),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icono,
                color: activo ? Colors.white : Colors.grey.shade500,
                size: 18),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: activo ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
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
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A2E),
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
