import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/negocio_model.dart';
import '../../../data/models/pedido_model.dart';
import '../../../data/services/auth_provider.dart';
import 'carrito_provider.dart';

class ConfirmarPedidoScreen extends StatefulWidget {
  final NegocioModel negocio;
  const ConfirmarPedidoScreen({super.key, required this.negocio});

  @override
  State<ConfirmarPedidoScreen> createState() => _ConfirmarPedidoScreenState();
}

class _ConfirmarPedidoScreenState extends State<ConfirmarPedidoScreen> {
  final _direccionCtrl = TextEditingController();
  final _notasCtrl = TextEditingController();
  String _metodoPago = AppConstants.pagoEfectivo;
  bool _enviando = false;

  @override
  void dispose() {
    _direccionCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  Future<void> _confirmarPedido() async {
    if (_direccionCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa tu dirección de entrega'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _enviando = true);

    try {
      final auth = context.read<AuthProvider>();
      final carrito = context.read<CarritoProvider>();
      final db = FirebaseFirestore.instance;

      final ref = db.collection(AppConstants.colPedidos).doc();
      final pedido = PedidoModel(
        id: ref.id,
        clienteId: auth.usuario!.uid,
        clienteNombre: auth.usuario!.nombre,
        negocioId: widget.negocio.id,
        negocioNombre: widget.negocio.nombre,
        items: carrito.items,
        subtotal: carrito.subtotal,
        costoEnvio: widget.negocio.costoEnvio,
        total: carrito.subtotal + widget.negocio.costoEnvio,
        estado: AppConstants.estadoPendiente,
        metodoPago: _metodoPago,
        direccionEntrega: _direccionCtrl.text.trim(),
        notas: _notasCtrl.text.isNotEmpty ? _notasCtrl.text.trim() : null,
        fechaCreacion: DateTime.now(),
      );

      await ref.set(pedido.toMap());
      carrito.limpiar();

      if (!mounted) return;
      Navigator.popUntil(context, (route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Pedido enviado! El negocio lo está revisando'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final carrito = context.watch<CarritoProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirmar pedido'),
        backgroundColor: AppColors.surface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumen del pedido
            _Seccion(
              titulo: 'Tu pedido',
              child: Column(
                children: [
                  ...carrito.items.map((item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                '${item.cantidad}x ${item.nombre}',
                                style: const TextStyle(
                                    color: AppColors.textPrimary),
                              ),
                            ),
                            Text(
                              '\$${item.subtotal.toStringAsFixed(0)}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Subtotal',
                          style: TextStyle(color: AppColors.textSecondary)),
                      Text('\$${carrito.subtotal.toStringAsFixed(0)}'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Envío',
                          style: TextStyle(color: AppColors.textSecondary)),
                      Text(
                        widget.negocio.costoEnvio == 0
                            ? 'Gratis'
                            : '\$${widget.negocio.costoEnvio.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: widget.negocio.costoEnvio == 0
                              ? AppColors.success
                              : AppColors.textPrimary,
                          fontWeight: widget.negocio.costoEnvio == 0
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '\$${(carrito.subtotal + widget.negocio.costoEnvio).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Dirección
            _Seccion(
              titulo: 'Dirección de entrega',
              child: TextField(
                controller: _direccionCtrl,
                decoration: const InputDecoration(
                  hintText: 'Calle, número, referencias...',
                  prefixIcon: Icon(Icons.location_on_outlined,
                      color: AppColors.textSecondary),
                ),
                maxLines: 2,
              ),
            ),
            const SizedBox(height: 16),

            // Método de pago
            _Seccion(
              titulo: 'Método de pago',
              child: Column(
                children: [
                  _MetodoPagoBtn(
                    icono: Icons.payments_outlined,
                    titulo: 'Efectivo',
                    subtitulo: 'Paga al recibir tu pedido',
                    seleccionado: _metodoPago == AppConstants.pagoEfectivo,
                    onTap: () => setState(
                        () => _metodoPago = AppConstants.pagoEfectivo),
                  ),
                  const SizedBox(height: 8),
                  _MetodoPagoBtn(
                    icono: Icons.credit_card_outlined,
                    titulo: 'MercadoPago',
                    subtitulo: 'Paga en línea de forma segura',
                    seleccionado:
                        _metodoPago == AppConstants.pagoMercadoPago,
                    onTap: () => setState(
                        () => _metodoPago = AppConstants.pagoMercadoPago),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Notas
            _Seccion(
              titulo: 'Notas (opcional)',
              child: TextField(
                controller: _notasCtrl,
                decoration: const InputDecoration(
                  hintText: 'Sin cebolla, extra salsa...',
                  prefixIcon: Icon(Icons.note_outlined,
                      color: AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _enviando ? null : _confirmarPedido,
              child: _enviando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('Confirmar pedido'),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Seccion extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _Seccion({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9ECEF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetodoPagoBtn extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final bool seleccionado;
  final VoidCallback onTap;

  const _MetodoPagoBtn({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.seleccionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: seleccionado
              ? AppColors.primary.withOpacity(0.08)
              : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: seleccionado ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(icono,
                color: seleccionado
                    ? AppColors.primary
                    : AppColors.textSecondary,
                size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    titulo,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: seleccionado
                          ? AppColors.primary
                          : AppColors.textPrimary,
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
            if (seleccionado)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}