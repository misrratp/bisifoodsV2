import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_constants.dart';

// Handler para mensajes en background
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Mensaje en background: ${message.messageId}');
}

class NotificacionService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> inicializar(String uid) async {
    // Registrar handler background
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Pedir permisos
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('Permiso notificaciones: ${settings.authorizationStatus}');

    // Obtener token y guardarlo
    final token = await _messaging.getToken();
    if (token != null) {
      await _guardarToken(uid, token);
    }

    // Escuchar renovación de token
    _messaging.onTokenRefresh.listen((nuevoToken) {
      _guardarToken(uid, nuevoToken);
    });

    // Mensaje con app abierta
    FirebaseMessaging.onMessage.listen((message) {
      print('Mensaje recibido: ${message.notification?.title}');
    });
  }

  Future<void> _guardarToken(String uid, String token) async {
    await _db
        .collection(AppConstants.colUsuarios)
        .doc(uid)
        .update({'fcmToken': token});
  }
}