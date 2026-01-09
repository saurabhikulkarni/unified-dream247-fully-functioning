/// Configuration for GraphQL API (Hygraph CMS)
class GraphQLConfig {
  /// Hygraph GraphQL endpoint for ecommerce data
  static const String hygraphEndpoint =
      'https://ap-south-1.cdn.hygraph.com/content/cmj85rtgv038n07uo8egj5fkb/master';

  /// API Key for authenticated requests (if needed)
  static const String? apiKey = null;

  /// GraphQL configuration
  static Map<String, dynamic> get config => {
        'endpoint': hygraphEndpoint,
        'enableCache': true,
        'cacheSize': 10 * 1024 * 1024, // 10MB
      };
}
