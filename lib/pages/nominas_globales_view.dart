// lib/pages/nominas_globales_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/nominas_globales_viewmodel.dart';

class NominasGlobalesView extends StatefulWidget {
  const NominasGlobalesView({super.key});

  @override
  State<NominasGlobalesView> createState() => _NominasGlobalesViewState();
}

class _NominasGlobalesViewState extends State<NominasGlobalesView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<NominasGlobalesViewModel>().cargar());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NominasGlobalesViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Nómina actual • Todos')),
      body: vm.loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: vm.cargar,
        child: vm.nominas.isEmpty
            ? ListView(children: const [
          SizedBox(height: 120),
          Center(child: Text('No hay datos de nómina')),
        ])
            : ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: vm.nominas.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (_, i) {
            final e = vm.nominas[i];
            final nombre = e['nombre'] ?? '—';
            final valor  = e['valorActual'];
            final periodo = e['periodoActual'] ?? '';

            return ListTile(
              tileColor: Colors.deepPurple.shade50,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                nombre,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                periodo.isNotEmpty ? 'Periodo: $periodo' : 'Sin periodo',
              ),
              trailing: Text(
                valor == null ? '—' : '\$ $valor',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
