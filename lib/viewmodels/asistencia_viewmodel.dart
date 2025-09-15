// lib/viewmodels/asistencia_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class AsistenciaViewModel extends ChangeNotifier {
  final _api = ApiService();

  DateTime selectedDay = DateTime.now();

  /// [{uid,nombre,rol}, ...]
  List<Map<String, dynamic>> empleados = [];

  /// Mapa de presencia por uid
  final Map<String, bool> presentes = {};

  bool loading = false;
  String? error;

  /// Día bloqueado por scheduler (penalizada == true)
  bool soloLectura = false;

  String get ymd => DateFormat('yyyy-MM-dd').format(selectedDay);

  /// Carga empleados + estado de asistencia del día seleccionado.
  Future<void> cargar() async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      // 1) Empleados activos
      empleados = await _api.getEmpleadosActivos();

      // Inicializa todos como ausentes
      presentes
        ..clear()
        ..addEntries(empleados.map((e) {
          final uid = (e['uid'] as String?) ?? '';
          return MapEntry(uid, false);
        }));

      // 2) Estado de asistencia del día
      final estado = await _api.getAsistenciaDia(ymd);

      if (estado == null) {
        // Si no existe, lo creamos (día editable por defecto)
        await _api.iniciarAsistencia(ymd);
        final creado = await _api.getAsistenciaDia(ymd);
        final pres = List<String>.from(creado?['presentes'] ?? []);
        for (final uid in pres) {
          if (presentes.containsKey(uid)) presentes[uid] = true;
        }
        soloLectura = (creado?['penalizada'] == true);
      } else {
        // Rellena presentes desde backend
        final pres = List<String>.from(estado['presentes'] ?? []);
        for (final uid in pres) {
          if (presentes.containsKey(uid)) presentes[uid] = true;
        }
        // 🔒 Día bloqueado si ya fue cerrado por el scheduler
        soloLectura = (estado['penalizada'] == true);
      }

      notifyListeners();
    } catch (e) {
      error = '$e';
      notifyListeners();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Cambia el día y recarga datos
  Future<void> cambiarDia(DateTime d) async {
    selectedDay = DateTime(d.year, d.month, d.day);
    await cargar();
  }

  /// Marca/desmarca presencia para un empleado.
  /// Si el día es de solo lectura, no hace nada.
  Future<void> toggle(String uid, bool value) async {
    if (soloLectura) return; // seguridad extra

    // Actualización optimista
    final prev = presentes[uid];
    presentes[uid] = value;
    notifyListeners();

    try {
      await _api.marcarAsistencia(uid: uid, fechaYMD: ymd, presente: value);
    } catch (e) {
      // Revierte si falla
      presentes[uid] = prev ?? false;
      error = '$e';
      notifyListeners();
    }
  }

  // ⚠️ Ya no se usa desde la vista, el cierre lo hace el scheduler.
  // Lo dejamos por si necesitas pruebas manuales.
  Future<bool> cerrarDia() async {
    try {
      await _api.cerrarAsistencia(ymd);
      // Después de cerrar, vuelve a cargar para reflejar soloLectura = true
      await cargar();
      return true;
    } catch (e) {
      error = '$e';
      notifyListeners();
      return false;
    }
  }
}
