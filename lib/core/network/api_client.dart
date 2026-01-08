import 'graphql_client.dart';
import 'rest_client.dart';

/// API client that provides access to both GraphQL and REST clients
class ApiClient {
  final GraphQLClientService graphQLClient;
  final RestClient restClient;

  ApiClient({
    required this.graphQLClient,
    required this.restClient,
  });
}
