class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8080',
  );

  static const String userEndpoint = '$baseUrl/api/user';

  /// Obtener perfil completo por email  ( ver con que dato lo puedo hacer)
  static String getUserProfile(String uuid) => '$baseUrl/api/user/$uuid';
  
  /// Obtener el saldo del usuario
  static String getBalance(String uuid) => '$baseUrl/api/user/$uuid/balance';
  
  // Acá podés ir agregando más:
  // static const String saldoEndpoint = '$baseUrl/api/wallet/balance';

}
