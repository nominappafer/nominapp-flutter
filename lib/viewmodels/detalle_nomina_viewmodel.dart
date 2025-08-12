// lib/viewmodels/detalle_nomina_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/nomina.dart';
import '../models/solicitud.dart';
import '../services/api_service.dart';

class DetalleNominaViewModel extends ChangeNotifier {
  final _api = ApiService();

  Nomina? nominaActual;
  List<Solicitud> _solicitudesMes = [];
  List<Solicitud> solicitudesFiltradas = [];
  bool loading = false;
  String? error;

  final searchCtrl = TextEditingController();

  String get periodoYYYYMM {
    // nomina.periodoActual puede ser "2025-01-01" o "2025-01"
    final p = nominaActual?.periodoActual ?? '';
    // toma YYYY-MM
    return p.length >= 7 ? p.substring(0, 7) : '';
  }

  Future<void> cargar() async {
    try {
      loading = true; error = null; notifyListeners();

      final uid = FirebaseAuth.instance.currentUser!.uid;

      // 1) nómina actual
      nominaActual = await _api.getNominaActual(uid);

      // 2) solicitudes del usuario (todas) y filtramos por mes de la nómina
      final todas = await _api.getSolicitudesNominaUsuario(uid);
      final target = periodoYYYYMM;

      _solicitudesMes = todas.where((s) {
        final f = s.fecha; // ISO string "2025-08-11T..." ó "2025-08-11"
        if (f.isEmpty || target.isEmpty) return false;
        return f.startsWith(target); // coincide YYYY-MM
      }).toList()
        ..sort((a, b) => (b.fecha).compareTo(a.fecha)); // recientes primero

      // arranque sin filtro
      solicitudesFiltradas = List.of(_solicitudesMes);
    } catch (e) {
      error = '$e';
    } finally {
      loading = false; notifyListeners();
    }
  }

  void aplicarBusqueda(String q) {
    final query = q.trim().toLowerCase();
    if (query.isEmpty) {
      solicitudesFiltradas = List.of(_solicitudesMes);
    } else {
      solicitudesFiltradas = _solicitudesMes.where((s) {
        final id = (s.id).toLowerCase();
        final desc = (s.descripcion).toLowerCase();
        return id.contains(query) || desc.contains(query);
      }).toList();
    }
    notifyListeners();
  }

  num montoDescuento(Solicitud s) {
    // Si la solicitud está aprobada y pertenece a este mes → descuentó "valor".
    if ((s.estado == 'aprobado') && (s.valor != null)) return s.valor!;
    return 0;
  }

  @override
  void dispose() {
    searchCtrl.dispose();
    super.dispose();
  }
}
