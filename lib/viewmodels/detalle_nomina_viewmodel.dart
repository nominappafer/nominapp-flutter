// lib/viewmodels/detalle_nomina_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import '../models/nomina.dart';
import '../models/solicitud.dart';
import '../services/api_service.dart';

class DetalleNominaViewModel extends ChangeNotifier {
  final _api = ApiService();

  Nomina? nominaActual;

  // Fuente completa del mes activo (solicitudes del usuario en ese mes)
  List<Solicitud> _todas = [];

  // Lo que ve la UI tras aplicar búsqueda
  List<Solicitud> visibles = [];

  bool loading = false;
  String? error;

  // Query de búsqueda (por descripción)
  String query = '';

  // Mes actual a mostrar (lo derivamos de la nómina activa)
  DateTime currentMonth = DateTime(DateTime.now().year, DateTime.now().month);

  String get mesY => DateFormat('yyyy-MM').format(currentMonth);

  /// Carga nómina actual + solicitudes del usuario y deja _todas en el mes de la nómina
  Future<void> cargar(String uid) async {
    try {
      loading = true; error = null; notifyListeners();

      // 1) Nómina activa
      nominaActual = await _api.getNominaActual(uid);

      // Derivar el mes de la nómina activa
      // periodoActual puede ser "YYYY-MM" o "YYYY-MM-DD"
      final p = nominaActual?.periodoActual ?? '';
      if (p.length >= 7) {
        final parts = p.substring(0, 7).split('-'); // [YYYY, MM]
        final y = int.parse(parts[0]);
        final m = int.parse(parts[1]);
        currentMonth = DateTime(y, m);
      }

      // 2) Traer solicitudes (subcolección del usuario)
      final todas = await _api.getSolicitudesNominaUsuario(uid);

      // 3) Filtrar por mes actual (comparando prefijo YYYY-MM de la fecha ISO)
      final prefijoMes = mesY; // "YYYY-MM"
      _todas = todas.where((s) {
        final f = (s.fecha).trim();
        return f.startsWith(prefijoMes);
      }).toList()
        ..sort((a, b) => (b.fecha).compareTo(a.fecha)); // más recientes primero

      // 4) Aplicar filtro de búsqueda (si lo hay)
      _aplicarFiltro();
    } catch (e) {
      error = '$e';
      visibles = [];
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Cambiar el texto de búsqueda (solo por descripción)
  void setQuery(String q) {
    query = q;
    _aplicarFiltro();
  }

  /// Si en el futuro permites cambiar de mes desde la UI, llama esto y recarga.
  void cambiarMes(DateTime nuevoMes) {
    currentMonth = DateTime(nuevoMes.year, nuevoMes.month);
    _aplicarFiltro();
  }

  void _aplicarFiltro() {
    final q = query.trim().toLowerCase();
    final prefijoMes = mesY;

    // Por seguridad, re-asegura que solo estén las del mes visible
    Iterable<Solicitud> base = _todas.where((s) => s.fecha.startsWith(prefijoMes));

    if (q.isEmpty) {
      visibles = base.toList();
    } else {
      visibles = base.where((s) {
        final desc = (s.descripcion).toLowerCase();
        return desc.contains(q); // <— filtro SOLO por descripción
      }).toList();
    }
    notifyListeners();
  }

  /// Valor que se muestra al final de la card (tu UI espera decrementos)
  /// - Solo cuenta solicitudes APROBADAS con valor positivo (adelantos).
  /// - Ignora bonos (valor negativo) y no aprobadas.
  num montoDescuento(Solicitud s) {
    if (s.estado == 'aprobado' && s.valor != null) {
      final v = s.valor!;
      return v > 0 ? v : 0;
    }
    return 0;
  }
}
