// lib/models/empleado_resumen.dart
class EmpleadoResumen {
  final String uid;
  final String nombre;
  final String rol; // empleado | cajero | admin

  EmpleadoResumen({required this.uid, required this.nombre, required this.rol});

  factory EmpleadoResumen.fromMap(Map<String, dynamic> m) => EmpleadoResumen(
    uid: m['uid'] ?? '',
    nombre: m['nombre'] ?? '',
    rol: m['rol'] ?? 'empleado',
  );
}

// lib/models/asistencia_dia.dart
class AsistenciaDia {
  final String fecha;               // 'YYYY-MM-DD'
  final List<String> presentes;
  final List<String> noAsistio;

  AsistenciaDia({
    required this.fecha,
    required this.presentes,
    required this.noAsistio,
  });

  factory AsistenciaDia.fromMap(Map<String, dynamic> m) => AsistenciaDia(
    fecha: m['fecha'] ?? '',
    presentes: List<String>.from(m['presentes'] ?? const []),
    noAsistio: List<String>.from(m['noasistio'] ?? const []),
  );
}
