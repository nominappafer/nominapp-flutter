// lib/viewmodels/nominas_globales_viewmodel.dart
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class NominasGlobalesViewModel extends ChangeNotifier {
  final _api = ApiService();

  bool loading = false;
  String? error;
  List<Map<String, dynamic>> nominas = []; // {uid,nombre,valorActual,periodoActual}

  Future<void> cargar() async {
    try {
      loading = true; error = null; notifyListeners();
      nominas = await _api.getNominasActuales();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false; notifyListeners();
    }
  }
}
