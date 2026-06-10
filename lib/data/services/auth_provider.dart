import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';
import 'auth_service.dart';
import '../../core/constants/app_constants.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  UsuarioModel? _usuario;
  bool _cargando = false;
  bool _inicializado = false;
  String? _error;

  UsuarioModel? get usuario => _usuario;
  bool get cargando => _cargando;
  bool get inicializado => _inicializado;
  String? get error => _error;
  bool get estaAutenticado => _usuario != null;
  String? get rol => _usuario?.rol;

  AuthProvider() {
    _authService.authStateChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? user) async {
    if (user != null) {
      try {
        final doc = await _db
            .collection(AppConstants.colUsuarios)
            .doc(user.uid)
            .get()
            .timeout(const Duration(seconds: 8));

        if (doc.exists && doc.data() != null) {
          _usuario = UsuarioModel.fromMap(doc.data()!, doc.id);
        } else {
          _usuario = UsuarioModel(
            uid: user.uid,
            nombre: user.displayName ?? user.email!.split('@')[0],
            email: user.email ?? '',
            telefono: '',
            rol: AppConstants.rolCliente,
            fechaCreacion: DateTime.now(),
          );
        }
      } catch (e) {
        _usuario = UsuarioModel(
          uid: user.uid,
          nombre: user.displayName ?? user.email!.split('@')[0],
          email: user.email ?? '',
          telefono: '',
          rol: AppConstants.rolCliente,
          fechaCreacion: DateTime.now(),
        );
      }
    } else {
      _usuario = null;
    }
    _inicializado = true;
    notifyListeners();
  }

  Future<bool> registrar({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String rol,
  }) async {
    _setCargando(true);
    try {
      _usuario = await _authService.registrar(
        nombre: nombre,
        email: email,
        password: password,
        telefono: telefono,
        rol: rol,
      );
      _inicializado = true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setCargando(true);
    try {
      final credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      try {
        final doc = await _db
            .collection(AppConstants.colUsuarios)
            .doc(credential.user!.uid)
            .get()
            .timeout(const Duration(seconds: 8));

        if (doc.exists && doc.data() != null) {
          _usuario = UsuarioModel.fromMap(doc.data()!, doc.id);
        } else {
          _usuario = UsuarioModel(
            uid: credential.user!.uid,
            nombre: credential.user!.displayName ?? email.split('@')[0],
            email: email,
            telefono: '',
            rol: AppConstants.rolCliente,
            fechaCreacion: DateTime.now(),
          );
        }
      } catch (e) {
        _usuario = UsuarioModel(
          uid: credential.user!.uid,
          nombre: credential.user!.displayName ?? email.split('@')[0],
          email: email,
          telefono: '',
          rol: AppConstants.rolCliente,
          fechaCreacion: DateTime.now(),
        );
      }

      _inicializado = true;
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setCargando(false);
    }
  }

  Future<void> cerrarSesion() async {
    await _authService.cerrarSesion();
    _usuario = null;
    notifyListeners();
  }

  void limpiarError() {
    _error = null;
    notifyListeners();
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}