import 'package:cloud_firestore/cloud_firestore.dart';

class ItemPedido {
  final String productoId;
  final String nombre;
  final double precio;
  final int cantidad;
  final String? notas;

  ItemPedido({
    required this.productoId,
    required this.nombre,
    required this.precio,
    required this.cantidad,
    this.notas,
  });

  factory ItemPedido.fromMap(Map<String, dynamic> map) {
    return ItemPedido(
      productoId: map['productoId'] ?? '',
      nombre: map['nombre'] ?? '',
      precio: (map['precio'] ?? 0.0).toDouble(),
      cantidad: map['cantidad'] ?? 1,
      notas: map['notas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productoId': productoId,
      'nombre': nombre,
      'precio': precio,
      'cantidad': cantidad,
      'notas': notas,
    };
  }

  double get subtotal => precio * cantidad;
}

class PedidoModel {
  final String id;
  final String clienteId;
  final String clienteNombre;
  final String negocioId;
  final String negocioNombre;
  final String? repartidorId;
  final List<ItemPedido> items;
  final double subtotal;
  final double costoEnvio;
  final double total;
  final String estado;
  final String metodoPago;
  final String direccionEntrega;
  final double? latitudEntrega;
  final double? longitudEntrega;
  final String? notas;
  final DateTime fechaCreacion;
  final DateTime? fechaAceptado;
  final DateTime? fechaEntregado;

  PedidoModel({
    required this.id,
    required this.clienteId,
    required this.clienteNombre,
    required this.negocioId,
    required this.negocioNombre,
    this.repartidorId,
    required this.items,
    required this.subtotal,
    required this.costoEnvio,
    required this.total,
    required this.estado,
    required this.metodoPago,
    required this.direccionEntrega,
    this.latitudEntrega,
    this.longitudEntrega,
    this.notas,
    required this.fechaCreacion,
    this.fechaAceptado,
    this.fechaEntregado,
  });

  factory PedidoModel.fromMap(Map<String, dynamic> map, String id) {
    return PedidoModel(
      id: id,
      clienteId: map['clienteId'] ?? '',
      clienteNombre: map['clienteNombre'] ?? '',
      negocioId: map['negocioId'] ?? '',
      negocioNombre: map['negocioNombre'] ?? '',
      repartidorId: map['repartidorId'],
      items: (map['items'] as List<dynamic>? ?? [])
          .map((i) => ItemPedido.fromMap(i))
          .toList(),
      subtotal: (map['subtotal'] ?? 0.0).toDouble(),
      costoEnvio: (map['costoEnvio'] ?? 0.0).toDouble(),
      total: (map['total'] ?? 0.0).toDouble(),
      estado: map['estado'] ?? 'pendiente',
      metodoPago: map['metodoPago'] ?? 'efectivo',
      direccionEntrega: map['direccionEntrega'] ?? '',
      latitudEntrega: map['latitudEntrega']?.toDouble(),
      longitudEntrega: map['longitudEntrega']?.toDouble(),
      notas: map['notas'],
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      fechaAceptado: map['fechaAceptado'] != null
          ? (map['fechaAceptado'] as Timestamp).toDate()
          : null,
      fechaEntregado: map['fechaEntregado'] != null
          ? (map['fechaEntregado'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'clienteId': clienteId,
      'clienteNombre': clienteNombre,
      'negocioId': negocioId,
      'negocioNombre': negocioNombre,
      'repartidorId': repartidorId,
      'items': items.map((i) => i.toMap()).toList(),
      'subtotal': subtotal,
      'costoEnvio': costoEnvio,
      'total': total,
      'estado': estado,
      'metodoPago': metodoPago,
      'direccionEntrega': direccionEntrega,
      'latitudEntrega': latitudEntrega,
      'longitudEntrega': longitudEntrega,
      'notas': notas,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'fechaAceptado':
          fechaAceptado != null ? Timestamp.fromDate(fechaAceptado!) : null,
      'fechaEntregado':
          fechaEntregado != null ? Timestamp.fromDate(fechaEntregado!) : null,
    };
  }
}