import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';
import '../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<UsuarioModel?> registrar({
    required String nombre,
    required String email,
    required String password,
    required String telefono,
    required String rol,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      print('UID creado: ${credential.user!.uid}');

      final usuario = UsuarioModel(
        uid: credential.user!.uid,
        nombre: nombre,
        email: email,
        telefono: telefono,
        rol: rol,
        fechaCreacion: DateTime.now(),
      );

      await _db
          .collection(AppConstants.colUsuarios)
          .doc(credential.user!.uid)
          .set(usuario.toMap());

      print('Usuario guardado en Firestore con rol: $rol');

      return usuario;
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    } catch (e) {
      print('Error al guardar en Firestore: $e');
      rethrow;
    }
  }

  Future<UsuarioModel?> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await obtenerUsuario(credential.user!.uid);
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  Future<UsuarioModel?> obtenerUsuario(String uid) async {
    try {
      final doc = await _db
          .collection(AppConstants.colUsuarios)
          .doc(uid)
          .get()
          .timeout(const Duration(seconds: 10));

      if (doc.exists) {
        return UsuarioModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error obtenerUsuario: $e');
      return null;
    }
  }

  Future<void> cerrarSesion() async {
    await _auth.signOut();
  }

  Future<void> recuperarPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _manejarError(e);
    }
  }

  String _manejarError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya está registrado';
      case 'invalid-email':
        return 'Correo electrónico inválido';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres';
      case 'user-not-found':
        return 'No existe una cuenta con este correo';
      case 'wrong-password':
        return 'Contraseña incorrecta';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      default:
        return 'Error: ${e.message}';
    }
  }
}