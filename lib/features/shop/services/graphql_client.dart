import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/config/graphql_config.dart';

class GraphQLService {
  // Hygraph endpoint URL from config
  static String get hygraphEndpoint => GraphQLConfig.useAuthToken 
      ? GraphQLConfig.hygraphContentApiEndpoint  // Use Content API with auth
      : GraphQLConfig.hygraphCdnEndpoint;        // Use CDN without auth

  // Create GraphQL client with optional auth
  static GraphQLClient getClient() {
    Link link;
    
    if (GraphQLConfig.useAuthToken && GraphQLConfig.hygraphAuthToken.isNotEmpty) {
      // Use auth link for mutations and draft content access
      final HttpLink httpLink = HttpLink(
        GraphQLConfig.hygraphContentApiEndpoint,
      );
      
      final AuthLink authLink = AuthLink(
        getToken: () async => 'Bearer ${GraphQLConfig.hygraphAuthToken}',
      );
      
      link = authLink.concat(httpLink);
      debugPrint('📡 [GRAPHQL] Using authenticated Content API endpoint');
    } else {
      // Use CDN for faster reads (published content only)
      link = HttpLink(GraphQLConfig.hygraphCdnEndpoint);
      debugPrint('📡 [GRAPHQL] Using CDN endpoint (no auth)');
    }

    return GraphQLClient(
      link: link,
      cache: GraphQLCache(store: InMemoryStore()),
    );
  }

  // Create GraphQL client for use in widgets
  static ValueNotifier<GraphQLClient> clientNotifier() {
    return ValueNotifier<GraphQLClient>(getClient());
  }
}
