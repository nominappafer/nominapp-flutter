// lib/models/dia_descanso.dart
class DiaDescanso {
  final String id;
  final DateTime dia;   // fecha asignada
  final bool activo;

  DiaDescanso({required this.id, required this.dia, required this.activo});

  factory DiaDescanso.fromMap(String id, Map<String, dynamic> m) => DiaDescanso(
    id: id,
    dia: DateTime.tryParse(m['dia'] ?? m['fecha'] ?? '') ?? DateTime(2000,1,1),
    activo: m['activo'] ?? true,
  );
}
