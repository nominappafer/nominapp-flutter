// lib/pages/dias_descanso_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../viewmodels/dias_descanso_viewmodel.dart';

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
    Future.microtask(() => context.read<DiasDescansoViewModel>().cargar());
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
            focusedDay: focusedDay,
            calendarFormat: format,
            onFormatChanged: (f) => setState(() => format = f),
            selectedDayPredicate: (day) => isSameDay(selectedDay, day),
            onDaySelected: (sel, foc) => setState(() { selectedDay = sel; focusedDay = foc; }),
            calendarStyle: CalendarStyle(
              // pinta los días de descanso
              defaultDecoration: const BoxDecoration(),
              todayDecoration: BoxDecoration(
                  color: Colors.indigo.shade100, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(
                  color: Colors.indigo, shape: BoxShape.circle),
              // marca descansos con un puntito
              markerDecoration: BoxDecoration(
                  color: Colors.deepPurple, shape: BoxShape.circle),
            ),
            eventLoader: (day) => vm.esDescanso(day) ? ['descanso'] : [],
            headerStyle: const HeaderStyle(formatButtonVisible: true, titleCentered: true),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pushNamed(context, '/crearSolicitudDescanso',
                        arguments: selectedDay ?? DateTime.now()),
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
