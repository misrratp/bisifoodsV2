import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/pedido_model.dart';
import '../../../data/services/negocio_provider.dart';

class PedidosNegocioScreen extends StatelessWidget {
  const PedidosNegocioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final negocioProvider = context.read<NegocioProvider>();
    final negocioId = negocioProvider.negocio?.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pedidos activos'),
        backgroundColor: AppColors.surface,
      ),
      body: negocioId == null
          ? const Center(child: Text('No hay negocio activo'))
          : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(AppConstants.colPedidos)
                  .where('negocioId', isEqualTo: negocioId)
                  .where('estado', whereIn: [
                    AppConstants.estadoPendiente,
                    AppConstants.estadoAceptado,
                    AppConstants.estadoPreparando,
                    AppConstants.estadoListo,
                  ])
                  .orderBy('fechaCreacion', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
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
                        Icon(Icons.receipt_long_outlined,
                            size: 64, color: AppColors.textHint),
                        const SizedBox(height: 16),
                        const Text(
                          'Sin pedidos activos',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const Text(
                          'Los pedidos nuevos aparecerán aquí',
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
                  padding: const EdgeInsets.all(20),
                  itemCount: pedidos.length,
                  itemBuilder: (context, i) =>
                      _PedidoCard(pedido: pedidos[i]),
                );
              },
            ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final PedidoModel pedido;
  const _PedidoCard({required this.pedido});

  Color _colorEstado(String estado) {
    switch (estado) {
      case AppConstants.estadoPendiente:
        return AppColors.warning;
      case AppConstants.estadoAceptado:
        return AppColors.info;
      case AppConstants.estadoPreparando:
        return AppColors.primary;
      case AppConstants.estadoListo:
        return AppColors.success;
      default:
        return AppColors.textSecondary;
    }
  }

  String _labelEstado(String estado) {
    switch (estado) {
      case AppConstants.estadoPendiente:
        return 'Pendiente';
      case AppConstants.estadoAceptado:
        return 'Aceptado';
      case AppConstants.estadoPreparando:
        return 'Preparando';
      case AppConstants.estadoListo:
        return 'Listo';
      default:
        return estado;
    }
  }

  Future<void> _cambiarEstado(BuildContext context, String nuevoEstado) async {
    await FirebaseFirestore.instance
        .collection(AppConstants.colPedidos)
        .doc(pedido.id)
        .update({
      'estado': nuevoEstado,
      if (nuevoEstado == AppConstants.estadoAceptado)
        'fechaAceptado': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    final color = _colorEstado(pedido.estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del pedido
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
                      pedido.clienteNombre,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      pedido.direccionEntrega,
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

          // Items del pedido
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...pedido.items.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item.cantidad}x ${item.nombre}',
                            style: const TextStyle(
                                color: AppColors.textPrimary),
                          ),
                          Text(
                            '\$${item.subtotal.toStringAsFixed(0)}',
                            style: const TextStyle(
                                color: AppColors.textSecondary),
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
                        Icon(
                          pedido.metodoPago == AppConstants.pagoEfectivo
                              ? Icons.payments_outlined
                              : Icons.credit_card_outlined,
                          size: 16,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          pedido.metodoPago == AppConstants.pagoEfectivo
                              ? 'Efectivo'
                              : 'MercadoPago',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Total: \$${pedido.total.toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                if (pedido.notas != null && pedido.notas!.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.note_outlined,
                            size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            pedido.notas!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 12),

                // Botones de acción
                _BotonesAccion(
                  estado: pedido.estado,
                  onCambiar: (nuevoEstado) =>
                      _cambiarEstado(context, nuevoEstado),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BotonesAccion extends StatelessWidget {
  final String estado;
  final Function(String) onCambiar;

  const _BotonesAccion({required this.estado, required this.onCambiar});

  @override
  Widget build(BuildContext context) {
    switch (estado) {
      case AppConstants.estadoPendiente:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () =>
                    onCambiar(AppConstants.estadoCancelado),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Rechazar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () =>
                    onCambiar(AppConstants.estadoAceptado),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(0, 44),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Aceptar'),
              ),
            ),
          ],
        );
      case AppConstants.estadoAceptado:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onCambiar(AppConstants.estadoPreparando),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Empezar a preparar'),
          ),
        );
      case AppConstants.estadoPreparando:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => onCambiar(AppConstants.estadoListo),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Marcar como listo'),
          ),
        );
      case AppConstants.estadoListo:
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_outline,
                  color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Text(
                'Listo para entregar',
                style: TextStyle(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox();
    }
  }
}