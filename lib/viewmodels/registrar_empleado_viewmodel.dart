// lib/viewmodels/registrar_empleado_viewmodel.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class RegistrarEmpleadoViewModel extends ChangeNotifier {
  final formKey = GlobalKey<FormState>();
  final nombreCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final cedulaCtrl = TextEditingController();
  final salarioCtrl = TextEditingController();
  final passwordCtrl = TextEditingController(); // opcional
  final descansoInicioCtrl = TextEditingController();
  final descansoCadaCtrl = TextEditingController(text: '16');
  String rol = 'empleado';
  String sector = 'admistrativo';

  final _api = ApiService();
  bool loading = false;
  String? error;
  String? creadoUid;

  DateTime? descansoSeleccionado; // para datepicker


  Future<bool> enviar() async {
    if (!formKey.currentState!.validate()) return false;
    try {
      loading = true;
      error = null;
      creadoUid = null;
      notifyListeners();

      final salario =
          num.tryParse(salarioCtrl.text.replaceAll(',', '.')) ?? -1;
      if (salario <= 0) {
        error = 'Salario base inválido';
        loading = false;
        notifyListeners();
        return false;
      }
      final descansoCada = int.tryParse(descansoCadaCtrl.text.trim()) ?? 16;
      if (descansoCada <= 0) {
        error = 'Descanso cada N días debe ser > 0';
        loading = false;
        notifyListeners();
        return false;
      }
      final descansoInicio = (descansoSeleccionado != null)
          ? '${descansoSeleccionado!.year.toString().padLeft(4, '0')}-'
              '${descansoSeleccionado!.month.toString().padLeft(2, '0')}-'
              '${descansoSeleccionado!.day.toString().padLeft(2, '0')}'
          : null; // si lo dejas null, el backend pondrá default (hoy)

      final resp = await _api.registrarEmpleado(
        nombre: nombreCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        cedula: cedulaCtrl.text.trim(),
        rol: rol,
        salarioBase: salario,
        password: passwordCtrl.text.trim().isEmpty
            ? null
            : passwordCtrl.text.trim(),
        descansoInicio: descansoInicio, // <-- nuevo
        descansoCadaDias: descansoCada,
        sector: sector.trim().isEmpty ? null : sector.trim(), // <-- nuevo
      );

      creadoUid = resp['uid'] as String?;
      loading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = '$e';
      loading = false;
      notifyListeners();
      return false;
    }
  }

  @override
  void dispose() {
    nombreCtrl.dispose();
    emailCtrl.dispose();
    cedulaCtrl.dispose();
    salarioCtrl.dispose();
    passwordCtrl.dispose();
    descansoInicioCtrl.dispose();
    descansoCadaCtrl.dispose();
    super.dispose();
  }
}
