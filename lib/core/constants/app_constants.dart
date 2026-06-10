class AppConstants {
  // Nombre de la app
  static const String appName = 'BisiFoods';
  static const String appTagline = 'Bisi = Traer • Comida local a tu puerta';

  // Roles de usuario
  static const String rolCliente = 'cliente';
  static const String rolNegocio = 'negocio';
  static const String rolRepartidor = 'repartidor';
  static const String rolAdmin = 'admin';

  // Colecciones Firestore
  static const String colUsuarios = 'usuarios';
  static const String colNegocios = 'negocios';
  static const String colProductos = 'productos';
  static const String colPedidos = 'pedidos';
  static const String colRepartidores = 'repartidores';
  static const String colResenas = 'resenas';

  // Estados del pedido
  static const String estadoPendiente = 'pendiente';
  static const String estadoAceptado = 'aceptado';
  static const String estadoPreparando = 'preparando';
  static const String estadoListo = 'listo';
  static const String estadoEnCamino = 'en_camino';
  static const String estadoEntregado = 'entregado';
  static const String estadoCancelado = 'cancelado';

  // Métodos de pago
  static const String pagoEfectivo = 'efectivo';
  static const String pagoMercadoPago = 'mercadopago';

  // Ciudad
  static const String ciudad = 'Felipe Carrillo Puerto';
  static const String estado = 'Quintana Roo';
  static const double latitudCiudad = 19.5833;
  static const double longitudCiudad = -88.0500;
}