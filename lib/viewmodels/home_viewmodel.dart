// lib/viewmodels/home_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nomina.dart';
import '../services/api_service.dart';

class HomeViewModel extends ChangeNotifier {
  final _api = ApiService();
  Nomina? nomina;
  bool loading = false;
  String? error;

  Future<void> cargarNominaActual() async {
    try {
      loading = true; error = null; notifyListeners();
      final uid = FirebaseAuth.instance.currentUser!.uid;
      nomina = await _api.getNominaActual(uid);
    } catch (e) {
      error = '$e';
    } finally {
      loading = false; notifyListeners();
    }
  }
}
