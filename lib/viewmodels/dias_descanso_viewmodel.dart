// lib/viewmodels/dias_descanso_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/dia_descanso.dart';
import '../services/api_service.dart';

class DiasDescansoViewModel extends ChangeNotifier {
  final _api = ApiService();
  List<DiaDescanso> activos = [];
  bool loading = false;
  String? error;

  Future<void> cargar() async {
    try {
      loading = true; error = null; notifyListeners();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      activos = await _api.getDiasDescansoActivos(uid);
    } catch (e) {
      error = '$e';
    } finally {
      loading = false; notifyListeners();
    }
  }

  bool esDescanso(DateTime day) {
    return activos.any((d) =>
    d.activo &&
        d.dia.year == day.year && d.dia.month == day.month && d.dia.day == day.day
    );
  }
}