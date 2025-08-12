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

  Future<void> cargarPendientes() async {
    try {
      loading = true; error = null; notifyListeners();
      pendientes = await _api.getSolicitudesNominaPendientes();
      // Aquí solo listamos; la restricción fuerte va en backend.
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
      await _api.resolverSolicitudNomina(
        uidSolicitante: s.solicitante!, // viene de auditoría
        solicitudId: s.id,
        resueltoPor: aprobador,
        accion: accion,
        razonEstado: razonEstado,
      );
      // quita la resuelta de la lista
      pendientes.removeWhere((x) => x.id == s.id && x.solicitante == s.solicitante);
      notifyListeners();
      return true;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return false;
    }
  }
}
