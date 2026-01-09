import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:unified_dream247/features/shop/models/address_model.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';

class AddressService {
  static final AddressService _instance = AddressService._internal();

  factory AddressService() {
    return _instance;
  }

  AddressService._internal();

  final GraphQLClient _client = GraphQLService.getClient();

  // Get all addresses for the current user
  Future<List<AddressModel>> getUserAddresses() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) {
      return [];
    }

    return await getAddressesByUserId(userId);
  }

  // Get all addresses for a specific user ID
  Future<List<AddressModel>> getAddressesByUserId(String userId) async {
    try {
      print('[ADDRESS_SERVICE] Querying addresses for userId: $userId');
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getAddressesByUser),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh data
        ),
      );

      if (result.hasException) {
        print('[ADDRESS_SERVICE] Query exception: ${result.exception}');
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['addresses'] == null) {
        print('[ADDRESS_SERVICE] No addresses data in response');
        return [];
      }

      final List<dynamic> addressesJson = result.data!['addresses'] as List<dynamic>;
      print('[ADDRESS_SERVICE] Found ${addressesJson.length} addresses in query result');
      return addressesJson
          .map((json) => AddressModel.fromJson({
                ...json as Map<String, dynamic>,
                'userId': userId,
              }))
          .toList();
    } catch (e) {
      throw Exception('Error fetching addresses: $e');
    }
  }

  // Get a single address by ID
  Future<AddressModel?> getAddressById(String addressId) async {
    try {
      final QueryResult result = await _client.query(
        QueryOptions(
          document: gql(GraphQLQueries.getAddressById),
          variables: {'id': addressId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['address'] == null) {
        return null;
      }

      final json = result.data!['address'] as Map<String, dynamic>;
      // Extract userId from userDetail relation
      final userId = json['userDetail']?['id']?.toString() ?? '';
      return AddressModel.fromJson({
        ...json,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Error fetching address: $e');
    }
  }

  // Create a new address
  Future<AddressModel?> createAddress({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String pincode,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    String country = 'India',
    bool isDefault = false,
  }) async {
    try {
      // If setting as default, unset all other default addresses first
      if (isDefault) {
        await _unsetAllDefaultAddresses(userId);
      }

      // Convert phone number string to integer (strip non-numeric characters first)
      final phoneNumberInt = int.tryParse(phoneNumber.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      if (phoneNumberInt == 0) {
        throw Exception('Invalid phone number format');
      }

      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.createAddress),
          variables: {
            'userId': userId,
            'fullName': fullName,
            'phoneNumber': phoneNumberInt,
            'pincode': pincode,
            'addressLine1': addressLine1,
            'addressLine2': addressLine2,
            'city': city,
            'state': state,
            'country': country,
            'isDefault': isDefault,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['createAddress'] == null) {
        return null;
      }

      final createdAddress = result.data!['createAddress'];
      final addressId = createdAddress['id']?.toString();

      print('[ADDRESS_SERVICE] Address created with ID: $addressId');

      // Publish the address (required for Hygraph)
      if (addressId != null) {
        print('[ADDRESS_SERVICE] Publishing address...');
        await _publishAddress(addressId);
        print('[ADDRESS_SERVICE] Address published, waiting for propagation...');
        // Wait for Hygraph to propagate the published content
        await Future.delayed(const Duration(milliseconds: 1500));
        print('[ADDRESS_SERVICE] Propagation wait complete');
      }

      return AddressModel.fromJson({
        ...createdAddress as Map<String, dynamic>,
        'userId': userId,
      });
    } catch (e) {
      throw Exception('Error creating address: $e');
    }
  }

  // Update an existing address
  Future<AddressModel?> updateAddress({
    required String addressId,
    required String fullName,
    required String phoneNumber,
    required String pincode,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    String country = 'India',
    bool isDefault = false,
  }) async {
    try {
      // Get the address first to get userId
      final existingAddress = await getAddressById(addressId);
      if (existingAddress == null) {
        throw Exception('Address not found');
      }

      // If setting as default, unset all other default addresses first
      if (isDefault) {
        await _unsetAllDefaultAddresses(existingAddress.userId);
      }

      // Convert phone number string to integer (strip non-numeric characters first)
      final phoneNumberInt = int.tryParse(phoneNumber.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      if (phoneNumberInt == 0) {
        throw Exception('Invalid phone number format');
      }

      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.updateAddress),
          variables: {
            'id': addressId,
            'fullName': fullName,
            'phoneNumber': phoneNumberInt,
            'pincode': pincode,
            'addressLine1': addressLine1,
            'addressLine2': addressLine2,
            'city': city,
            'state': state,
            'country': country,
            'isDefault': isDefault,
          },
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      if (result.data == null || result.data!['updateAddress'] == null) {
        return null;
      }

      final updatedAddress = result.data!['updateAddress'];

      // Publish the address (required for Hygraph)
      await _publishAddress(addressId);

      return AddressModel.fromJson({
        ...updatedAddress as Map<String, dynamic>,
        'userId': existingAddress.userId,
      });
    } catch (e) {
      throw Exception('Error updating address: $e');
    }
  }

  // Delete an address
  Future<bool> deleteAddress(String addressId) async {
    try {
      final QueryResult result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.deleteAddress),
          variables: {'id': addressId},
        ),
      );

      if (result.hasException) {
        throw Exception(result.exception.toString());
      }

      return result.data != null && result.data!['deleteAddress'] != null;
    } catch (e) {
      throw Exception('Error deleting address: $e');
    }
  }

  // Set an address as default (unset others first)
  Future<bool> setDefaultAddress(String addressId) async {
    try {
      final address = await getAddressById(addressId);
      if (address == null) {
        return false;
      }

      // Unset all default addresses for this user
      await _unsetAllDefaultAddresses(address.userId);

      // Update this address to be default
      final updated = await updateAddress(
        addressId: addressId,
        fullName: address.fullName,
        phoneNumber: address.phoneNumber,
        pincode: address.pincode,
        addressLine1: address.addressLine1,
        addressLine2: address.addressLine2,
        city: address.city,
        state: address.state,
        country: address.country,
        isDefault: true,
      );

      return updated != null;
    } catch (e) {
      throw Exception('Error setting default address: $e');
    }
  }

  // Get the default address for a user
  Future<AddressModel?> getDefaultAddress(String userId) async {
    try {
      final addresses = await getAddressesByUserId(userId);
      return addresses.firstWhere(
        (address) => address.isDefault,
        orElse: () => addresses.isNotEmpty ? addresses.first : throw StateError('No addresses'),
      );
    } catch (e) {
      return null;
    }
  }

  // Helper: Unset all default addresses for a user
  Future<void> _unsetAllDefaultAddresses(String userId) async {
    try {
      await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.unsetAllDefaultAddresses),
          variables: {'userId': userId},
        ),
      );
    } catch (e) {
      // Silently fail - not critical
      print('Warning: Could not unset default addresses: $e');
    }
  }

  // Helper: Publish address (required for Hygraph)
  Future<void> _publishAddress(String addressId) async {
    try {
      print('[ADDRESS_SERVICE] Publishing address ID: $addressId');
      final result = await _client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.publishAddress),
          variables: {'id': addressId},
        ),
      );
      
      if (result.hasException) {
        print('[ADDRESS_SERVICE] Publish exception: ${result.exception}');
      } else {
        print('[ADDRESS_SERVICE] Publish successful');
      }
    } catch (e) {
      // Silently fail - address is still created/updated
      print('[ADDRESS_SERVICE] Warning: Could not publish address: $e');
    }
  }
}

// Singleton instance
final addressService = AddressService();
