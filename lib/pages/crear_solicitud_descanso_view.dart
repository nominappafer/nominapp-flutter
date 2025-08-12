// lib/pages/crear_solicitud_descanso_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/crear_solicitud_descanso_viewmodel.dart';

class CrearSolicitudDescansoView extends StatelessWidget {
  const CrearSolicitudDescansoView({super.key});

  String _formatYMD(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<CrearSolicitudDescansoViewModel>();
    final DateTime? preselect =
    ModalRoute.of(context)!.settings.arguments as DateTime?;
    vm.fechaSeleccionada ??= preselect ?? DateTime.now();

    return Scaffold(
      appBar: AppBar(title: const Text('Crear solicitud descanso')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: vm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // selector acción
              DropdownButtonFormField<String>(
                value: vm.tipoOperacion,
                items: const [
                  DropdownMenuItem(
                      value: 'agregar',
                      child: Text('Agregar día de descanso')),
                  DropdownMenuItem(
                      value: 'remover',
                      child: Text('Remover día de descanso')),
                ],
                onChanged: (v) {
                  vm.tipoOperacion = v ?? 'agregar';
                  vm.notifyListeners();
                },
                decoration: const InputDecoration(labelText: 'Acción'),
              ),
              const SizedBox(height: 12),

              // fecha (formato YYYY-MM-DD)
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  hintText: vm.fechaSeleccionada == null
                      ? 'Selecciona fecha'
                      : _formatYMD(vm.fechaSeleccionada!),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: vm.fechaSeleccionada ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) {
                    vm.fechaSeleccionada = d;
                    vm.notifyListeners();
                  }
                },
                validator: (_) =>
                vm.fechaSeleccionada == null ? 'Seleccione una fecha' : null,
              ),
              const SizedBox(height: 12),

              // razón
              TextFormField(
                controller: vm.razonCtrl,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Motivo / Razón'),
                validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'Ingrese un motivo' : null,
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
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/historialDescanso');
                  }
                },
                child: vm.loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Enviar Solicitud'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}