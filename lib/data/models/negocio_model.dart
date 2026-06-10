import 'package:cloud_firestore/cloud_firestore.dart';

class NegocioModel {
  final String id;
  final String nombre;
  final String descripcion;
  final String categoria;
  final String imagenUrl;
  final String propietarioId;
  final String telefono;
  final String direccion;
  final double latitud;
  final double longitud;
  final double calificacion;
  final int totalResenas;
  final bool abierto;
  final bool activo;
  final String tiempoEntrega; // "20-30 min"
  final double costoEnvio;
  final DateTime fechaCreacion;

  NegocioModel({
    required this.id,
    required this.nombre,
    required this.descripcion,
    required this.categoria,
    required this.imagenUrl,
    required this.propietarioId,
    required this.telefono,
    required this.direccion,
    required this.latitud,
    required this.longitud,
    this.calificacion = 0.0,
    this.totalResenas = 0,
    this.abierto = true,
    this.activo = true,
    this.tiempoEntrega = '20-30 min',
    this.costoEnvio = 0.0,
    required this.fechaCreacion,
  });

  factory NegocioModel.fromMap(Map<String, dynamic> map, String id) {
    return NegocioModel(
      id: id,
      nombre: map['nombre'] ?? '',
      descripcion: map['descripcion'] ?? '',
      categoria: map['categoria'] ?? '',
      imagenUrl: map['imagenUrl'] ?? '',
      propietarioId: map['propietarioId'] ?? '',
      telefono: map['telefono'] ?? '',
      direccion: map['direccion'] ?? '',
      latitud: (map['latitud'] ?? 0.0).toDouble(),
      longitud: (map['longitud'] ?? 0.0).toDouble(),
      calificacion: (map['calificacion'] ?? 0.0).toDouble(),
      totalResenas: map['totalResenas'] ?? 0,
      abierto: map['abierto'] ?? true,
      activo: map['activo'] ?? true,
      tiempoEntrega: map['tiempoEntrega'] ?? '20-30 min',
      costoEnvio: (map['costoEnvio'] ?? 0.0).toDouble(),
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'descripcion': descripcion,
      'categoria': categoria,
      'imagenUrl': imagenUrl,
      'propietarioId': propietarioId,
      'telefono': telefono,
      'direccion': direccion,
      'latitud': latitud,
      'longitud': longitud,
      'calificacion': calificacion,
      'totalResenas': totalResenas,
      'abierto': abierto,
      'activo': activo,
      'tiempoEntrega': tiempoEntrega,
      'costoEnvio': costoEnvio,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
    };
  }
}