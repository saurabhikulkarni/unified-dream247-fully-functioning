import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:unified_dream247/features/shop/models/address_model.dart';
import 'package:unified_dream247/features/shop/services/graphql_client.dart';
import 'package:unified_dream247/features/shop/services/graphql_queries.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';

class AddressService {
  static final AddressService _instance = AddressService._internal();
  static const String _localAddressesKey = 'local_addresses';

  factory AddressService() {
    return _instance;
  }

  AddressService._internal();

  // Use public client for reads (CDN, no auth needed)
  final GraphQLClient _readClient = GraphQLService.getPublicClient();
  // Use authenticated client for mutations (create/update/delete)
  final GraphQLClient _writeClient = GraphQLService.getClient();

  // Local cache of addresses
  List<AddressModel> _localAddresses = [];
  bool _isInitialized = false;

  // Initialize local storage
  Future<void> _initializeLocalStorage() async {
    if (_isInitialized) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString(_localAddressesKey);
      if (addressesJson != null && addressesJson.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(addressesJson);
        _localAddresses = decoded
            .map((item) => AddressModel.fromJson(item as Map<String, dynamic>))
            .toList();
        print('[ADDRESS_SERVICE] Loaded ${_localAddresses.length} addresses from local storage');
      }
      _isInitialized = true;
    } catch (e) {
      print('[ADDRESS_SERVICE] Error loading local addresses: $e');
      _localAddresses = [];
      _isInitialized = true;
    }
  }

  // Save addresses to local storage
  Future<void> _saveToLocalStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = jsonEncode(
        _localAddresses.map((a) => {
          ...a.toJson(),
          'userId': a.userId,
        },).toList(),
      );
      await prefs.setString(_localAddressesKey, addressesJson);
      print('[ADDRESS_SERVICE] Saved ${_localAddresses.length} addresses to local storage');
    } catch (e) {
      print('[ADDRESS_SERVICE] Error saving local addresses: $e');
    }
  }

  // Get all addresses for the current user
  Future<List<AddressModel>> getUserAddresses() async {
    final userId = UserService.getCurrentUserId();
    if (userId == null) {
      return [];
    }

    return await getAddressesByUserId(userId);
  }

  // Get all addresses for a specific user ID (combines backend + local addresses)
  Future<List<AddressModel>> getAddressesByUserId(String userId) async {
    await _initializeLocalStorage();
    
    List<AddressModel> backendAddresses = [];
    
    try {
      print('[ADDRESS_SERVICE] Querying addresses for userId: $userId');
      final QueryResult result = await _readClient.query(
        QueryOptions(
          document: gql(GraphQLQueries.getAddressesByUser),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly, // Always fetch fresh data
        ),
      );

      if (result.hasException) {
        print('[ADDRESS_SERVICE] Query exception: ${result.exception}');
        // Fall through to return local addresses
      } else if (result.data != null && result.data!['addresses'] != null) {
        final List<dynamic> addressesJson = result.data!['addresses'] as List<dynamic>;
        print('[ADDRESS_SERVICE] Found ${addressesJson.length} addresses from backend');
        backendAddresses = addressesJson
            .map((json) => AddressModel.fromJson({
                  ...json as Map<String, dynamic>,
                  'userId': userId,
                }),)
            .toList();
      }
    } catch (e) {
      print('[ADDRESS_SERVICE] Error fetching backend addresses: $e');
    }

    // Get local addresses for this user
    final localUserAddresses = _localAddresses.where((a) => a.userId == userId).toList();
    print('[ADDRESS_SERVICE] Found ${localUserAddresses.length} local addresses');

    // Merge: backend addresses + local addresses (avoiding duplicates by ID)
    final backendIds = backendAddresses.map((a) => a.id).toSet();
    final uniqueLocalAddresses = localUserAddresses.where((a) => !backendIds.contains(a.id)).toList();
    
    final allAddresses = [...backendAddresses, ...uniqueLocalAddresses];
    print('[ADDRESS_SERVICE] Total addresses: ${allAddresses.length}');
    
    return allAddresses;
  }

  // Get a single address by ID (checks both backend and local)
  Future<AddressModel?> getAddressById(String addressId) async {
    await _initializeLocalStorage();
    
    // First check local addresses
    final localMatch = _localAddresses.where((a) => a.id == addressId).firstOrNull;
    if (localMatch != null) {
      return localMatch;
    }
    
    try {
      final QueryResult result = await _readClient.query(
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

  // Create a new address (tries Hygraph first, falls back to local storage)
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
    await _initializeLocalStorage();
    
    // If setting as default, unset all other default addresses first (local)
    if (isDefault) {
      for (var i = 0; i < _localAddresses.length; i++) {
        if (_localAddresses[i].userId == userId && _localAddresses[i].isDefault) {
          _localAddresses[i] = _localAddresses[i].copyWith(isDefault: false);
        }
      }
    }

    // Convert phone number string (strip non-numeric characters)
    final phoneNumberClean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    if (phoneNumberClean.isEmpty) {
      throw Exception('Invalid phone number format');
    }

    // Try Hygraph first
    try {
      if (isDefault) {
        await _unsetAllDefaultAddresses(userId);
      }

      final phoneNumberInt = int.tryParse(phoneNumberClean) ?? 0;
      
      final QueryResult result = await _writeClient.mutate(
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
        throw Exception('No data returned from createAddress');
      }

      final createdAddress = result.data!['createAddress'];
      final addressId = createdAddress['id']?.toString();

      print('[ADDRESS_SERVICE] Address created on Hygraph with ID: $addressId');

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
      // Hygraph failed - fall back to local storage
      print('[ADDRESS_SERVICE] Hygraph mutation failed, saving locally: $e');
      
      // Generate a local ID
      final localId = 'local_${DateTime.now().millisecondsSinceEpoch}';
      
      final localAddress = AddressModel(
        id: localId,
        userId: userId,
        fullName: fullName,
        phoneNumber: phoneNumberClean,
        pincode: pincode,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        isDefault: isDefault,
      );
      
      _localAddresses.add(localAddress);
      await _saveToLocalStorage();
      
      print('[ADDRESS_SERVICE] Address saved locally with ID: $localId');
      return localAddress;
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
    await _initializeLocalStorage();
    
    // Check if this is a local address
    final localIndex = _localAddresses.indexWhere((a) => a.id == addressId);
    if (localIndex >= 0 || addressId.startsWith('local_')) {
      // Update local address
      print('[ADDRESS_SERVICE] Updating local address: $addressId');
      
      final phoneNumberClean = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
      
      // If setting as default, unset all other defaults
      if (isDefault) {
        for (var i = 0; i < _localAddresses.length; i++) {
          if (_localAddresses[i].isDefault) {
            _localAddresses[i] = _localAddresses[i].copyWith(isDefault: false);
          }
        }
      }
      
      final updatedAddress = AddressModel(
        id: addressId,
        userId: localIndex >= 0 ? _localAddresses[localIndex].userId : UserService.getCurrentUserId() ?? '',
        fullName: fullName,
        phoneNumber: phoneNumberClean,
        pincode: pincode,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        state: state,
        country: country,
        isDefault: isDefault,
      );
      
      if (localIndex >= 0) {
        _localAddresses[localIndex] = updatedAddress;
      } else {
        _localAddresses.add(updatedAddress);
      }
      
      await _saveToLocalStorage();
      return updatedAddress;
    }
    
    // Try Hygraph for non-local addresses
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

      final QueryResult result = await _writeClient.mutate(
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

  // Delete an address (handles both local and Hygraph addresses)
  Future<bool> deleteAddress(String addressId) async {
    await _initializeLocalStorage();
    
    // Check if this is a local address
    final localIndex = _localAddresses.indexWhere((a) => a.id == addressId);
    if (localIndex >= 0 || addressId.startsWith('local_')) {
      print('[ADDRESS_SERVICE] Deleting local address: $addressId');
      _localAddresses.removeWhere((a) => a.id == addressId);
      await _saveToLocalStorage();
      return true;
    }
    
    // Try Hygraph for non-local addresses
    try {
      final QueryResult result = await _writeClient.mutate(
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
      // If Hygraph fails, still remove from local cache if present
      print('[ADDRESS_SERVICE] Hygraph delete failed, removing from local cache: $e');
      _localAddresses.removeWhere((a) => a.id == addressId);
      await _saveToLocalStorage();
      return true;
    }
  }

  // Set an address as default (unset others first)
  Future<bool> setDefaultAddress(String addressId) async {
    await _initializeLocalStorage();
    
    try {
      final address = await getAddressById(addressId);
      if (address == null) {
        return false;
      }

      // Unset all local default addresses
      for (var i = 0; i < _localAddresses.length; i++) {
        if (_localAddresses[i].isDefault) {
          _localAddresses[i] = _localAddresses[i].copyWith(isDefault: false);
        }
      }
      
      // Try to unset on backend
      try {
        await _unsetAllDefaultAddresses(address.userId);
      } catch (e) {
        print('[ADDRESS_SERVICE] Could not unset defaults on backend: $e');
      }

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
      await _writeClient.mutate(
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
      final result = await _writeClient.mutate(
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
