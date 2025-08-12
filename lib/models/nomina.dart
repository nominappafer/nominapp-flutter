class Nomina {
  final num valorActual;
  final String periodoActual;
  final bool historico;

  Nomina({required this.valorActual, required this.periodoActual, required this.historico});

  factory Nomina.fromMap(Map<String, dynamic> m) => Nomina(
    valorActual: (m['valorActual'] ?? 0),
    periodoActual: (m['periodoActual'] ?? ''),
    historico: (m['historico'] ?? false),
  );
}