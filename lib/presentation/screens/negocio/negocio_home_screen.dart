import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_provider.dart';
import '../../../data/services/negocio_provider.dart';
import 'registro_negocio_screen.dart';
import 'mis_productos_screen.dart';
import 'pedidos_negocio_screen.dart';


class NegocioHomeScreen extends StatefulWidget {
  const NegocioHomeScreen({super.key});

  @override
  State<NegocioHomeScreen> createState() => _NegocioHomeScreenState();
}

class _NegocioHomeScreenState extends State<NegocioHomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      final negocioProvider = context.read<NegocioProvider>();
      if (auth.usuario != null) {
        negocioProvider.cargarNegocio(auth.usuario!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final negocioProvider = context.watch<NegocioProvider>();

    if (negocioProvider.cargando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    if (!negocioProvider.tieneNegocio) {
      return RegistroNegocioScreen();
    }

    return _PanelNegocio(
      auth: auth,
      negocioProvider: negocioProvider,
    );
  }
}

class _PanelNegocio extends StatelessWidget {
  final AuthProvider auth;
  final NegocioProvider negocioProvider;

  const _PanelNegocio({
    required this.auth,
    required this.negocioProvider,
  });

  @override
  Widget build(BuildContext context) {
    final negocio = negocioProvider.negocio!;
    final productos = negocioProvider.productos;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        negocio.nombre,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        negocio.categoria,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => auth.cerrarSesion(),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          negocio.nombre[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Toggle abierto/cerrado
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE9ECEF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Estado del negocio',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          negocio.abierto ? 'Abierto — recibiendo pedidos' : 'Cerrado',
                          style: TextStyle(
                            fontSize: 13,
                            color: negocio.abierto
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: negocio.abierto,
                      activeColor: AppColors.primary,
                      onChanged: (val) =>
                          negocioProvider.toggleAbierto(val),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Stats
              Row(
                children: [
                  _StatCard(
                    titulo: 'Productos',
                    valor: '${productos.length}',
                    icono: Icons.fastfood_outlined,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    titulo: 'Calificación',
                    valor: negocio.calificacion.toStringAsFixed(1),
                    icono: Icons.star_outline_rounded,
                    color: const Color(0xFFFFC300),
                  ),
                  const SizedBox(width: 12),
                  _StatCard(
                    titulo: 'Reseñas',
                    valor: '${negocio.totalResenas}',
                    icono: Icons.reviews_outlined,
                    color: AppColors.info,
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Botones de acción
              const Text(
                'Gestión',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              _AccionBtn(
                icono: Icons.restaurant_menu_outlined,
                titulo: 'Mis productos',
                subtitulo: 'Agregar, editar o desactivar productos',
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MisProductosScreen(),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _AccionBtn(
                icono: Icons.receipt_long_outlined,
                titulo: 'Pedidos activos',
                subtitulo: 'Ver y gestionar pedidos entrantes',
                onTap: () => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => const PedidosNegocioScreen(),
  ),
),
                badge: '0',
              ),
              const SizedBox(height: 10),
              _AccionBtn(
                icono: Icons.bar_chart_outlined,
                titulo: 'Mis ventas',
                subtitulo: 'Historial y estadísticas',
                onTap: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _StatCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              valor,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              titulo,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AccionBtn extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final VoidCallback onTap;
  final String? badge;

  const _AccionBtn({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icono, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitulo,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              )
            else
              const Icon(Icons.arrow_forward_ios,
                  size: 16, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}