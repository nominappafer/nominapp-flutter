// lib/pages/registrar_empleado_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/registrar_empleado_viewmodel.dart';

class RegistrarEmpleadoView extends StatelessWidget {
  const RegistrarEmpleadoView({super.key});

  String _formatYMD(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<RegistrarEmpleadoViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Registrar empleado')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: vm.formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: vm.nombreCtrl,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: vm.emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || !v.contains('@')) ? 'Email inválido' : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: vm.cedulaCtrl,
                decoration: const InputDecoration(labelText: 'Cédula'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: vm.rol,
                decoration: const InputDecoration(labelText: 'Rol'),
                items: const [
                  DropdownMenuItem(value: 'empleado', child: Text('Empleado')),
                  DropdownMenuItem(value: 'cajero', child: Text('Cajero')),
                  DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                ],
                onChanged: (v) {
                  vm.rol = v ?? 'empleado';
                  vm.notifyListeners();
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: vm.salarioCtrl,
                decoration: const InputDecoration(labelText: 'Salario base'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = num.tryParse((v ?? '').replaceAll(',', '.')) ?? -1;
                  return n <= 0 ? 'Salario inválido' : null;
                },
              ),
              const SizedBox(height: 12),

              // ------------ NUEVOS CAMPOS ------------
              // Descanso inicio (date picker)
              TextFormField(
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Descanso inicio (YYYY-MM-DD)',
                  hintText: vm.descansoSeleccionado == null
                      ? 'Hoy (por defecto)'
                      : _formatYMD(vm.descansoSeleccionado!),
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: vm.descansoSeleccionado ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2035),
                  );
                  if (d != null) {
                    vm.descansoSeleccionado = d;
                    vm.notifyListeners();
                  }
                },
              ),
              const SizedBox(height: 12),

              // Cada N días
              TextFormField(
                controller: vm.descansoCadaCtrl, // default '16'
                decoration: const InputDecoration(labelText: 'Descanso cada N días'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim()) ?? 0;
                  return n <= 0 ? 'Debe ser entero > 0' : null;
                },
              ),
              const SizedBox(height: 12),
              // ------------ FIN NUEVOS CAMPOS ------------

              TextFormField(
                controller: vm.passwordCtrl,
                decoration:
                const InputDecoration(labelText: 'Contraseña inicial (opcional)'),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: vm.sector,
                decoration: const InputDecoration(labelText: 'Sector'),
                items: const [
                  DropdownMenuItem(
                    value: 'admistrativo',
                    child: Text('Admistrativo'),
                  ),
                  DropdownMenuItem(
                    value: 'greco',
                    child: Text('Greco'),
                  ),
                  DropdownMenuItem(
                    value: 'cocina',
                    child: Text('Cocina'),
                  ),
                  DropdownMenuItem(
                    value: 'pizzeria',
                    child: Text('Pizzería'),
                  ),
                  DropdownMenuItem(
                    value: 'pasteleria',
                    child: Text('Pastelería'),
                  ),
                  DropdownMenuItem(
                    value: 'pan',
                    child: Text('Pan'),
                  ),
                ],
                onChanged: (value) {
                  if (value == null) return;
                  vm.sector = value;
                  vm.notifyListeners();
                },
                validator: (value) =>
                    (value == null || value.isEmpty) ? 'Requerido' : null,
              ),
              if (vm.error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(vm.error!, style: const TextStyle(color: Colors.red)),
                ),

              ElevatedButton(
                onPressed: vm.loading
                    ? null
                    : () async {
                  final ok = await vm.enviar();
                  if (!context.mounted) return;
                  if (ok) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Empleado creado (uid: ${vm.creadoUid ?? '—'})',
                        ),
                      ),
                    );
                    Navigator.pop(context); // vuelve a Home
                  }
                },
                child: vm.loading
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Registrar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
