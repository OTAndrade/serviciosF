class AppStates {
  const AppStates._();

  static const activo = 'AC';
  static const pendiente = 'PE';

  static const elaborada = 'ELABORADA';
  static const aceptada = 'ACEPTADA';
  static const confirmada = 'CONFIRMADA';
  static const cancelada = 'CANCELADA';

  static const solicitudesActivas = [elaborada, aceptada, confirmada];
}
