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
      return list.map((e) => Solicitud.fromMapAuditoria(e as Map<String, dynamic>)).toList();
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
}

