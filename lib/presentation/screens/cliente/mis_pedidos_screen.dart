import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/pedido_model.dart';
import '../../../data/services/auth_provider.dart';

class MisPedidosScreen extends StatelessWidget {
  const MisPedidosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Mis pedidos'),
        backgroundColor: AppColors.surface,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.colPedidos)
            .where('clienteId', isEqualTo: auth.usuario!.uid)
            .orderBy('fechaCreacion', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined,
                      size: 64, color: AppColors.textHint),
                  const SizedBox(height: 16),
                  const Text(
                    'Sin pedidos aún',
                    style: TextStyle(
                        fontSize: 16, color: AppColors.textSecondary),
                  ),
                  const Text(
                    'Haz tu primer pedido',
                    style: TextStyle(
                        fontSize: 13, color: AppColors.textHint),
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
            padding: const EdgeInsets.all(20),
            itemCount: pedidos.length,
            itemBuilder: (context, i) => _PedidoClienteCard(pedido: pedidos[i]),
          );
        },
      ),
    );
  }
}

class _PedidoClienteCard extends StatelessWidget {
  final PedidoModel pedido;
  const _PedidoClienteCard({required this.pedido});

  Color _colorEstado(String estado) {
    switch (estado) {
      case AppConstants.estadoPendiente: return AppColors.warning;
      case AppConstants.estadoAceptado: return AppColors.info;
      case AppConstants.estadoPreparando: return AppColors.primary;
      case AppConstants.estadoListo: return AppColors.success;
      case AppConstants.estadoEnCamino: return AppColors.repartidorColor;
      case AppConstants.estadoEntregado: return AppColors.success;
      case AppConstants.estadoCancelado: return AppColors.error;
      default: return AppColors.textSecondary;
    }
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case AppConstants.estadoPendiente: return '⏳ Pendiente';
      case AppConstants.estadoAceptado: return '✅ Aceptado';
      case AppConstants.estadoPreparando: return '👨‍🍳 Preparando';
      case AppConstants.estadoListo: return '📦 Listo';
      case AppConstants.estadoEnCamino: return '🛵 En camino';
      case AppConstants.estadoEntregado: return '🎉 Entregado';
      case AppConstants.estadoCancelado: return '❌ Cancelado';
      default: return estado;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorEstado(pedido.estado);
    final entregado = pedido.estado == AppConstants.estadoEntregado;
    final cancelado = pedido.estado == AppConstants.estadoCancelado;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: entregado || cancelado
              ? const Color(0xFFE9ECEF)
              : color.withOpacity(0.5),
          width: entregado || cancelado ? 1 : 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
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
                      '${pedido.fechaCreacion.day}/${pedido.fechaCreacion.month}/${pedido.fechaCreacion.year}',
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
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _labelEstado(pedido.estado),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: color,
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
                // Items
                ...pedido.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.cantidad}x ${item.nombre}',
                            style: const TextStyle(
                                color: AppColors.textPrimary, fontSize: 13),
                          ),
                          Text(
                            '\$${item.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: AppColors.textSecondary, fontSize: 13),
                          ),
                        ],
                      ),
                    )),
                const Divider(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Text(
                          pedido.direccionEntrega,
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textSecondary),
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

                // Barra de progreso
                if (!cancelado) ...[
                  const SizedBox(height: 16),
                  _BarraProgreso(estado: pedido.estado),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BarraProgreso extends StatelessWidget {
  final String estado;
  const _BarraProgreso({required this.estado});

  int _pasoActual() {
    switch (estado) {
      case AppConstants.estadoPendiente: return 0;
      case AppConstants.estadoAceptado: return 1;
      case AppConstants.estadoPreparando: return 2;
      case AppConstants.estadoListo: return 3;
      case AppConstants.estadoEnCamino: return 4;
      case AppConstants.estadoEntregado: return 5;
      default: return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final paso = _pasoActual();
    final pasos = ['Enviado', 'Aceptado', 'Preparando', 'Listo', 'En camino', 'Entregado'];

    return Column(
      children: [
        Row(
          children: List.generate(pasos.length, (i) {
            final activo = i <= paso;
            final esCurrent = i == paso;
            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 4,
                      color: i <= paso
                          ? AppColors.primary
                          : const Color(0xFFE9ECEF),
                    ),
                  ),
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: activo ? AppColors.primary : const Color(0xFFE9ECEF),
                      shape: BoxShape.circle,
                      border: esCurrent
                          ? Border.all(color: AppColors.primary, width: 2)
                          : null,
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: pasos
              .map((p) => Text(
                    p,
                    style: TextStyle(
                      fontSize: 9,
                      color: pasos.indexOf(p) <= paso
                          ? AppColors.primary
                          : AppColors.textHint,
                      fontWeight: pasos.indexOf(p) == paso
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}