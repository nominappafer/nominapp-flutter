// lib/views/crear_solicitud_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/crear_solicitud_viewmodel.dart';

class CrearSolicitudView extends StatelessWidget {
  const CrearSolicitudView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CrearSolicitudViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear Solicitud')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: vm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: vm.nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre Solicitud'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: vm.valorCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Valor'),
                validator: (v) {
                  final n = num.tryParse((v ?? '').replaceAll(',', '.')) ?? -1;
                  if (n <= 0) return 'Ingrese un valor válido (> 0)';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: vm.descCtrl,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 4,
                validator: (v) => (v == null || v.trim().isEmpty)
                    ? 'Ingrese una descripción'
                    : null,
              ),
              const SizedBox(height: 20),

              if (vm.error != null)
                Text(vm.error!, style: const TextStyle(color: Colors.red)),

              ElevatedButton(
                onPressed: vm.loading
                    ? null
                    : () async {
                  final ok = await vm.enviar();
                  if (!context.mounted) return;
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Solicitud enviada')),
                    );
                    // cerrar y llevar a Historial
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/historial');
                  }
                },
                child: vm.loading
                    ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Enviar Solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
