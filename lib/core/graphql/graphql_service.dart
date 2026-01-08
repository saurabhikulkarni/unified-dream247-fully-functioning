import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/foundation.dart';

/// GraphQL service for Hygraph backend communication
/// Handles all GraphQL queries and mutations for ecommerce features
class GraphQLService {
  static final GraphQLService _instance = GraphQLService._internal();
  factory GraphQLService() => _instance;
  GraphQLService._internal();

  GraphQLClient? _client;
  
  /// Initialize GraphQL client with Hygraph endpoint
  void initialize(String endpoint, {String? authToken}) {
    final httpLink = HttpLink(endpoint);
    
    Link link = httpLink;
    
    if (authToken != null) {
      final authLink = AuthLink(
        getToken: () async => 'Bearer $authToken',
      );
      link = authLink.concat(httpLink);
    }
    
    _client = GraphQLClient(
      cache: GraphQLCache(store: HiveStore()),
      link: link,
    );
  }

  GraphQLClient get client {
    if (_client == null) {
      throw Exception(
        'GraphQL client not initialized. Call initialize() first.\n'
        'Example: graphQLService.initialize("https://your-endpoint.hygraph.com", authToken: "your-token");'
      );
    }
    return _client!;
  }

  /// Execute a GraphQL query
  Future<QueryResult> query({
    required String query,
    Map<String, dynamic>? variables,
    FetchPolicy? fetchPolicy,
  }) async {
    final options = QueryOptions(
      document: gql(query),
      variables: variables ?? {},
      fetchPolicy: fetchPolicy ?? FetchPolicy.cacheAndNetwork,
    );
    
    try {
      final result = await client.query(options);
      
      if (result.hasException) {
        debugPrint('GraphQL Query Error: ${result.exception}');
      }
      
      return result;
    } catch (e) {
      debugPrint('GraphQL Query Exception: $e');
      rethrow;
    }
  }

  /// Execute a GraphQL mutation
  Future<QueryResult> mutate({
    required String mutation,
    Map<String, dynamic>? variables,
  }) async {
    final options = MutationOptions(
      document: gql(mutation),
      variables: variables ?? {},
    );
    
    try {
      final result = await client.mutate(options);
      
      if (result.hasException) {
        debugPrint('GraphQL Mutation Error: ${result.exception}');
      }
      
      return result;
    } catch (e) {
      debugPrint('GraphQL Mutation Exception: $e');
      rethrow;
    }
  }

  /// Subscribe to GraphQL subscription
  Stream<QueryResult> subscribe({
    required String subscription,
    Map<String, dynamic>? variables,
  }) {
    final options = SubscriptionOptions(
      document: gql(subscription),
      variables: variables ?? {},
    );
    
    return client.subscribe(options);
  }
}

// Global instance
final graphQLService = GraphQLService();
