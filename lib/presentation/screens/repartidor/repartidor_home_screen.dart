import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/pedido_model.dart';
import '../../../data/services/auth_provider.dart';

class RepartidorHomeScreen extends StatelessWidget {
  const RepartidorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hola, ${auth.usuario?.nombre.split(' ').first ?? 'Repartidor'} 👋',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Text(
                        'Pedidos listos para entregar',
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
                        color: AppColors.repartidorColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          ((auth.usuario?.nombre?.isNotEmpty == true)
                                  ? auth.usuario!.nombre[0]
                                  : 'R')
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
            ),

            // Lista de pedidos listos
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(AppConstants.colPedidos)
                    .where('estado', whereIn: [
                      AppConstants.estadoListo,
                      AppConstants.estadoEnCamino,
                    ])
                    .orderBy('fechaCreacion', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                          color: AppColors.repartidorColor),
                    );
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.delivery_dining,
                              size: 64, color: AppColors.textHint),
                          const SizedBox(height: 16),
                          const Text(
                            'Sin entregas pendientes',
                            style: TextStyle(
                              fontSize: 16,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const Text(
                            'Los pedidos listos aparecerán aquí',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final pedidos = docs
                      .map((d) => PedidoModel.fromMap(
                          d.data() as Map<String, dynamic>, d.id))
                      .toList();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: pedidos.length,
                    itemBuilder: (context, i) =>
                        _EntregaCard(pedido: pedidos[i], auth: auth),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntregaCard extends StatelessWidget {
  final PedidoModel pedido;
  final AuthProvider auth;

  const _EntregaCard({required this.pedido, required this.auth});

  Future<void> _cambiarEstado(String nuevoEstado) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.colPedidos)
        .doc(pedido.id)
        .update({
      'estado': nuevoEstado,
      'repartidorId': auth.usuario?.uid,
      if (nuevoEstado == AppConstants.estadoEntregado)
        'fechaEntregado': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final enCamino = pedido.estado == AppConstants.estadoEnCamino;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: enCamino
              ? AppColors.repartidorColor
              : const Color(0xFFE9ECEF),
          width: enCamino ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: enCamino
                  ? AppColors.repartidorColor.withOpacity(0.08)
                  : AppColors.success.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pedido.negocioNombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Cliente: ${pedido.clienteNombre}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: enCamino
                        ? AppColors.repartidorColor.withOpacity(0.15)
                        : AppColors.success.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    enCamino ? 'En camino' : 'Listo',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: enCamino
                          ? AppColors.repartidorColor
                          : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dirección
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: AppColors.error, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        pedido.direccionEntrega,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Items resumidos
                Text(
                  pedido.items.map((i) => '${i.cantidad}x ${i.nombre}').join(', '),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          pedido.metodoPago == AppConstants.pagoEfectivo
                              ? Icons.payments_outlined
                              : Icons.credit_card_outlined,
                          size: 14,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pedido.metodoPago == AppConstants.pagoEfectivo
                              ? 'Cobrar \$${pedido.total.toStringAsFixed(0)}'
                              : 'Ya pagado',
                          style: TextStyle(
                            fontSize: 13,
                            color: pedido.metodoPago ==
                                    AppConstants.pagoEfectivo
                                ? AppColors.warning
                                : AppColors.success,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Total: \$${pedido.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Botón acción
                if (!enCamino)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _cambiarEstado(AppConstants.estadoEnCamino),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.repartidorColor,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Tomar entrega'),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () =>
                          _cambiarEstado(AppConstants.estadoEntregado),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Marcar como entregado'),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}