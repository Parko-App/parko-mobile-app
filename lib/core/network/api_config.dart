class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    //defaultValue: 'https://api.parko.site',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String balanceBaseUrl = String.fromEnvironment(
    'BALANCE_API_BASE_URL',
    //defaultValue: 'https://api.parko.site',
    defaultValue: 'http://10.0.2.2:8082',
  );

  static const String accessBaseUrl = String.fromEnvironment(
    'ACCESS_API_BASE_URL',
    //defaultValue: 'https://api.parko.site',
    defaultValue: 'http://10.0.2.2:8081',
  );

  static const String userEndpoint = '$baseUrl/api/v1/user';

  /// Obtener perfil completo
  static String getUserProfile(String token, String firebaseId) => '$userEndpoint/$firebaseId';
  
  /// Obtener el saldo del usuario
  static String getBalance(String token, String firebaseId) => '$userEndpoint/$firebaseId/balance';

  /// Historial de transacciones (balance-service, el userId sale del token, no va en el path)
  static String getTransactions() => '$balanceBaseUrl/api/v1/balance/transactions';

  /// Ocupación REST Snapshot (access-service)
  static String getOccupancySnapshot() => '$accessBaseUrl/api/v1/access/occupancy';

  /// Ocupación SSE Stream (access-service)
  static String getOccupancyStream() => '$accessBaseUrl/api/v1/access/occupancy/stream';
}
