import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/negocio_model.dart';
import '../../../data/services/auth_provider.dart';
import '../../../data/services/negocio_service.dart';
import 'negocio_detalle_screen.dart';
import 'mis_pedidos_screen.dart';

class ClienteHomeScreen extends StatefulWidget {
  const ClienteHomeScreen({super.key});

  @override
  State<ClienteHomeScreen> createState() => _ClienteHomeScreenState();
}

class _ClienteHomeScreenState extends State<ClienteHomeScreen> {
  final NegocioService _negocioService = NegocioService();
  final TextEditingController _buscarCtrl = TextEditingController();
  String _categoriaSeleccionada = 'Todos';
  String _busqueda = '';

  final List<Map<String, dynamic>> _categorias = [
    {'nombre': 'Todos', 'icono': Icons.restaurant_menu},
    {'nombre': 'Lonchería', 'icono': Icons.lunch_dining},
    {'nombre': 'Antojitos', 'icono': Icons.fastfood},
    {'nombre': 'Mariscos', 'icono': Icons.set_meal},
    {'nombre': 'Dulces', 'icono': Icons.cake},
    {'nombre': 'Bebidas', 'icono': Icons.local_drink},
  ];

  @override
  void dispose() {
    _buscarCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, ${auth.usuario?.nombre.split(' ').first ?? 'Usuario'} 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const Text(
                              'Felipe Carrillo Puerto',
                              style: TextStyle(
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
                                ((auth.usuario?.nombre?.isNotEmpty == true)
                                        ? auth.usuario!.nombre[0]
                                        : 'U')
                                    .toUpperCase(),
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
const SizedBox(height: 12),
GestureDetector(
  onTap: () => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => const MisPedidosScreen()),
  ),
  child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    decoration: BoxDecoration(
      color: AppColors.primary.withOpacity(0.08),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
    ),
    child: const Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.receipt_long_outlined,
            color: AppColors.primary, size: 18),
        SizedBox(width: 8),
        Text(
          'Mis pedidos',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ],
    ),
  ),
),









                    
                    const SizedBox(height: 20),
                    TextField(
                      controller: _buscarCtrl,
                      onChanged: (v) =>
                          setState(() => _busqueda = v.toLowerCase()),
                      decoration: InputDecoration(
                        hintText: 'Buscar loncherías, antojitos...',
                        prefixIcon: const Icon(Icons.search,
                            color: AppColors.textSecondary),
                        suffixIcon: _busqueda.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close,
                                    color: AppColors.textSecondary),
                                onPressed: () {
                                  _buscarCtrl.clear();
                                  setState(() => _busqueda = '');
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),




            // Banner promo
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 130,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -10,
                      bottom: -10,
                      child: Opacity(
                        opacity: 0.15,
                        child: Image.asset(
                          'assets/images/logo.png',
                          width: 130,
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '🎉 ¡Bienvenido a BisiFoods!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Apoya la comida local\nde Felipe Carrillo Puerto',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Categorías
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Categorías',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 90,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      scrollDirection: Axis.horizontal,
                      itemCount: _categorias.length,
                      itemBuilder: (context, i) {
                        final cat = _categorias[i];
                        final seleccionado =
                            _categoriaSeleccionada == cat['nombre'];
                        return GestureDetector(
                          onTap: () => setState(
                              () => _categoriaSeleccionada = cat['nombre']),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 70,
                            child: Column(
                              children: [
                                AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: seleccionado
                                        ? AppColors.primary
                                        : AppColors.surface,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: seleccionado
                                          ? AppColors.primary
                                          : const Color(0xFFE9ECEF),
                                    ),
                                  ),
                                  child: Icon(
                                    cat['icono'] as IconData,
                                    color: seleccionado
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  cat['nombre'],
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: seleccionado
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color: seleccionado
                                        ? AppColors.primary
                                        : AppColors.textSecondary,
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // Título negocios
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _categoriaSeleccionada == 'Todos'
                      ? 'Todos los negocios'
                      : _categoriaSeleccionada,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Lista de negocios
            StreamBuilder<List<NegocioModel>>(
              stream: _categoriaSeleccionada == 'Todos'
                  ? _negocioService.obtenerNegocios()
                  : _negocioService.obtenerPorCategoria(_categoriaSeleccionada),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CircularProgressIndicator(
                            color: AppColors.primary),
                      ),
                    ),
                  );
                }

                final negocios = (snapshot.data ?? []).where((n) {
                  if (_busqueda.isEmpty) return true;
                  return n.nombre.toLowerCase().contains(_busqueda) ||
                      n.categoria.toLowerCase().contains(_busqueda);
                }).toList();

                if (negocios.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            Icon(Icons.store_outlined,
                                size: 64, color: AppColors.textHint),
                            const SizedBox(height: 16),
                            const Text(
                              'No hay negocios disponibles',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const Text(
                              'Pronto habrá más opciones',
                              style: TextStyle(
                                color: AppColors.textHint,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) => _NegocioCard(negocio: negocios[i]),
                      childCount: negocios.length,
                    ),
                  ),
                );
              },
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}

class _NegocioCard extends StatelessWidget {
  final NegocioModel negocio;
  const _NegocioCard({required this.negocio});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => NegocioDetalleScreen(negocio: negocio),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE9ECEF)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: negocio.imagenUrl.isNotEmpty
                  ? Image.network(
                      negocio.imagenUrl,
                      height: 140,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _imagenPlaceholder(),
                    )
                  : _imagenPlaceholder(),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          negocio.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: negocio.abierto
                              ? AppColors.success.withOpacity(0.1)
                              : AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          negocio.abierto ? 'Abierto' : 'Cerrado',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: negocio.abierto
                                ? AppColors.success
                                : AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    negocio.descripcion,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFC300), size: 16),
                      const SizedBox(width: 4),
                      Text(
                        negocio.calificacion.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${negocio.totalResenas})',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.access_time_rounded,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        negocio.tiempoEntrega,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(Icons.delivery_dining,
                          color: AppColors.textSecondary, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        negocio.costoEnvio == 0
                            ? 'Gratis'
                            : '\$${negocio.costoEnvio.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: negocio.costoEnvio == 0
                              ? AppColors.success
                              : AppColors.textSecondary,
                          fontWeight: negocio.costoEnvio == 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenPlaceholder() {
    return Container(
      height: 140,
      width: double.infinity,
      color: AppColors.accent,
      child: const Center(
        child: Icon(Icons.store_outlined,
            size: 48, color: AppColors.primary),
      ),
    );
  }
}