// lib/pages/aprobar_detalle_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/solicitud.dart';
import '../viewmodels/aprobar_solicitudes_viewmodel.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Solicitud')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Valor: \$${s.valor ?? '-'}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          Text('Descripción: ${s.descripcion}'),
          const SizedBox(height: 8),
          Text('Solicitante: ${s.solicitante}'),
          const SizedBox(height: 16),
          TextField(
            controller: razonCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Razón (opcional)'),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: vm.loading ? null : () async {
                    final ok = await vm.resolver(s: s, accion: 'rechazar', razonEstado: razonCtrl.text.trim());
                    if (!mounted) return;
                    if (ok) { Navigator.pop(context); }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Rechazar'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: vm.loading ? null : () async {
                    final ok = await vm.resolver(s: s, accion: 'aprobar', razonEstado: razonCtrl.text.trim());
                    if (!mounted) return;
                    if (ok) { Navigator.pop(context); }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  child: const Text('Aprobar'),
                ),
              ),
            ],
          ),
        ]),
      ),
    );
  }
}
