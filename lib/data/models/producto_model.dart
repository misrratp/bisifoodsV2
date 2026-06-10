import 'package:cloud_firestore/cloud_firestore.dart';

class ProductoModel {
  final String id;
  final String negocioId;
  final String nombre;
  final String descripcion;
  final double precio;
  final String imagenUrl;
  final String categoria;
  final bool disponible;
  final bool destacado;

  ProductoModel({
    required this.id,
    required this.negocioId,
    required this.nombre,
    required this.descripcion,
    required this.precio,
    required this.imagenUrl,
    required this.categoria,
    this.disponible = true,
    this.destacado = false,
  });

  factory ProductoModel.fromMap(Map<String, dynamic> map, String id) {
    return ProductoModel(
      id: id,
      negocioId: map['negocioId'] ?? '',
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      imagenUrl: map['imagenUrl'] ?? '',
      categoria: map['categoria'] ?? '',
      disponible: map['disponible'] ?? true,
      destacado: map['destacado'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'negocioId': negocioId,
      'nombre': nombre,
      'descripcion': descripcion,
      'precio': precio,
      'imagenUrl': imagenUrl,
      'categoria': categoria,
      'disponible': disponible,
      'destacado': destacado,
    };
  }
}