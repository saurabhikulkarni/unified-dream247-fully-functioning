import 'package:unified_dream247/features/shop/services/api_service.dart';

/// Backend API wrapper for address operations
/// Provides methods for all 7 address management APIs
class AddressApiService {
  
  /// POST /api/addresses - Create a new address
  /// Required: userId, fullName, phoneNumber, addressLine1, city, state, pincode, country
  /// Optional: addressLine2, isDefault
  static Future<Map<String, dynamic>> createAddress({
    required String userId,
    required String fullName,
    required String phoneNumber,
    required String addressLine1,
    String? addressLine2,
    required String city,
    required String state,
    required String pincode,
    required String country,
    bool isDefault = false,
  }) {
    return ApiService.post(
      '/api/addresses',
      body: {
        'userId': userId,
        'fullName': fullName,
        'phoneNumber': phoneNumber,
        'addressLine1': addressLine1,
        'addressLine2': addressLine2 ?? '',
        'city': city,
        'state': state,
        'pincode': pincode,
        'country': country,
        'isDefault': isDefault,
      },
    );
  }

  /// GET /api/addresses - Get all addresses for a user
  /// Params: userId
  static Future<Map<String, dynamic>> getAddresses(String userId) {
    return ApiService.get('/api/addresses?userId=$userId');
  }

  /// GET /api/addresses/{addressId} - Get a specific address
  static Future<Map<String, dynamic>> getAddress(String addressId) {
    return ApiService.get('/api/addresses/$addressId');
  }

  /// PUT /api/addresses/{addressId} - Update an address
  /// Optional fields: fullName, phoneNumber, city, state
  static Future<Map<String, dynamic>> updateAddress(
    String addressId, {
    String? fullName,
    String? phoneNumber,
    String? city,
    String? state,
  }) {
    final body = <String, dynamic>{};
    if (fullName != null) body['fullName'] = fullName;
    if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
    if (city != null) body['city'] = city;
    if (state != null) body['state'] = state;

    return ApiService.put(
      '/api/addresses/$addressId',
      body: body,
    );
  }

  /// DELETE /api/addresses/{addressId} - Delete an address
  static Future<Map<String, dynamic>> deleteAddress(String addressId) {
    return ApiService.delete('/api/addresses/$addressId');
  }

  /// POST /api/addresses/{addressId}/set-default - Set an address as default
  /// Required body: userId
  static Future<Map<String, dynamic>> setDefaultAddress(
    String addressId, {
    required String userId,
  }) {
    return ApiService.post(
      '/api/addresses/$addressId/set-default',
      body: {'userId': userId},
    );
  }

  /// GET /api/addresses/default/{userId} - Get the default address for a user
  static Future<Map<String, dynamic>> getDefaultAddress(String userId) {
    return ApiService.get('/api/addresses/default/$userId');
  }
}
