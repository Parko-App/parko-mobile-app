class ApiInfoautos {

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://argautos.com/api/v1',
  );

  static const String brandsEndpoint = '$baseUrl/infoauto/brands?per_page=100';

  static String getBrandModels(int brandId) => '$baseUrl/infoauto/brands/$brandId/models?per_page=100';


}
