import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/usuario.dart';

class UsuarioViewModel extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Usuario? _usuario;
  Usuario? get currentUser => _usuario;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  String errorMessage = '';

  // -------------------------
  // LOGIN
  // -------------------------
  Future<bool> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (!formKey.currentState!.validate()) return false;

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = cred.user!.uid;
      final doc = await _db.collection('empleados').doc(uid).get();

      if (!doc.exists) {
        errorMessage = 'No existe un documento en Firestore para este usuario.';
        notifyListeners();
        return false;
      }

      _usuario = Usuario.fromMap(uid, doc.data() as Map<String, dynamic>);

      if (!(_usuario?.activo ?? false)) {
        await _auth.signOut();
        errorMessage = 'El usuario está inactivo.';
        _usuario = null;
        notifyListeners();
        return false;
      }

      errorMessage = '';
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.message ?? 'Error de autenticación';
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Error inesperado: $e';
      notifyListeners();
      return false;
    }
  }

  // -------------------------
  // REFRESH DESDE FIRESTORE
  // -------------------------
  Future<bool> refrescarUsuario() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      final doc = await _db.collection('empleados').doc(uid).get();
      if (!doc.exists) return false;

      _usuario = Usuario.fromMap(uid, doc.data() as Map<String, dynamic>);
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'No se pudo refrescar el usuario: $e';
      notifyListeners();
      return false;
    }
  }

  // -------------------------
  // LOGOUT
  // -------------------------
  Future<void> cerrarSesion() async {
    await _auth.signOut();
    _usuario = null;
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  // -------------------------
  // GETTERS DE ESTADO
  // -------------------------
  bool estaAutenticado() => _auth.currentUser != null && _usuario != null;

  String? obtenerRol() => _usuario?.rol;
  String? obtenerUID() => _usuario?.uid;
  String? obtenerNombre() => _usuario?.nombre;

  /// YYYY-MM-DD crudo desde Firestore (puede ser null)
  String? get descansoInicioRaw => _usuario?.descansoInicio;

  /// Devuelve DateTime parseado de `descansoInicio` (o null si no hay/ inválido)
  DateTime? get descansoInicioDate {
    final raw = _usuario?.descansoInicio;
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.split('-');
      if (parts.length < 3) return null;
      final y = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final d = int.parse(parts[2]);
      return DateTime(y, m, d);
    } catch (_) {
      return null;
    }
  }

  /// Días entre descansos predispuestos (por ejemplo 16). Puede ser null si no está en BD.
  int? get descansoCadaDias => _usuario?.descansoCadaDias;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}