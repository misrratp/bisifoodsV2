import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/services/auth_provider.dart';
import '../../../data/services/negocio_provider.dart';

class RegistroNegocioScreen extends StatefulWidget {
  const RegistroNegocioScreen({super.key});

  @override
  State<RegistroNegocioScreen> createState() => _RegistroNegocioScreenState();
}

class _RegistroNegocioScreenState extends State<RegistroNegocioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _costoEnvioCtrl = TextEditingController(text: '0');
  String _categoriaSeleccionada = 'Lonchería';
  String _tiempoEntrega = '20-30 min';

  final List<String> _categorias = [
    'Lonchería', 'Antojitos', 'Mariscos', 'Dulces', 'Bebidas', 'Otros'
  ];
  final List<String> _tiempos = [
    '10-20 min', '20-30 min', '30-40 min', '40-60 min'
  ];

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _costoEnvioCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final provider = context.read<NegocioProvider>();
    final ok = await provider.crearNegocio(
      nombre: _nombreCtrl.text.trim(),
      descripcion: _descripcionCtrl.text.trim(),
      categoria: _categoriaSeleccionada,
      telefono: _telefonoCtrl.text.trim(),
      direccion: _direccionCtrl.text.trim(),
      propietarioId: auth.usuario!.uid,
      costoEnvio: double.tryParse(_costoEnvioCtrl.text) ?? 0,
      tiempoEntrega: _tiempoEntrega,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al registrar negocio'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NegocioProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Center(
                  child: Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.store_outlined,
                        color: AppColors.primary, size: 36),
                  ),
                ),
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Registra tu negocio',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const Center(
                  child: Text(
                    'Empieza a recibir pedidos hoy',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                _label('Nombre del negocio'),
                TextFormField(
                  controller: _nombreCtrl,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'Ej: Lonchería Doña Mary',
                    prefixIcon: Icon(Icons.store_outlined,
                        color: AppColors.textSecondary),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                _label('Descripción'),
                TextFormField(
                  controller: _descripcionCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Describe tu negocio y especialidades...',
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                _label('Categoría'),
                DropdownButtonFormField<String>(
                  value: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.category_outlined,
                        color: AppColors.textSecondary),
                  ),
                  items: _categorias
                      .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                      .toList(),
                  onChanged: (v) =>
                      setState(() => _categoriaSeleccionada = v!),
                ),
                const SizedBox(height: 16),

                _label('Teléfono'),
                TextFormField(
                  controller: _telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '983 XXX XXXX',
                    prefixIcon: Icon(Icons.phone_outlined,
                        color: AppColors.textSecondary),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                _label('Dirección'),
                TextFormField(
                  controller: _direccionCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Calle y número, colonia',
                    prefixIcon: Icon(Icons.location_on_outlined,
                        color: AppColors.textSecondary),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Campo requerido' : null,
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Costo de envío (\$)'),
                          TextFormField(
                            controller: _costoEnvioCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              hintText: '0',
                              prefixIcon: Icon(Icons.delivery_dining,
                                  color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _label('Tiempo de entrega'),
                          DropdownButtonFormField<String>(
                            value: _tiempoEntrega,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.access_time,
                                  color: AppColors.textSecondary),
                            ),
                            items: _tiempos
                                .map((t) =>
                                    DropdownMenuItem(value: t, child: Text(t)))
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _tiempoEntrega = v!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: provider.cargando ? null : _registrar,
                  child: provider.cargando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text('Registrar mi negocio'),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}