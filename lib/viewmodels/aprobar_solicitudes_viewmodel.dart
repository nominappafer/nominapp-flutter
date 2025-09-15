// lib/viewmodels/aprobar_solicitudes_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/solicitud.dart';
import '../services/api_service.dart';

class AprobarSolicitudesViewModel extends ChangeNotifier {
  final _api = ApiService();

  List<Solicitud> pendientes = [];
  bool loading = false;
  String? error;

  Future<void> cargarPendientes({required String rolActual}) async {
    try {
      loading = true; error = null; notifyListeners();

      final nomina = await _api.getSolicitudesNominaPendientes();
      final descanso = await _api.getSolicitudesDescansoPendientes();

      // Filtro para cajero: solo solicitudes de empleados (ambos tipos)
      List<Solicitud> mix = [...nomina, ...descanso];
      if (rolActual == 'cajero') {
        mix = mix.where((s) => (s.solicitanteRol ?? 'empleado') == 'empleado').toList();
      }

      // Orden opcional por fechaSolicitud desc (siempre que sea ISO)
      mix.sort((a, b) => (b.fecha).compareTo(a.fecha));

      pendientes = mix;
    } catch (e) {
      error = '$e';
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<bool> resolver({
    required Solicitud s,
    required String accion, // 'aprobar' | 'rechazar'
    String? razonEstado,
  }) async {
    try {
      final aprobador = FirebaseAuth.instance.currentUser!.uid;
      final uidSolicitante = s.uidEmpleado ?? s.solicitante;
      if (uidSolicitante == null || uidSolicitante.isEmpty) {
        throw Exception('No se pudo determinar el UID del solicitante');
      }

      if (s.tipo == 'solicitudadelanto') {
        await _api.resolverSolicitudNomina(
          uidSolicitante: uidSolicitante,
          solicitudId: s.id,
          resueltoPor: aprobador,
          accion: accion,
          razonEstado: razonEstado,
        );
      } else {
        await _api.resolverSolicitudDescanso(
          uidSolicitante: uidSolicitante,
          solicitudId: s.id,
          resueltoPor: aprobador,
          accion: accion,
          razonEstado: razonEstado,
        );
      }

      pendientes.removeWhere((x) =>
      x.id == s.id && (x.uidEmpleado ?? x.solicitante) == uidSolicitante);
      notifyListeners();
      return true;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return false;
    }
  }



/// Utilidad por si quieres refrescar después de resolver varias.
  Future<void> refrescar({required String rolActual}) => cargarPendientes(rolActual: rolActual);
}
