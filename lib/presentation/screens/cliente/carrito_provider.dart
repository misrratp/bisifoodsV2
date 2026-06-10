import 'package:flutter/material.dart';
import '../../../data/models/producto_model.dart';
import '../../../data/models/negocio_model.dart';
import '../../../data/models/pedido_model.dart';

class CarritoProvider extends ChangeNotifier {
  List<ItemPedido> _items = [];
  String? _negocioId;
  String? _negocioNombre;

  List<ItemPedido> get items => _items;
  String? get negocioId => _negocioId;
  String? get negocioNombre => _negocioNombre;
  int get itemCount => _items.fold(0, (sum, i) => sum + i.cantidad);
  double get subtotal => _items.fold(0, (sum, i) => sum + i.subtotal);
  double get total => subtotal;

  int getCantidad(String productoId) {
    final idx = _items.indexWhere((i) => i.productoId == productoId);
    return idx != -1 ? _items[idx].cantidad : 0;
  }

  void agregar(ProductoModel producto, NegocioModel negocio) {
    // Si es de otro negocio, limpiar carrito
    if (_negocioId != null && _negocioId != negocio.id) {
      _items = [];
    }
    _negocioId = negocio.id;
    _negocioNombre = negocio.nombre;

    final idx = _items.indexWhere((i) => i.productoId == producto.id);
    if (idx != -1) {
      _items[idx] = ItemPedido(
        productoId: producto.id,
        nombre: producto.nombre,
        precio: producto.precio,
        cantidad: _items[idx].cantidad + 1,
      );
    } else {
      _items.add(ItemPedido(
        productoId: producto.id,
        nombre: producto.nombre,
        precio: producto.precio,
        cantidad: 1,
      ));
    }
    notifyListeners();
  }

  void quitar(String productoId) {
    final idx = _items.indexWhere((i) => i.productoId == productoId);
    if (idx != -1) {
      if (_items[idx].cantidad > 1) {
        _items[idx] = ItemPedido(
          productoId: _items[idx].productoId,
          nombre: _items[idx].nombre,
          precio: _items[idx].precio,
          cantidad: _items[idx].cantidad - 1,
        );
      } else {
        _items.removeAt(idx);
      }
      if (_items.isEmpty) _negocioId = null;
      notifyListeners();
    }
  }

  void limpiar() {
    _items = [];
    _negocioId = null;
    _negocioNombre = null;
    notifyListeners();
  }
}