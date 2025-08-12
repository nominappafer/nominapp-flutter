class Usuario {
  final String uid;
  final String nombre;
  final String email;
  final String rol;
  final bool activo;
  final String cedula;
  final int salarioBase;
  final DateTime fechaIngreso;

  Usuario({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.rol,
    required this.activo,
    required this.cedula,
    required this.salarioBase,
    required this.fechaIngreso,
  });

  factory Usuario.fromMap(String uid, Map<String, dynamic> data) {
    return Usuario(
      uid: uid,
      nombre: data['nombre'] ?? '',
      email: data['email'] ?? '',
      rol: data['rol'] ?? '',
      activo: data['activo'] ?? true,
      cedula: data['cedula'] ?? '',
      salarioBase: data['salarioBase'] ?? 0,
      fechaIngreso: DateTime.tryParse(data['fechaIngreso'] ?? '') ?? DateTime(2000),
    );
  }
}
