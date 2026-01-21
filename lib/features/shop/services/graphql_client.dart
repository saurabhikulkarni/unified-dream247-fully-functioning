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
      debugPrint('📡 [GRAPHQL] Endpoint: ${GraphQLConfig.hygraphContentApiEndpoint}');
    } else {
      // Use CDN for faster reads (published content only)
      link = HttpLink(GraphQLConfig.hygraphCdnEndpoint);
      debugPrint('📡 [GRAPHQL] Using CDN endpoint (no auth)');
      debugPrint('📡 [GRAPHQL] Endpoint: ${GraphQLConfig.hygraphCdnEndpoint}');
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
    _publicClient = null;
    debugPrint('🔄 [GRAPHQL] Client reset');
  }
  
  // Public client for read-only operations (uses CDN, no auth required)
  static GraphQLClient? _publicClient;
  
  /// Get a public GraphQL client that uses CDN endpoint
  /// This is for READ-ONLY operations like fetching products
  /// No authentication token is needed - works even if token is invalid
  static GraphQLClient getPublicClient() {
    if (_publicClient != null) return _publicClient!;
    
    // Always use CDN endpoint for public reads (no auth)
    final link = HttpLink(GraphQLConfig.hygraphCdnEndpoint);
    debugPrint('📡 [GRAPHQL] Creating public CDN client (no auth)');
    debugPrint('📡 [GRAPHQL] CDN Endpoint: ${GraphQLConfig.hygraphCdnEndpoint}');
    
    final store = _isInitialized ? HiveStore() : InMemoryStore();
    
    _publicClient = GraphQLClient(
      link: link,
      cache: GraphQLCache(store: store),
    );
    
    return _publicClient!;
  }
  
  // Clear the GraphQL cache
  static Future<void> clearCache() async {
    _client?.cache.store.reset();
    debugPrint('🗑️ [GRAPHQL] Cache cleared');
  }
}
