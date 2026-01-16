
import 'package:graphql_flutter/graphql_flutter.dart';
import '../constants/api_constants.dart';
import '../services/auth_service.dart' as core_auth;

/// GraphQL client for e-commerce API (Hygraph)
/// Enhanced with unified authentication and error handling
class GraphQLClientService {
  late GraphQLClient _client;

  GraphQLClientService() {
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
        // Use unified auth service
        final authService = core_auth.AuthService();
        await authService.initialize();
        final token = authService.getAuthToken();
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
    try {
      final options = QueryOptions(
        document: gql(query),
        variables: variables ?? {},
      );

      final result = await _client.query(options);

      if (result.hasException) {
        print('❌ GraphQL Query Error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result;
    } catch (e) {
      print('❌ Query execution failed: $e');
      rethrow;
    }
  }

  /// Execute a GraphQL mutation
  Future<QueryResult> mutate(
    String mutation, {
    Map<String, dynamic>? variables,
  }) async {
    try {
      final options = MutationOptions(
        document: gql(mutation),
        variables: variables ?? {},
      );

      final result = await _client.mutate(options);

      if (result.hasException) {
        print('❌ GraphQL Mutation Error: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      return result;
    } catch (e) {
      print('❌ Mutation execution failed: $e');
      rethrow;
    }
  }

  /// Get the GraphQL client instance
  GraphQLClient get client => _client;
}
