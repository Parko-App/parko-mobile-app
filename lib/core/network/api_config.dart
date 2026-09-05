class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  ); // 10.0.2.2 para emulador

  static const String balanceBaseUrl = String.fromEnvironment(
    'BALANCE_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8082',
  );

  static const String userEndpoint = '$baseUrl/api/v1/user';

  /// Obtener perfil completo
  static String getUserProfile(String token, String firebaseId) => '$userEndpoint/$firebaseId';
  
  /// Obtener el saldo del usuario
  static String getBalance(String token, String firebaseId) => '$userEndpoint/$firebaseId/balance';

  /// Historial de transacciones
  static String getTransactions(String userId) => '$baseUrl/api/v1/transactions/$userId';
}
