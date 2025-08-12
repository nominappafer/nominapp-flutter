// lib/pages/historial_descanso_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/historial_descanso_viewmodel.dart';

class HistorialDescansoView extends StatefulWidget {
  const HistorialDescansoView({super.key});

  @override
  State<HistorialDescansoView> createState() => _HistorialDescansoViewState();
}

class _HistorialDescansoViewState extends State<HistorialDescansoView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HistorialDescansoViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistorialDescansoViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial días descanso')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: vm.refresh,
        child: vm.solicitudes.isEmpty
            ? ListView(children: const [
          SizedBox(height: 120),
          Center(child: Text('Sin solicitudes registradas')),
        ])
            : ListView.separated(
          itemCount: vm.solicitudes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final s = vm.solicitudes[i];
            return ListTile(
              tileColor: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('${s.descripcion.isEmpty ? 'Solicitud' : s.descripcion}'),
              subtitle: Text(s.fecha),
              trailing: Chip(
                label: Text(s.estado.toUpperCase()),
                backgroundColor: s.estado == 'aprobado'
                    ? Colors.green.shade200
                    : s.estado == 'rechazado'
                    ? Colors.red.shade200
                    : Colors.orange.shade200,
              ),
            );
          },
        ),
      ),
    );
  }
}
