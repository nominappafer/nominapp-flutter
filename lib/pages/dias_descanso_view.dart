// lib/pages/dias_descanso_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/dias_descanso_viewmodel.dart';
import '../viewmodels/usuario_viewmodel.dart';

class DiasDescansoView extends StatefulWidget {
  const DiasDescansoView({super.key});

  @override
  State<DiasDescansoView> createState() => _DiasDescansoViewState();
}

class _DiasDescansoViewState extends State<DiasDescansoView> {
  CalendarFormat format = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime? selectedDay;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final uvm = context.read<UsuarioViewModel>();
      context.read<DiasDescansoViewModel>().cargar(uvm);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DiasDescansoViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Días de descanso')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 8),
          TableCalendar(
            firstDay: DateTime(2020),
            lastDay: DateTime(2030),
            focusedDay: vm.focusedMonth,
            calendarFormat: format,
            onFormatChanged: (f) => setState(() => format = f),
            selectedDayPredicate: (day) =>
            selectedDay != null &&
                day.year == selectedDay!.year &&
                day.month == selectedDay!.month &&
                day.day == selectedDay!.day,
            onDaySelected: (sel, foc) => setState(() {
              selectedDay = sel;
              focusedDay = foc;
            }),
            onPageChanged: (newFocus) {
              vm.cambiarMes(newFocus);
            },
            eventLoader: vm.eventosDelDia,
            headerStyle: const HeaderStyle(formatButtonVisible: true, titleCentered: true),

            // === Estilos por día (predispuesto: azul, real: naranja) ===
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focused) {
                final color = vm.colorParaDia(day);
                if (color == null) return null; // usa el default

                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color, width: 1.2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color, // número del día con el color
                    ),
                  ),
                );
              },
              todayBuilder: (context, day, focused) {
                // “hoy” con borde más fuerte + capa del tipo si aplica
                final color = vm.colorParaDia(day);
                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (color ?? Colors.indigo).withOpacity(0.18),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color ?? Colors.indigo, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: color ?? Colors.indigo,
                    ),
                  ),
                );
              },
              selectedBuilder: (context, day, focused) {
                final color = vm.colorParaDia(day);
                return Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: (color ?? Colors.indigo).withOpacity(0.35),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: color ?? Colors.indigo, width: 1.6),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${day.day}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(
                      context,
                      '/crearSolicitudDescanso',
                      arguments: selectedDay ?? DateTime.now(),
                    ),
                    child: const Text('Crear solicitud días descanso'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/historialDescanso'),
                    child: const Text('Historial días descanso'),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
