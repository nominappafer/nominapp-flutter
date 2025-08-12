import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/usuario_viewmodel.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<UsuarioViewModel>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar Sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: vm.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: vm.emailController,
                decoration: const InputDecoration(labelText: 'Correo electrónico'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese su correo' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: vm.passwordController,
                decoration: const InputDecoration(labelText: 'Contraseña'),
                obscureText: true,
                validator: (value) =>
                value == null || value.isEmpty ? 'Ingrese su contraseña' : null,
              ),
              const SizedBox(height: 24),
              if (vm.errorMessage.isNotEmpty)
                Text(
                  vm.errorMessage,
                  style: const TextStyle(color: Colors.red),
                ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  bool success = await vm.login();
                  if (success && context.mounted) {
                    final user = vm.currentUser!;
                    if (user.rol == 'empleado') {
                      Navigator.pushNamed(context, '/homeEmpleado');
                    } else if (user.rol == 'cajero') {
                      Navigator.pushNamed(context, '/homeCajero');
                    } else {
                      Navigator.pushNamed(context, '/homeAdmin');
                    }
                  }
                },
                child: const Text('Iniciar Sesión'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}