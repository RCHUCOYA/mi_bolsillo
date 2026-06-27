import 'package:flutter/material.dart';

const List<Map<String, dynamic>> categorias = [
  {
    'nombre': 'Comida',
    'icono': Icons.restaurant_rounded,
    'color': Color(0xFFE85D75),
  },
  {
    'nombre': 'Transporte',
    'icono': Icons.directions_car_rounded,
    'color': Color(0xFF00A7A5),
  },
  {
    'nombre': 'Vivienda',
    'icono': Icons.home_rounded,
    'color': Color(0xFF2F80ED),
  },
  {
    'nombre': 'Salud',
    'icono': Icons.favorite_rounded,
    'color': Color(0xFF20A67A),
  },
  {
    'nombre': 'Ocio',
    'icono': Icons.sports_esports_rounded,
    'color': Color(0xFFE0A100),
  },
  {
    'nombre': 'Ropa',
    'icono': Icons.checkroom_rounded,
    'color': Color(0xFFB261D8),
  },
  {
    'nombre': 'Educación',
    'icono': Icons.school_rounded,
    'color': Color(0xFF0E9F6E),
  },
  {
    'nombre': 'Trabajo',
    'icono': Icons.work_rounded,
    'color': Color(0xFF6C63FF),
  },
  {
    'nombre': 'Salario',
    'icono': Icons.attach_money_rounded,
    'color': Color(0xFF169B62),
  },
  {
    'nombre': 'Otros',
    'icono': Icons.more_horiz_rounded,
    'color': Color(0xFF64748B),
  },
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
