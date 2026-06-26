import 'package:flutter/material.dart';

const List<Map<String, dynamic>> categorias = [
  {'nombre': 'Comida',     'icono': Icons.fastfood,       'color': Color(0xFFFF6B6B)},
  {'nombre': 'Transporte', 'icono': Icons.directions_car, 'color': Color(0xFF4ECDC4)},
  {'nombre': 'Vivienda',   'icono': Icons.home,           'color': Color(0xFF45B7D1)},
  {'nombre': 'Salud',      'icono': Icons.favorite,       'color': Color(0xFF96CEB4)},
  {'nombre': 'Ocio',       'icono': Icons.sports_esports, 'color': Color(0xFFFFEAA7)},
  {'nombre': 'Ropa',       'icono': Icons.checkroom,      'color': Color(0xFFDDA0DD)},
  {'nombre': 'Educación',  'icono': Icons.school,         'color': Color(0xFF98D8C8)},
  {'nombre': 'Trabajo',    'icono': Icons.work,           'color': Color(0xFFB8B8FF)},
  {'nombre': 'Salario',    'icono': Icons.attach_money,   'color': Color(0xFF90EE90)},
  {'nombre': 'Otros',      'icono': Icons.more_horiz,     'color': Color(0xFFD3D3D3)},
];

IconData getCategoriaIcono(String nombre) {
  final cat = categorias.firstWhere(
    (c) => c['nombre'] == nombre,
    orElse: () => categorias.last,
  );
  return cat['icono'] as IconData;
}

Color getCategoriaColor(String nombre) {
  final cat = categorias.firstWhere(
    (c) => c['nombre'] == nombre,
    orElse: () => categorias.last,
  );
  return cat['color'] as Color;
}
