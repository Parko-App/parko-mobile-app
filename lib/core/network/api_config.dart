class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.parko.site',
  );

  static const String balanceBaseUrl = String.fromEnvironment(
    'BALANCE_API_BASE_URL',
    defaultValue: 'https://api.parko.site',
  );

  static const String userEndpoint = '$baseUrl/api/v1/user';

  /// Obtener perfil completo
  static String getUserProfile(String token, String firebaseId) => '$userEndpoint/$firebaseId';
  
  /// Obtener el saldo del usuario
  static String getBalance(String token, String firebaseId) => '$userEndpoint/$firebaseId/balance';

  /// Historial de transacciones (balance-service, el userId sale del token, no va en el path)
  static String getTransactions() => '$balanceBaseUrl/api/v1/balance/transactions';
}
