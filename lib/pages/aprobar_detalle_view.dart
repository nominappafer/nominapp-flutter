// lib/pages/aprobar_detalle_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/aprobar_solicitudes_viewmodel.dart';
import '../models/solicitud.dart';

class AprobarDetalleView extends StatefulWidget {
  const AprobarDetalleView({super.key});
  @override
  State<AprobarDetalleView> createState() => _AprobarDetalleViewState();
}

class _AprobarDetalleViewState extends State<AprobarDetalleView> {
  final razonCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final Solicitud s = ModalRoute.of(context)!.settings.arguments as Solicitud;
    final vm = context.watch<AprobarSolicitudesViewModel>();

    final esNomina = (s.tipo == 'solicitudadelanto');

    return Scaffold(
      appBar: AppBar(title: Text(esNomina ? 'Detalle adelanto' : 'Detalle descanso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Empleado: ${s.nombreEmpleado ?? s.uidEmpleado ?? s.solicitante ?? '—'}'),
            const SizedBox(height: 8),
            if (esNomina) ...[
              Text('Monto: \$${s.valor ?? '-'}'),
              Text('Motivo: ${s.descripcion}'),
            ] else ...[
              Text('Fecha solicitada: ${s.fecha}'),
              Text('Motivo: ${s.descripcion}'),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: razonCtrl,
              decoration: const InputDecoration(
                labelText: 'Razón (aprobado/rechazado)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const Spacer(),
            if (vm.error != null)
              Text(vm.error!, style: const TextStyle(color: Colors.red)),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await vm.resolver(
                        s: s, accion: 'rechazar', razonEstado: razonCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      if (ok) Navigator.pop(context, true);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    child: const Text('Rechazar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final ok = await vm.resolver(
                        s: s, accion: 'aprobar', razonEstado: razonCtrl.text.trim(),
                      );
                      if (!mounted) return;
                      if (ok) Navigator.pop(context, true);
                    },
                    child: const Text('Aprobar'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
