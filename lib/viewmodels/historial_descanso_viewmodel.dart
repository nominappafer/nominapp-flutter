// lib/viewmodels/historial_descanso_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/solicitud.dart';
import '../services/api_service.dart';

class HistorialDescansoViewModel extends ChangeNotifier {
  final _api = ApiService();
  List<Solicitud> solicitudes = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    try {
      loading = true; error = null; notifyListeners();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      solicitudes = await _api.getSolicitudesDescansoUsuario(uid);
    } catch (e) {
      error = '$e';
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<void> refresh() => cargar();
}
