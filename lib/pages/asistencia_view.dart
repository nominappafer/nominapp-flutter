// lib/pages/asistencia_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/asistencia_viewmodel.dart';

class AsistenciaView extends StatefulWidget {
  const AsistenciaView({super.key});

  @override
  State<AsistenciaView> createState() => _AsistenciaViewState();
}

class _AsistenciaViewState extends State<AsistenciaView> {
  CalendarFormat _format = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AsistenciaViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AsistenciaViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Asistencia'),
        // 🔹 Se elimina el botón de "Cerrar día" (lo hace el scheduler)
      ),
      body: vm.loading && vm.empleados.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 8),
          // Calendario para seleccionar día
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: TableCalendar(
              firstDay: DateTime(2020),
              lastDay: DateTime(2030),
              focusedDay: vm.selectedDay,
              calendarFormat: _format,
              onFormatChanged: (f) => setState(() => _format = f),
              selectedDayPredicate: (day) =>
              day.year == vm.selectedDay.year &&
                  day.month == vm.selectedDay.month &&
                  day.day == vm.selectedDay.day,
              onDaySelected: (sel, foc) => vm.cambiarDia(sel),
              headerStyle: const HeaderStyle(titleCentered: true),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'Fecha: ${vm.ymd}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          // 🔒 Aviso visual si el día está bloqueado (cerrado por scheduler)
          if (vm.soloLectura)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: MaterialBanner(
                backgroundColor: Colors.amber.shade100,
                content: const Text(
                  'Este día está cerrado por el sistema. Solo lectura.',
                ),
                leading: const Icon(Icons.lock),
                actions: const [SizedBox.shrink()],
              ),
            ),

          if (vm.error != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
            ),

          // Lista de empleados con checkbox
          Expanded(
            child: RefreshIndicator(
              onRefresh: vm.cargar,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: vm.empleados.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, i) {
                  final e = vm.empleados[i];
                  final uid = (e['uid'] as String?) ?? '';
                  final nombre = (e['nombre'] as String?) ?? '—';
                  final rol = (e['rol'] as String?) ?? 'empleado';
                  final checked = vm.presentes[uid] ?? false;

                  return CheckboxListTile(
                    value: checked,
                    // 🔒 Si es solo lectura, no permitimos cambiar
                    onChanged: vm.soloLectura
                        ? null
                        : (v) {
                      if (uid.isEmpty) return;
                      vm.toggle(uid, v ?? false);
                    },
                    title: Text(nombre),
                    subtitle: Text(rol),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    // Icono de candado al final si está bloqueado
                    secondary: vm.soloLectura
                        ? const Icon(Icons.lock_outline, size: 20)
                        : null,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
