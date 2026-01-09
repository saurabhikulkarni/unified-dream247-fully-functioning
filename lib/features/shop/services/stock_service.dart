import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';
import 'package:unified_dream247/features/shop/services/notification_service.dart';

/// Service for managing product stock/inventory in Hygraph
class StockService {
  static final StockService _instance = StockService._internal();

  factory StockService() {
    return _instance;
  }

  StockService._internal();

  final GraphQLClient _client = GraphQLService.getClient();

  /// Update stock quantity for a specific size
  /// Returns true if successful, false otherwise
  Future<bool> updateSizeStock({
    required String sizeId,
    required int newQuantity,
    String? productId,
    String? productTitle,
    String? sizeName,
  }) async {
    try {
      // Get old quantity first
      final oldQuantity = await getStockQuantity(sizeId);
      
      // Update size quantity
      final MutationOptions updateOptions = MutationOptions(
        document: gql(GraphQLQueries.updateSizeQuantity),
        variables: {
          'id': sizeId,
          'quantity': newQuantity,
        },
      );

      final QueryResult updateResult = await _client.mutate(updateOptions);

      if (updateResult.hasException) {
        return false;
      }

      // Publish the size update
      final MutationOptions publishOptions = MutationOptions(
        document: gql(GraphQLQueries.publishSize),
        variables: {'id': sizeId},
      );

      final QueryResult publishResult = await _client.mutate(publishOptions);

      if (publishResult.hasException) {
        return false;
      }

      // If stock went from 0 to > 0, notify users
      if (oldQuantity != null && oldQuantity == 0 && newQuantity > 0) {
        if (productId != null && productTitle != null) {
          await notificationService.checkAndNotifyStockAvailability(
            productId: productId,
            productTitle: productTitle,
            sizeId: sizeId,
            sizeName: sizeName,
            newQuantity: newQuantity,
          );
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Reduce stock by a specific quantity
  /// Returns true if successful, false otherwise
  Future<bool> reduceStock({
    required String sizeId,
    required int quantityToReduce,
  }) async {
    try {
      // First, get current quantity
      final QueryOptions queryOptions = QueryOptions(
        document: gql(GraphQLQueries.getSizeById),
        variables: {'id': sizeId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult queryResult = await _client.query(queryOptions);

      if (queryResult.hasException) {
        return false;
      }

      if (queryResult.data == null || queryResult.data!['size'] == null) {
        return false;
      }

      final currentQuantity = queryResult.data!['size']['quantity'] as int;
      final newQuantity = currentQuantity - quantityToReduce;

      if (newQuantity < 0) {
        return false;
      }

      // Update with new quantity
      return await updateSizeStock(
        sizeId: sizeId,
        newQuantity: newQuantity,
      );
    } catch (e) {
      return false;
    }
  }

  /// Increase stock by a specific quantity (e.g., for order cancellations)
  /// Returns true if successful, false otherwise
  Future<bool> increaseStock({
    required String sizeId,
    required int quantityToAdd,
    String? productId,
    String? productTitle,
    String? sizeName,
  }) async {
    try {
      // First, get current quantity
      final QueryOptions queryOptions = QueryOptions(
        document: gql(GraphQLQueries.getSizeById),
        variables: {'id': sizeId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult queryResult = await _client.query(queryOptions);

      if (queryResult.hasException) {
        print('Error fetching size: ${queryResult.exception}');
        return false;
      }

      if (queryResult.data == null || queryResult.data!['size'] == null) {
        print('Size not found: $sizeId');
        return false;
      }

      final currentQuantity = queryResult.data!['size']['quantity'] as int;
      final newQuantity = currentQuantity + quantityToAdd;

      // Update with new quantity
      return await updateSizeStock(
        sizeId: sizeId,
        newQuantity: newQuantity,
        productId: productId,
        productTitle: productTitle,
        sizeName: sizeName,
      );
    } catch (e) {
      print('Error increasing stock: $e');
      return false;
    }
  }

  /// Get current stock for a size
  Future<int?> getStockQuantity(String sizeId) async {
    try {
      final QueryOptions queryOptions = QueryOptions(
        document: gql(GraphQLQueries.getSizeById),
        variables: {'id': sizeId},
        fetchPolicy: FetchPolicy.networkOnly,
      );

      final QueryResult queryResult = await _client.query(queryOptions);

      if (queryResult.hasException) {
        return null;
      }

      if (queryResult.data == null || queryResult.data!['size'] == null) {
        return null;
      }

      return queryResult.data!['size']['quantity'] as int;
    } catch (e) {

      return null;
    }
  }
}

// Global instance
final StockService stockService = StockService();
