// lib/pages/detalle_nomina_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/detalle_nomina_viewmodel.dart';
import '../models/solicitud.dart';

class DetalleNominaView extends StatefulWidget {
  const DetalleNominaView({super.key});

  @override
  State<DetalleNominaView> createState() => _DetalleNominaViewState();
}

class _DetalleNominaViewState extends State<DetalleNominaView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<DetalleNominaViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DetalleNominaViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detalle nómina')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Valor actual
            Text(
              vm.nominaActual != null
                  ? '\$ ${vm.nominaActual!.valorActual}'
                  : '\$ ---',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold, color: Colors.deepPurple),
            ),
            const SizedBox(height: 16),

            // Barra de búsqueda
            TextField(
              controller: vm.searchCtrl,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.menu),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => vm.aplicarBusqueda(vm.searchCtrl.text),
                ),
                hintText: 'Buscar Solicitud',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
              ),
              onChanged: vm.aplicarBusqueda,
            ),
            const SizedBox(height: 12),

            // Lista
            Expanded(
              child: vm.solicitudesFiltradas.isEmpty
                  ? const Center(child: Text('Sin solicitudes este mes'))
                  : ListView.separated(
                itemCount: vm.solicitudesFiltradas.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (_, i) {
                  final s = vm.solicitudesFiltradas[i];
                  return _SolicitudItem(
                    solicitud: s,
                    descuento: vm.montoDescuento(s),
                    onTap: () => Navigator.pushNamed(
                        context, '/detalleSolicitud', arguments: s),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SolicitudItem extends StatelessWidget {
  final Solicitud solicitud;
  final num descuento;
  final VoidCallback onTap;
  const _SolicitudItem({
    required this.solicitud, required this.descuento, required this.onTap, super.key});

  @override
  Widget build(BuildContext context) {
    final colorEstado = solicitud.estado == 'aprobado'
        ? Colors.green.shade200
        : (solicitud.estado == 'rechazado'
        ? Colors.red.shade200
        : Colors.orange.shade200);

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: colorEstado,
              child: const Text('A', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Solicitud ${solicitud.id}',
                      maxLines: 1, overflow: TextOverflow.ellipsis),
                  Text(solicitud.fecha, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Text(
              descuento > 0 ? '\$ $descuento' : '—',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
