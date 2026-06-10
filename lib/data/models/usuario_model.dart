import 'package:cloud_firestore/cloud_firestore.dart';

class UsuarioModel {
  final String uid;
  final String nombre;
  final String email;
  final String telefono;
  final String rol;
  final String? fotoUrl;
  final bool activo;
  final DateTime fechaCreacion;
  final String? negocioId;
  final double? latitud;
  final double? longitud;
  final String? fcmToken;

  UsuarioModel({
    required this.uid,
    required this.nombre,
    required this.email,
    required this.telefono,
    required this.rol,
    this.fotoUrl,
    this.activo = true,
    required this.fechaCreacion,
    this.negocioId,
    this.latitud,
    this.longitud,
    this.fcmToken,
  });

  factory UsuarioModel.fromMap(Map<String, dynamic> map, String uid) {
    return UsuarioModel(
      uid: uid,
      nombre: map['nombre'] ?? '',
      email: map['email'] ?? '',
      telefono: map['telefono'] ?? '',
      rol: map['rol'] ?? 'cliente',
      fotoUrl: map['fotoUrl'],
      activo: map['activo'] ?? true,
      fechaCreacion: (map['fechaCreacion'] as Timestamp).toDate(),
      negocioId: map['negocioId'],
      latitud: map['latitud']?.toDouble(),
      longitud: map['longitud']?.toDouble(),
      fcmToken: map['fcmToken'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': nombre,
      'email': email,
      'telefono': telefono,
      'rol': rol,
      'fotoUrl': fotoUrl,
      'activo': activo,
      'fechaCreacion': Timestamp.fromDate(fechaCreacion),
      'negocioId': negocioId,
      'latitud': latitud,
      'longitud': longitud,
      'fcmToken': fcmToken,
    };
  }

  UsuarioModel copyWith({
    String? nombre,
    String? telefono,
    String? fotoUrl,
    bool? activo,
    double? latitud,
    double? longitud,
    String? fcmToken,
  }) {
    return UsuarioModel(
      uid: uid,
      nombre: nombre ?? this.nombre,
      email: email,
      telefono: telefono ?? this.telefono,
      rol: rol,
      fotoUrl: fotoUrl ?? this.fotoUrl,
      activo: activo ?? this.activo,
      fechaCreacion: fechaCreacion,
      negocioId: negocioId,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }
}