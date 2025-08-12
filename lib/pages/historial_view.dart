// lib/pages/historial_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/historial_viewmodel.dart';
import '../models/solicitud.dart';

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HistorialViewModel>().cargarSolicitudesNomina());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HistorialViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Historial Solicitudes (Nómina)')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: vm.refresh,
        child: vm.solicitudes.isEmpty
            ? ListView(children: const [
          SizedBox(height: 120),
          Center(child: Text('No hay solicitudes de nómina')),
        ])
            : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: vm.solicitudes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final s = vm.solicitudes[i];
            return ListTile(
              onTap: () => Navigator.pushNamed(
                context, '/detalleSolicitud',
                arguments: s,
              ),
              tileColor: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Adelanto • \$${s.valor ?? '-'}'),
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
