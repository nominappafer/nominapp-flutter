// lib/views/detalle_solicitud_view.dart
import 'package:flutter/material.dart';
import '../models/solicitud.dart';

class DetalleSolicitudView extends StatelessWidget {
  const DetalleSolicitudView({super.key});

  @override
  Widget build(BuildContext context) {
    final Solicitud s = ModalRoute.of(context)!.settings.arguments as Solicitud;

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle Solicitud')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          TextField(
            readOnly: true,
            decoration: InputDecoration(labelText: 'Nombre Solicitud', hintText: s.tipo == 'solicitudadelanto' ? 'Adelanto' : 'Descanso'),
          ),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            decoration: InputDecoration(labelText: 'Valor', hintText: s.valor?.toString() ?? '-'),
          ),
          const SizedBox(height: 12),
          TextField(
            readOnly: true,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Descripción', hintText: s.descripcion),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: s.estado == 'aprobado' ? Colors.green : (s.estado == 'rechazado' ? Colors.red : Colors.orange),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(s.estado.toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 16),
          TextField(
            readOnly: true,
            maxLines: 3,
            decoration: InputDecoration(labelText: 'Razón (opcional)', hintText: s.razonEstado.isEmpty ? '-' : s.razonEstado),
          ),
        ]),
      ),
    );
  }
}
