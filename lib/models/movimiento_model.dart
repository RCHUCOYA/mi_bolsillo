class Movimiento {
  final int? id;
  final String titulo;
  final double monto;
  final String categoria;
  final String fecha;
  final String tipo;
  final String notas;

  Movimiento({
    this.id,
    required this.titulo,
    required this.monto,
    required this.categoria,
    required this.fecha,
    required this.tipo,
    this.notas = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'monto': monto,
      'categoria': categoria,
      'fecha': fecha,
      'tipo': tipo,
      'notas': notas,
    };
  }

  factory Movimiento.fromMap(Map<String, dynamic> map) {
    return Movimiento(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      monto: (map['monto'] as num).toDouble(),
      categoria: map['categoria'] as String,
      fecha: map['fecha'] as String,
      tipo: map['tipo'] as String,
      notas: map['notas'] as String? ?? '',
    );
  }

  Movimiento copyWith({
    int? id,
    String? titulo,
    double? monto,
    String? categoria,
    String? fecha,
    String? tipo,
    String? notas,
  }) {
    return Movimiento(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      monto: monto ?? this.monto,
      categoria: categoria ?? this.categoria,
      fecha: fecha ?? this.fecha,
      tipo: tipo ?? this.tipo,
      notas: notas ?? this.notas,
    );
  }
}
