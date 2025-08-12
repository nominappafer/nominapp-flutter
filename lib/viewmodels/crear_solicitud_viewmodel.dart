// lib/viewmodels/crear_solicitud_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/api_service.dart';

class CrearSolicitudViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController(); // opcional, solo UI
  final valorCtrl  = TextEditingController();
  final descCtrl   = TextEditingController();

  final _api = ApiService();
  bool loading = false;
  String? error;

  Future<bool> enviar() async {
    if (!formKey.currentState!.validate()) return false;

    try {
      loading = true; error = null; notifyListeners();

      final uid = FirebaseAuth.instance.currentUser!.uid;
      final valor = num.tryParse(valorCtrl.text.replaceAll(',', '.')) ?? -1;
      if (valor <= 0) {
        error = 'El valor debe ser mayor a 0';
        loading = false; notifyListeners();
        return false;
      }

      await _api.crearSolicitudNomina(
        uid: uid,
        valor: valor,
        razon: descCtrl.text.trim(),
        creadoPor: uid,
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
    nombreCtrl.dispose();
    valorCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }
}
