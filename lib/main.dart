import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'data/services/auth_provider.dart';
import 'core/router/app_router.dart';
import 'firebase_options.dart';
import 'data/services/negocio_provider.dart';
import 'presentation/screens/cliente/carrito_provider.dart';
import 'data/services/notificacion_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BisiFoodsApp());
}

class BisiFoodsApp extends StatelessWidget {
  const BisiFoodsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => NegocioProvider()),
        ChangeNotifierProvider(create: (_) => CarritoProvider()),
      ],
      child: Builder(
        builder: (context) {
          final authProvider = context.watch<AuthProvider>();

          // Inicializar notificaciones cuando el usuario está autenticado
          if (authProvider.estaAutenticado && authProvider.usuario != null) {
            NotificacionService().inicializar(authProvider.usuario!.uid);
          }

          final router = AppRouter.createRouter(authProvider);
          return MaterialApp.router(
            title: 'BisiFoods',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            routerConfig: router,
          );
        },
      ),
    );
  }
}