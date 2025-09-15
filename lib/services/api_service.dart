// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/nomina.dart';
import '../models/solicitud.dart';
import '../models/dia_descanso.dart';
import 'package:intl/intl.dart';

class ApiService {
  static const String base = 'https://usercreate-service-652884480519.europe-west1.run.app';

  Future<Nomina?> getNominaActual(String uid) async {
    final r = await http.get(Uri.parse('$base/api/empleados/$uid/nominaActual'));
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body)['nominaActual'];
      return Nomina.fromMap(data);
    }
    return null;
  }

  /// 🔹 SOLO solicitudes de NÓMINA del usuario (subcolección)
  Future<List<Solicitud>> getSolicitudesNominaUsuario(String uid) async {
    final r = await http.get(
      Uri.parse('$base/api/empleados/$uid/solicitudesNomina'),
    );

    if (r.statusCode == 200) {
      final list = jsonDecode(r.body);
      return (list as List)
          .map((e) => Solicitud.fromMapNomina(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }
  // ⬇️ NUEVO: crear solicitud de adelanto
  Future<Map<String, dynamic>> crearSolicitudNomina({
    required String uid,
    required num valor,
    required String razon,
    required String creadoPor,
  }) async {
    final url = Uri.parse('$base/api/empleados/$uid/solicitudesNomina');
    final r = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'valor': valor,
        'razon': razon,
        'creadoPor': creadoPor,
      }),
    );

    if (r.statusCode >= 200 && r.statusCode < 300) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    } else {
      throw Exception('Error ${r.statusCode}: ${r.body}');
    }
  }
  // ⬇️ obtiene TODAS las solicitudes de NÓMINA pendientes (para cajero/admin)
  Future<List<Solicitud>> getSolicitudesNominaPendientes() async {
    final r = await http.get(Uri.parse('$base/api/solicitudesNomina/pendientes'));
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      // ANTES: fromMapAuditoria
      // AHORA:
      return list
          .map((e) => Solicitud.fromMapPendienteNomina(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  // ⬇️ aprobar / rechazar (usa tu endpoint existente)
  Future<void> resolverSolicitudNomina({
    required String uidSolicitante,
    required String solicitudId,
    required String resueltoPor,
    required String accion, // 'aprobar' | 'rechazar'
    String? razonEstado,
  }) async {
    final url = Uri.parse(
      '$base/api/empleados/$uidSolicitante/solicitudesNomina/$solicitudId/resolver',
    );
    final r = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'accion': accion,
        'resueltoPor': resueltoPor,
        'razonEstado': razonEstado ?? 'Sin especificar',
      }),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }


  Future<List<DiaDescanso>> getDiasDescansoActivos(String uid) async {
    final r = await http.get(Uri.parse('$base/api/empleados/$uid/diasDescanso'));
    if (r.statusCode == 200) {
      final list = (jsonDecode(r.body)['diasDescansoActivos'] as List);
      return list.map((e) => DiaDescanso.fromMap(e['id'] ?? '', e as Map<String,dynamic>)).toList();
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  // Historial de solicitudes de descanso del empleado
  Future<List<Solicitud>> getSolicitudesDescansoUsuario(String uid) async {
    final r = await http.get(Uri.parse('$base/api/empleados/$uid/solicitudesDescanso'));
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list.map((e) => Solicitud.fromMapDescanso(e as Map<String, dynamic>)).toList();
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  // Crear solicitud de descanso
  // accion: "agregar" | "remover"
  Future<void> crearSolicitudDescanso({
    required String uid,
    required String tipoOperacion, // "agregar" | "remover"
    required DateTime fecha,       // se enviará como "YYYY-MM-DD"
    required String razon,
  }) async {
    final f = DateFormat('yyyy-MM-dd').format(fecha);

    final r = await http.post(
      Uri.parse('$base/api/empleados/$uid/solicitudesDescanso'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fecha': f,
        'tipoOperacion': tipoOperacion,
        'razon': razon,
        'creadoPor': uid,
      }),
    );

    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }
  // GET: estado del día (usa el GET sugerido)
  Future<Map<String, dynamic>?> getAsistenciaDia(String ymd) async {
    final r = await http.get(Uri.parse('$base/asistencia/$ymd'));
    if (r.statusCode == 200) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    } else if (r.statusCode == 404) {
      return null; // no existe aún
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  // POST: iniciar (si no existe)
  Future<void> iniciarAsistencia(String ymd) async {
    final r = await http.post(
      Uri.parse('$base/asistencia/iniciar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"fecha": ymd}),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  // POST: marcar presente/ausente para un uid en fecha
  Future<void> marcarAsistencia({
    required String uid,
    required String fechaYMD,
    required bool presente,
  }) async {
    final r = await http.post(
      Uri.parse('$base/asistencia/marcar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "uid": uid,
        "fecha": fechaYMD,
        "accion": presente ? "presente" : "ausente",
      }),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  // POST: cerrar el día (aplica penalización)
  Future<void> cerrarAsistencia(String ymd) async {
    final r = await http.post(
      Uri.parse('$base/asistencia/cerrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({"fecha": ymd}),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  // (opcional) GET lista empleados activos si aún no la tienes en otro servicio
  Future<List<Map<String, dynamic>>> getEmpleadosActivos() async {
    final r = await http.get(Uri.parse('$base/api/empleados'));
    if (r.statusCode == 200) {
      return (jsonDecode(r.body) as List).cast<Map<String, dynamic>>();
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }
  Future<Map<String, dynamic>> registrarEmpleado({
    required String nombre,
    required String email,
    required String cedula,
    required String rol,
    required num salarioBase,
    String? password,
    String? descansoInicio,     // YYYY-MM-DD (opcional)
    int? descansoCadaDias,      // opcional
    String? sector,
  }) async {
    final body = {
      'nombre': nombre,
      'email': email,
      'cedula': cedula,
      'rol': rol,
      'salarioBase': salarioBase,
      if (password != null && password.isNotEmpty) 'password': password,
      if (descansoInicio != null) 'descansoInicio': descansoInicio,
      if (descansoCadaDias != null) 'descansoCadaDias': descansoCadaDias,
      if (sector != null && sector.isNotEmpty) 'sector': sector, // <--- NUEVO

    };
    final r = await http.post(
      Uri.parse('$base/api/empleados'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (r.statusCode >= 200 && r.statusCode < 300) {
      return jsonDecode(r.body) as Map<String, dynamic>;
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }
  Future<List<Solicitud>> getSolicitudesDescansoPendientes() async {
    final r = await http.get(Uri.parse('$base/api/solicitudesDescanso/pendientes'));
    if (r.statusCode == 200) {
      final list = jsonDecode(r.body) as List;
      return list
          .map((e) => Solicitud.fromMapPendienteDescanso(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  Future<void> resolverSolicitudDescanso({
    required String uidSolicitante,
    required String solicitudId,
    required String resueltoPor,
    required String accion, // 'aprobar' | 'rechazar'
    String? razonEstado,
  }) async {
    final url = Uri.parse(
        '$base/api/empleados/$uidSolicitante/solicitudesDescanso/$solicitudId/resolver');
    final r = await http.patch(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'accion': accion,
        'resueltoPor': resueltoPor,
        'razonEstado': razonEstado ?? 'Sin especificar',
      }),
    );
    if (r.statusCode < 200 || r.statusCode >= 300) {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }

  Future<List<Map<String, dynamic>>> getNominasActuales() async {
    final r = await http.get(Uri.parse('$base/api/nominas/actuales'));
    if (r.statusCode == 200) {
      final data = jsonDecode(r.body) as Map<String, dynamic>;
      final list = (data['nominas'] as List).cast<Map<String, dynamic>>();
      return list;
    } else {
      throw Exception('HTTP ${r.statusCode}: ${r.body}');
    }
  }
}

