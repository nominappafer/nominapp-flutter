// lib/viewmodels/crear_solicitud_descanso_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class CrearSolicitudDescansoViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final razonCtrl = TextEditingController();
  DateTime? fechaSeleccionada;
  String tipoOperacion = 'agregar'; // 'agregar' | 'remover'

  final _api = ApiService();
  bool loading = false;
  String? error;

  Future<bool> enviar() async {
    if (!formKey.currentState!.validate() || fechaSeleccionada == null) {
      error = 'Complete fecha y razón';
      notifyListeners();
      return false;
    }
    try {
      loading = true; error = null; notifyListeners();
      final uid = FirebaseAuth.instance.currentUser!.uid;

      await _api.crearSolicitudDescanso(
        uid: uid,
        tipoOperacion: tipoOperacion,
        fecha: fechaSeleccionada!,
        razon: razonCtrl.text.trim(),
      );

      loading = false; notifyListeners();
      return true;
    } catch (e) {
      error = '$e';
      loading = false; notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    razonCtrl.dispose();
    super.dispose();
  }
}