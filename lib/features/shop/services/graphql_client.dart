import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter/material.dart';
import 'package:shop/config/graphql_config.dart';

class GraphQLService {
  // Hygraph endpoint URL from config
  static const String hygraphEndpoint = GraphQLConfig.hygraphEndpoint;

  // Create GraphQL client
  static GraphQLClient getClient() {
    final HttpLink httpLink = HttpLink(
      hygraphEndpoint,
    );

    return GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  // Create GraphQL client for use in widgets
  static ValueNotifier<GraphQLClient> clientNotifier() {
    return ValueNotifier<GraphQLClient>(getClient());
  }
}
