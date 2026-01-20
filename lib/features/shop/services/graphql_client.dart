import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/shop/config/graphql_config.dart';

class GraphQLService {
  static bool _isInitialized = false;
  static GraphQLClient? _client;
  
  // Hygraph endpoint URL from config
  static String get hygraphEndpoint => GraphQLConfig.useAuthToken 
      ? GraphQLConfig.hygraphContentApiEndpoint  // Use Content API with auth
      : GraphQLConfig.hygraphCdnEndpoint;        // Use CDN without auth

  // Initialize Hive for GraphQL cache persistence using graphql_flutter's method
  static Future<void> initHiveStore() async {
    if (!_isInitialized) {
      try {
        // Use graphql_flutter's built-in Hive initialization
        await initHiveForFlutter();
        _isInitialized = true;
        debugPrint('📦 [GRAPHQL] Hive initialized for persistent caching');
      } catch (e) {
        debugPrint('⚠️ [GRAPHQL] Hive initialization failed: $e');
        _isInitialized = false;
      }
    }
  }

  // Create GraphQL client with optional auth and persistent cache
  static GraphQLClient getClient() {
    // Return cached client if available
    if (_client != null) return _client!;
    
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

    // Use HiveStore if initialized, otherwise use InMemoryStore
    // This ensures the app works even if Hive isn't ready yet
    final store = _isInitialized ? HiveStore() : InMemoryStore();
    
    _client = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: store),
    );
    
    if (_isInitialized) {
      debugPrint('📦 [GRAPHQL] Using HiveStore for persistent cache');
    } else {
      debugPrint('⚠️ [GRAPHQL] Using InMemoryStore (Hive not initialized)');
    }
    
    return _client!;
  }

  // Create GraphQL client for use in widgets
  static ValueNotifier<GraphQLClient> clientNotifier() {
    return ValueNotifier<GraphQLClient>(getClient());
  }
  
  // Clear the cached client (useful for logout or reset)
  static void resetClient() {
    _client = null;
    debugPrint('🔄 [GRAPHQL] Client reset');
  }
  
  // Clear the GraphQL cache
  static Future<void> clearCache() async {
    _client?.cache.store.reset();
    debugPrint('🗑️ [GRAPHQL] Cache cleared');
  }
}
