// lib/pages/aprobar_solicitudes_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/aprobar_solicitudes_viewmodel.dart';
import '../viewmodels/usuario_viewmodel.dart';
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
    Future.microtask(() {
      final rol = context.read<UsuarioViewModel>().obtenerRol() ?? 'empleado';
      context.read<AprobarSolicitudesViewModel>().cargarPendientes(rolActual: rol);
    });
  }

  Future<void> _onRefresh() async {
    final rol = context.read<UsuarioViewModel>().obtenerRol() ?? 'empleado';
    await context.read<AprobarSolicitudesViewModel>().cargarPendientes(rolActual: rol);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AprobarSolicitudesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Solicitudes pendientes')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _onRefresh,
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
            final Solicitud s = vm.pendientes[i];

            // nombre visible del empleado (fallbacks seguros)
            final quien = s.nombreEmpleado ?? s.uidEmpleado ?? s.solicitante ?? '—';

            // Título según tipo y operación (bono/adelanto)
            String titulo;
            if (s.tipo == 'solicitudadelanto') {
              final esBono = s.isBono; // del modelo (infiere por signo si no viene tipoOperacion)
              if (esBono) {
                final v = (s.valor ?? 0);
                final montoAbs = v is num ? v.abs() : v;
                titulo = 'Bono • +\$$montoAbs';
              } else {
                final v = (s.valor ?? 0);
                titulo = 'Adelanto • -\$$v';
              }
            } else {
              // descanso
              final desc = (s.descripcion.isNotEmpty ? s.descripcion : s.fecha);
              titulo = 'Descanso • $desc';
            }

            // Subtítulo con nombre y fecha
            final subtitulo = (s.tipo == 'solicitudadelanto')
                ? 'Empleado: $quien\nFecha: ${s.fecha}'
                : 'Empleado: $quien\n${s.fecha} • ${s.solicitanteRol ?? 'empleado'}';

            return ListTile(
              tileColor: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              title: Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(subtitulo),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(
                context,
                '/aprobarDetalle', // vista genérica que decide según s.tipo
                arguments: s,
              ),
            );
          },
        ),
      ),
    );
  }
}
