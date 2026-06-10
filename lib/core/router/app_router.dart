import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/services/auth_provider.dart';
import '../../presentation/screens/auth/splash_screen.dart';
import '../../presentation/screens/auth/login_screen.dart';
import '../../presentation/screens/auth/registro_screen.dart';
import '../../presentation/screens/cliente/cliente_home_screen.dart';
import '../../presentation/screens/negocio/negocio_home_screen.dart';
import '../../presentation/screens/repartidor/repartidor_home_screen.dart';
import '../../presentation/screens/admin/admin_home_screen.dart';
import '../../core/constants/app_constants.dart';

class AppRouter {
  static GoRouter createRouter(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        // Mientras no esté inicializado, quedarse en splash
        if (!authProvider.inicializado) {
          return '/splash';
        }

        final autenticado = authProvider.estaAutenticado;
        final enSplash = state.matchedLocation == '/splash';
        final enAuth = state.matchedLocation == '/login' ||
            state.matchedLocation == '/registro';

        if (enSplash && autenticado) {
          return _rutaPorRol(authProvider.rol);
        }

        if (enSplash && !autenticado) {
          return '/login';
        }

        if (!autenticado && !enAuth) return '/login';

        if (autenticado && enAuth) {
          return _rutaPorRol(authProvider.rol);
        }

        return null;
      },
      refreshListenable: authProvider,
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/registro',
          builder: (context, state) => const RegistroScreen(),
        ),
        GoRoute(
          path: '/cliente',
          builder: (context, state) => const ClienteHomeScreen(),
        ),
        GoRoute(
          path: '/negocio',
          builder: (context, state) => const NegocioHomeScreen(),
        ),
        GoRoute(
          path: '/repartidor',
          builder: (context, state) => const RepartidorHomeScreen(),
        ),
        GoRoute(
          path: '/admin',
          builder: (context, state) => const AdminHomeScreen(),
        ),
      ],
    );
  }

  static String _rutaPorRol(String? rol) {
    switch (rol) {
      case AppConstants.rolCliente:
        return '/cliente';
      case AppConstants.rolNegocio:
        return '/negocio';
      case AppConstants.rolRepartidor:
        return '/repartidor';
      case AppConstants.rolAdmin:
        return '/admin';
      default:
        return '/login';
    }
  }
}