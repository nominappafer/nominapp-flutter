import 'package:flutter/material.dart'; // <-- para Color / Colors
import '../models/dia_descanso.dart';
import '../services/api_service.dart';
import '../viewmodels/usuario_viewmodel.dart';

DateTime _ymd(DateTime d) => DateTime(d.year, d.month, d.day);

class DiasDescansoViewModel extends ChangeNotifier {
  final _api = ApiService();

  // Mes visible en el calendario
  DateTime focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);

  // Datos de negocio (del usuario)
  DateTime? descansoInicio;   // ej. 2025-01-03 (ASIGNADO MANUAL EN BD)
  int descansoCadaDias = 16;

  // Datos en memoria
  List<DiaDescanso> _reales = [];

  // Resultado para pintar
  Set<DateTime> predispuestosMes = {};
  Set<DateTime> realesMes = {};
  Set<DateTime> especialesMes = {}; // <-- NUEVO: morado (cada 365 días)

  bool loading = false;
  String? error;

  /// Carga inicial: trae días reales activos del usuario y
  /// toma descansoInicio / descansoCadaDias desde el UsuarioViewModel.
  /// Los días ESPECIALES (morados) se anclan a:
  ///  1) descansoInicio (si existe), o
  ///  2) la fecha del primer día real (activo) encontrado.
  Future<void> cargar(UsuarioViewModel uvm) async {
    try {
      loading = true;
      error = null;
      notifyListeners();

      final uid = uvm.obtenerUID();
      if (uid == null) {
        error = 'Usuario no autenticado';
        return;
      }

      // 1) Trae días reales (activos) desde tu API
      _reales = await _api.getDiasDescansoActivos(uid);

      // 2) Lee parámetros para predispuestos del propio usuario
      descansoInicio   = uvm.descansoInicioDate ?? DateTime.now();
      descansoCadaDias = uvm.descansoCadaDias ?? 16;

      // 3) Construye sets para el mes visible (incluye especiales)
      _recalcularMes();
    } catch (e) {
      error = '$e';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Cambia el mes visible y recalcula los sets con los datos en memoria.
  Future<void> cambiarMes(DateTime nuevoFocus) async {
    focusedMonth = DateTime(nuevoFocus.year, nuevoFocus.month);
    _recalcularMes();
    notifyListeners();
  }

  void _recalcularMes() {
    predispuestosMes = _generarPredispuestosMes();
    realesMes        = _filtrarRealesMes(_reales);
    especialesMes    = _generarEspecialesMes(); // <-- generado desde ancla 365d
  }

  Set<DateTime> _generarPredispuestosMes() {
    final set = <DateTime>{};
    if (descansoInicio == null || descansoCadaDias <= 0) return set;

    // Rango del mes visible
    final start = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final end   = DateTime(focusedMonth.year, focusedMonth.month + 1, 0); // último día del mes

    // Avanza desde descansoInicio en bloques de N días hasta cubrir el mes
    DateTime cursor = descansoInicio!;

    // Acerca cursor al mes visible (salto por bloques)
    if (cursor.isBefore(start)) {
      final diffDays = start.difference(cursor).inDays;
      final saltos = (diffDays ~/ descansoCadaDias);
      cursor = cursor.add(Duration(days: saltos * descansoCadaDias));
      if (cursor.isBefore(start)) {
        cursor = cursor.add(Duration(days: descansoCadaDias));
      }
    }

    while (!cursor.isAfter(end)) {
      set.add(_ymd(cursor));
      cursor = cursor.add(Duration(days: descansoCadaDias));
    }
    return set;
  }

  Set<DateTime> _filtrarRealesMes(List<DiaDescanso> reales) {
    final set = <DateTime>{};
    for (final d in reales) {
      if (!d.activo) continue;
      if (d.dia.year == focusedMonth.year && d.dia.month == focusedMonth.month) {
        set.add(_ymd(d.dia));
      }
    }
    return set;
  }

  /// Encuentra la ancla para especiales (365d):
  /// - Primero intenta `descansoInicio`
  /// - Si no hay, toma la fecha real más antigua (activa)
  DateTime? _anclaEspecial() {
    if (descansoInicio != null) return _ymd(descansoInicio!);
    DateTime? minReal;
    for (final d in _reales) {
      if (!d.activo) continue;
      minReal = (minReal == null) ? d.dia : (d.dia.isBefore(minReal!) ? d.dia : minReal);
    }
    return minReal == null ? null : _ymd(minReal);
  }

  // NUEVO: genera días especiales (cada 365 días desde la ancla) en el mes visible
  Set<DateTime> _generarEspecialesMes() {
    final set = <DateTime>{};
    final base = _anclaEspecial();
    if (base == null) return set;

    final start = DateTime(focusedMonth.year, focusedMonth.month, 1);
    final end   = DateTime(focusedMonth.year, focusedMonth.month + 1, 0);

    // Acercar cursor al inicio del mes con saltos de 365 días
    DateTime cursor = base;
    if (cursor.isBefore(start)) {
      final diff = start.difference(cursor).inDays;
      final saltos = diff ~/ 365;
      cursor = cursor.add(Duration(days: saltos * 365));
      if (cursor.isBefore(start)) {
        cursor = cursor.add(const Duration(days: 365));
      }
    }

    while (!cursor.isAfter(end)) {
      set.add(_ymd(cursor));
      cursor = cursor.add(const Duration(days: 365));
    }
    return set;
  }

  // Para TableCalendar: 1 "evento" si hay predispuesto/real/especial
  List<String> eventosDelDia(DateTime day) {
    final y = _ymd(day);
    final hasPred = predispuestosMes.contains(y);
    final hasReal = realesMes.contains(y);
    final hasEsp  = especialesMes.contains(y);

    if (hasPred && hasReal && hasEsp) return const ['pred+real+esp'];
    if (hasReal && hasEsp) return const ['real+esp'];
    if (hasPred && hasEsp) return const ['pred+esp'];
    if (hasPred && hasReal) return const ['pred+real'];
    if (hasEsp)  return const ['esp'];
    if (hasPred) return const ['pred'];
    if (hasReal) return const ['real'];
    return const [];
  }

  // Color según prioridad: reales (naranja) > especiales (morado) > predispuestos (azul)
  Color? colorParaDia(DateTime day) {
    final y = _ymd(day);
    if (realesMes.contains(y))       return Colors.orange; // reales: naranja
    if (especialesMes.contains(y))   return Colors.purple; // especiales: morado
    if (predispuestosMes.contains(y)) return Colors.blue;  // predispuestos: azul
    return null;
  }
}
