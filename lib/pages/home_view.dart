// lib/views/home_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/home_viewmodel.dart';
import '../viewmodels/usuario_viewmodel.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<HomeViewModel>().cargarNominaActual());
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<HomeViewModel>();
    final rol = context.select<UsuarioViewModel, String?>((u) => u.obtenerRol());

    final esAdmin  = rol == 'admin';
    final esCajero = rol == 'cajero';

    return Scaffold(
      appBar: AppBar(title: const Text('Nómina Mensual Actual')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
              child: vm.loading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Nómina Mensual Actual:',
                      style: TextStyle(color: Colors.white)),
                  const SizedBox(height: 8),
                  Text('\$ ${vm.nomina?.valorActual ?? '---'}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _HomeButton(
                  icon: Icons.history,
                  label: 'Historial',
                  onTap: () => Navigator.pushNamed(context, '/historial'),
                ),
                _HomeButton(
                  icon: Icons.post_add,
                  label: 'Crear Solicitud',
                  onTap: () => Navigator.pushNamed(context, '/crearSolicitud'),
                ),
                _HomeButton(
                  icon: Icons.calendar_today,
                  label: 'Ver detalle nómina',
                  onTap: () => Navigator.pushNamed(context, '/detalleNomina'),
                ),
                _HomeButton(
                  icon: Icons.list_alt,
                  label: 'Ver días descanso',
                  onTap: () => Navigator.pushNamed(context, '/diasDescanso'),
                ),

                // Solo admin o cajero
                if (esAdmin || esCajero)
                  _HomeButton(
                    icon: Icons.verified,
                    label: 'Aprobar Solicitudes',
                    onTap: () =>
                        Navigator.pushNamed(context, '/aprobarSolicitudes'),
                  ),
                if (esAdmin || esCajero)
                  _HomeButton(
                    icon: Icons.date_range,
                    label: 'Marcar Asistencia',
                    onTap: () => Navigator.pushNamed(context, '/asistencia'),
                  ),

                // Solo admin
                if (esAdmin)
                  _HomeButton(
                    icon: Icons.person_add_alt_1,
                    label: 'Registrar empleado',
                    onTap: () =>
                        Navigator.pushNamed(context, '/registrarEmpleado'),
                  ),
                if (esAdmin)
                  _HomeButton(
                    icon: Icons.people_alt,
                    label: 'Nómina empleados',
                    onTap: () => Navigator.pushNamed(context, '/nominasGlobales'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _HomeButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 150,
        height: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 6)],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 28),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}