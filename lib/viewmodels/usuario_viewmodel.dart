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
        return false;
      }

      _usuario = Usuario.fromMap(uid, doc.data() as Map<String, dynamic>);

      if (!_usuario!.activo) {
        await _auth.signOut();
        errorMessage = 'El usuario está inactivo.';
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

  Future<void> cerrarSesion() async {
    await _auth.signOut();
    _usuario = null;
    emailController.clear();
    passwordController.clear();
    notifyListeners();
  }

  bool estaAutenticado() => _auth.currentUser != null && _usuario != null;

  String? obtenerRol() => _usuario?.rol;
  String? obtenerUID() => _usuario?.uid;
  String? obtenerNombre() => _usuario?.nombre;
}
