class Solicitud {
  final String id;

  /// 'solicitudadelanto' | 'solicituddescanso'
  final String tipo;

  /// 'pendiente' | 'aprobado' | 'rechazado'
  final String estado;

  /// Motivo/descripción ingresado al crear
  final String descripcion;

  /// Monto (solo aplica a adelantos/bonos de nómina)
  final num? valor;

  /// ISO-8601: fecha de creación o del evento relevante
  final String fecha;

  /// Razón del estado final (por qué se aprobó/rechazó)
  final String razonEstado;

  /// UID del aprobador (si ya fue resuelta)
  final String? resueltoPor;

  /// UID del solicitante (creador)
  final String? solicitante;

  /// UID del empleado dueño de la solicitud (cuando viene de collection_group)
  final String? uidEmpleado;

  /// Rol del solicitante (útil para filtrar en cajero/admin)
  final String? solicitanteRol;

  /// Nombre del empleado (si tu endpoint lo agrega)
  final String? nombreEmpleado;

  /// 'adelanto' | 'bono' (opcional). Si no viene, se infiere del signo de `valor`.
  final String? tipoOperacion;

  /// Título legible para UI (opcional). Si no viene, se calcula internamente.
  final String? titulo;

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
    this.uidEmpleado,
    this.solicitanteRol,
    this.nombreEmpleado,
    this.tipoOperacion,
    this.titulo,
  });

  // -----------------------------
  // Helpers opcionales para la UI
  // -----------------------------
  bool get isBono {
    if (tipoOperacion != null) return tipoOperacion == 'bono';
    if (valor == null) return false;
    return (valor ?? 0) < 0;
  }

  /// Si no viene `titulo`, lo deduce.
  String get tituloUI {
    if (titulo != null && titulo!.trim().isNotEmpty) return titulo!;
    if (tipo == 'solicitudadelanto') {
      return isBono ? 'Bono' : 'Adelanto';
    }
    if (tipo == 'solicituddescanso') return 'Día de descanso';
    return 'Solicitud';
  }

  // ----------------------------------------------------------
  // 1) Documentos en: /empleados/{uid}/solicitudesNomina/{id}
  // ----------------------------------------------------------
  factory Solicitud.fromMapNomina(Map<String, dynamic> m) {
    final num? v = m['valor'];
    final String? op = (m['tipoOperacion'] as String?);
    final String? nombre = m['nombreEmpleado'] as String?;
    // Si no viene tipoOperacion, lo inferimos por signo:
    final String? opFinal = op ?? ((v != null && v < 0) ? 'bono' : 'adelanto');

    return Solicitud(
      id: m['id'] ?? '',
      tipo: 'solicitudadelanto',
      estado: m['estado'] ?? 'pendiente',
      descripcion: m['razon'] ?? '',
      valor: v,
      fecha: m['fechaSolicitud'] ?? '',
      razonEstado: m['razonEstado'] ?? '',
      resueltoPor: m['resueltoPor'],
      solicitante: m['creadoPor'],
      solicitanteRol: m['solicitanteRol'],
      nombreEmpleado: nombre,
      tipoOperacion: opFinal,
      titulo: m['titulo'], // si el backend lo envía listo para UI
    );
  }

  // -----------------------------------------------------------------
  // 2) Registros en auditoría_global (si los usas en algún flujo)
  // -----------------------------------------------------------------
  factory Solicitud.fromMapAuditoria(Map<String, dynamic> m) {
    final num? v = m['valor'];
    final String? op = m['tipoOperacion'];
    final String? opFinal = op ?? ((v != null && v < 0) ? 'bono' : 'adelanto');

    return Solicitud(
      id: m['solicitudId'] ?? m['id'] ?? '',
      tipo: m['tipo'] ?? 'solicitudadelanto',
      estado: m['estadoFinal'] ?? 'pendiente',
      descripcion: m['descripcion'] ?? m['razon'] ?? '',
      valor: v,
      fecha: m['fecha'] ?? '',
      razonEstado: m['razonEstado'] ?? '',
      resueltoPor: m['resueltoPor'],
      solicitante: m['solicitante'],
      // normalmente auditoría no trae uidEmpleado/rol/nombre, pero por si acaso:
      uidEmpleado: m['uidEmpleado'],
      solicitanteRol: m['solicitanteRol'],
      nombreEmpleado: m['nombreEmpleado'],
      tipoOperacion: opFinal,
      titulo: m['titulo'],
    );
  }

  // ----------------------------------------------------------
  // 3) Documentos en: /empleados/{uid}/solicitudesDescanso/{id}
  // ----------------------------------------------------------
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
    nombreEmpleado: m['nombreEmpleado'],
    titulo: m['titulo'], // p.ej. "Día de descanso"
  );

  // ---------------------------------------------------------------------------------
  // 4) NUEVO: respuesta de /api/solicitudesNomina/pendientes (collection_group)
  //    {
  //      "solicitudId", "uidEmpleado", "valor", "razon", "estado",
  //      "creadoPor", "fechaSolicitud", "solicitanteRol", "nombreEmpleado",
  //      (opcional) "tipoOperacion", (opcional) "titulo"
  //    }
  // ---------------------------------------------------------------------------------
  factory Solicitud.fromMapPendienteNomina(Map<String, dynamic> m) {
    final num? v = m['valor'];
    final String? op = m['tipoOperacion'];
    final String? opFinal = op ?? ((v != null && v < 0) ? 'bono' : 'adelanto');

    return Solicitud(
      id: m['solicitudId'] ?? m['id'] ?? '',
      tipo: 'solicitudadelanto',
      estado: m['estado'] ?? 'pendiente',
      descripcion: m['razon'] ?? '',
      valor: v,
      fecha: m['fechaSolicitud'] ?? '',
      razonEstado: m['razonEstado'] ?? '',
      resueltoPor: m['resueltoPor'],
      solicitante: m['creadoPor'],
      uidEmpleado: m['uidEmpleado'],
      solicitanteRol: m['solicitanteRol'],
      nombreEmpleado: m['nombreEmpleado'],
      tipoOperacion: opFinal,
      titulo: m['titulo'],
    );
  }

  /// Pendientes de descanso (si agregas endpoint paralelo)
  factory Solicitud.fromMapPendienteDescanso(Map<String, dynamic> m) => Solicitud(
    id: m['solicitudId'] ?? m['id'] ?? '',
    tipo: 'solicituddescanso',
    estado: m['estado'] ?? 'pendiente',
    descripcion: m['razon'] ?? '',
    valor: null,
    fecha: m['fechaSolicitud'] ?? m['fecha'] ?? '',
    razonEstado: m['razonEstado'] ?? '',
    resueltoPor: m['resueltoPor'],
    solicitante: m['creadoPor'],
    uidEmpleado: m['uidEmpleado'],
    solicitanteRol: m['solicitanteRol'],
    nombreEmpleado: m['nombreEmpleado'],
    titulo: m['titulo'],
  );
}
