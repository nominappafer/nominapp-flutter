// lib/viewmodels/historial_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/solicitud.dart';
import '../services/api_service.dart';

class HistorialViewModel extends ChangeNotifier {
  final _api = ApiService();
  List<Solicitud> solicitudes = [];
  bool loading = false;
  String? error;

  Future<void> cargarSolicitudesNomina() async {
    try {
      loading = true; error = null; notifyListeners();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      solicitudes = await _api.getSolicitudesNominaUsuario(uid);
    } catch (e) {
      error = '$e';
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<void> refresh() => cargarSolicitudesNomina();
}