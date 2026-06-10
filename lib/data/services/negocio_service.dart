import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/negocio_model.dart';
import '../models/producto_model.dart';
import '../../core/constants/app_constants.dart';

class NegocioService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Obtener todos los negocios activos
  Stream<List<NegocioModel>> obtenerNegocios() {
    return _db
        .collection(AppConstants.colNegocios)
        .where('activo', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NegocioModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener negocios por categoría
  Stream<List<NegocioModel>> obtenerPorCategoria(String categoria) {
    return _db
        .collection(AppConstants.colNegocios)
        .where('activo', isEqualTo: true)
        .where('categoria', isEqualTo: categoria)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => NegocioModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener productos de un negocio
  Stream<List<ProductoModel>> obtenerProductos(String negocioId) {
    return _db
        .collection(AppConstants.colProductos)
        .where('negocioId', isEqualTo: negocioId)
        .where('disponible', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((doc) => ProductoModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Obtener negocio por id
  Future<NegocioModel?> obtenerNegocio(String id) async {
    final doc = await _db.collection(AppConstants.colNegocios).doc(id).get();
    if (doc.exists) return NegocioModel.fromMap(doc.data()!, doc.id);
    return null;
  }
}