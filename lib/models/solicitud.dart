class Solicitud {
  final String id;
  final String tipo;        // fijo: 'solicitudadelanto' en este flujo
  final String estado;      // pendiente/aprobado/rechazado
  final String descripcion; // 'razon' en tu BD
  final num? valor;
  final String fecha;
  final String razonEstado; // por qué se aprobó/rechazó
  final String? resueltoPor;
  final String? solicitante;

  Solicitud({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.descripcion,
    required this.valor,
    required this.fecha,
    required this.razonEstado,
    this.resueltoPor,
    this.solicitante,
  });

  /// ↳ Mapeo para documentos de /empleados/{uid}/solicitudesNomina
  factory Solicitud.fromMapNomina(Map<String, dynamic> m) => Solicitud(
    id: m['id'] ?? '',
    tipo: 'solicitudadelanto',
    estado: m['estado'] ?? 'pendiente',
    descripcion: m['razon'] ?? '',
    valor: m['valor'],
    fecha: m['fechaSolicitud'] ?? '',
    razonEstado: m['razonEstado'] ?? '',
    resueltoPor: m['resueltoPor'],
    solicitante: m['creadoPor'], // si lo guardaste así
  );

  // Para /solicitudesNomina/pendientes desde auditoría_global (incluye `solicitante`)
  factory Solicitud.fromMapAuditoria(Map<String, dynamic> m) => Solicitud(
    id: m['solicitudId'] ?? m['id'] ?? '',
    tipo: m['tipo'] ?? 'solicitudadelanto',
    estado: m['estadoFinal'] ?? 'pendiente',
    descripcion: m['descripcion'] ?? m['razon'] ?? '',
    valor: m['valor'],
    fecha: m['fecha'] ?? '',
    razonEstado: m['razonEstado'] ?? '',
    resueltoPor: m['resueltoPor'],
    solicitante: m['solicitante'],
  );

  factory Solicitud.fromMapDescanso(Map<String, dynamic> m) => Solicitud(
    id: m['id'] ?? '',
    tipo: 'solicituddescanso',
    estado: m['estado'] ?? 'pendiente',
    descripcion: m['razon'] ?? m['descripcion'] ?? '',
    valor: null, // no aplica
    fecha: m['fechaSolicitud'] ?? m['fecha'] ?? '',
    razonEstado: m['razonEstado'] ?? '',
    resueltoPor: m['resueltoPor'],
    solicitante: m['creadoPor'],
  );
}