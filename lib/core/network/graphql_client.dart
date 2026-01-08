import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../constants/api_constants.dart';
import '../constants/storage_constants.dart';

/// GraphQL client for e-commerce API (Hygraph)
class GraphQLClientService {
  late GraphQLClient _client;
  final FlutterSecureStorage _secureStorage;

  GraphQLClientService(this._secureStorage) {
    _initClient();
  }

  void _initClient() {
    final httpLink = HttpLink(
      ApiConstants.hygraphEndpoint,
      defaultHeaders: {
        'Authorization': 'Bearer ${ApiConstants.hygraphApiKey}',
        'Content-Type': 'application/json',
      },
    );

    final authLink = AuthLink(
      getToken: () async {
        final token = await _secureStorage.read(key: StorageConstants.accessToken);
        return token != null ? 'Bearer $token' : null;
      },
    );

    final link = authLink.concat(httpLink);

    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(
        store: InMemoryStore(),
      ),
    );
  }

  /// Execute a GraphQL query
  Future<QueryResult> query(
    String query, {
    Map<String, dynamic>? variables,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
    );

    final result = await _client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result;
  }

  /// Execute a GraphQL mutation
  Future<QueryResult> mutate(
    String mutation, {
    Map<String, dynamic>? variables,
  }) async {
    final options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );

    final result = await _client.mutate(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    return result;
  }

  /// Get the GraphQL client instance
  GraphQLClient get client => _client;
}
