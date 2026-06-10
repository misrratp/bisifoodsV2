import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/negocio_model.dart';
import '../models/producto_model.dart';
import '../../core/constants/app_constants.dart';

class NegocioProvider extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  NegocioModel? _negocio;
  List<ProductoModel> _productos = [];
  bool _cargando = false;
  String? _error;

  NegocioModel? get negocio => _negocio;
  List<ProductoModel> get productos => _productos;
  bool get cargando => _cargando;
  String? get error => _error;
  bool get tieneNegocio => _negocio != null;

  Future<void> cargarNegocio(String propietarioId) async {
    try {
      final snap = await _db
          .collection(AppConstants.colNegocios)
          .where('propietarioId', isEqualTo: propietarioId)
          .limit(1)
          .get();

      if (snap.docs.isNotEmpty) {
        _negocio = NegocioModel.fromMap(snap.docs.first.data(), snap.docs.first.id);
        await cargarProductos(_negocio!.id);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> cargarProductos(String negocioId) async {
    try {
      final snap = await _db
          .collection(AppConstants.colProductos)
          .where('negocioId', isEqualTo: negocioId)
          .get();
      _productos = snap.docs
          .map((d) => ProductoModel.fromMap(d.data(), d.id))
          .toList();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
    }
  }

  Future<bool> crearNegocio({
    required String nombre,
    required String descripcion,
    required String categoria,
    required String telefono,
    required String direccion,
    required String propietarioId,
    required double costoEnvio,
    required String tiempoEntrega,
  }) async {
    _setCargando(true);
    try {
      final ref = _db.collection(AppConstants.colNegocios).doc();
      final negocio = NegocioModel(
        id: ref.id,
        nombre: nombre,
        descripcion: descripcion,
        categoria: categoria,
        imagenUrl: '',
        propietarioId: propietarioId,
        telefono: telefono,
        direccion: direccion,
        latitud: AppConstants.latitudCiudad,
        longitud: AppConstants.longitudCiudad,
        tiempoEntrega: tiempoEntrega,
        costoEnvio: costoEnvio,
        fechaCreacion: DateTime.now(),
      );
      await ref.set(negocio.toMap());
      _negocio = negocio;
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

  Future<bool> agregarProducto({
    required String nombre,
    required String descripcion,
    required double precio,
    required String categoria,
  }) async {
    if (_negocio == null) return false;
    _setCargando(true);
    try {
      final ref = _db.collection(AppConstants.colProductos).doc();
      final producto = ProductoModel(
        id: ref.id,
        negocioId: _negocio!.id,
        nombre: nombre,
        descripcion: descripcion,
        precio: precio,
        imagenUrl: '',
        categoria: categoria,
      );
      await ref.set(producto.toMap());
      _productos.add(producto);
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

  Future<bool> toggleDisponible(String productoId, bool disponible) async {
    try {
      await _db
          .collection(AppConstants.colProductos)
          .doc(productoId)
          .update({'disponible': disponible});
      final idx = _productos.indexWhere((p) => p.id == productoId);
      if (idx != -1) {
        _productos[idx] = ProductoModel(
          id: _productos[idx].id,
          negocioId: _productos[idx].negocioId,
          nombre: _productos[idx].nombre,
          descripcion: _productos[idx].descripcion,
          precio: _productos[idx].precio,
          imagenUrl: _productos[idx].imagenUrl,
          categoria: _productos[idx].categoria,
          disponible: disponible,
          destacado: _productos[idx].destacado,
        );
        notifyListeners();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> toggleAbierto(bool abierto) async {
    if (_negocio == null) return false;
    try {
      await _db
          .collection(AppConstants.colNegocios)
          .doc(_negocio!.id)
          .update({'abierto': abierto});
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  void _setCargando(bool valor) {
    _cargando = valor;
    notifyListeners();
  }
}