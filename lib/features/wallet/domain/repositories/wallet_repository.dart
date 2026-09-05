abstract class WalletRepository {
  /// Obtiene la URL de Mercado Pago para iniciar la carga de saldo
  Future<String> createTopUpPreference({
    required String uuid,
    required String token,
    required double amount,
  });
}
