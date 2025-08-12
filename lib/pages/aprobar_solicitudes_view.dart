// lib/pages/aprobar_solicitudes_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/aprobar_solicitudes_viewmodel.dart';
import '../models/solicitud.dart';

class AprobarSolicitudesView extends StatefulWidget {
  const AprobarSolicitudesView({super.key});

  @override
  State<AprobarSolicitudesView> createState() => _AprobarSolicitudesViewState();
}

class _AprobarSolicitudesViewState extends State<AprobarSolicitudesView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<AprobarSolicitudesViewModel>().cargarPendientes());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AprobarSolicitudesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes pendientes')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: vm.cargarPendientes,
        child: vm.pendientes.isEmpty
            ? ListView(children: const [
          SizedBox(height: 120),
          Center(child: Text('No hay solicitudes pendientes')),
        ])
            : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: vm.pendientes.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final s = vm.pendientes[i];
            return ListTile(
              tileColor: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text('Adelanto • \$${s.valor ?? '-'}'),
              subtitle: Text('Solicitante: ${s.solicitante}\n${s.fecha}'),
              onTap: () => Navigator.pushNamed(
                context, '/aprobarDetalle',
                arguments: s,
              ),
            );
          },
        ),
      ),
    );
  }
}
