/// AddressModel represents a shipping/billing address
class AddressModel {
  final String? id;
  final String userId;
  final String fullName;
  final String phoneNumber;
  final String pincode;
  final String addressLine1;
  final String? addressLine2;
  final String city;
  final String state;
  final String country;
  final bool isDefault;

  AddressModel({
    this.id,
    required this.userId,
    required this.fullName,
    required this.phoneNumber,
    required this.pincode,
    required this.addressLine1,
    this.addressLine2,
    required this.city,
    required this.state,
    this.country = 'India',
    this.isDefault = false,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    // Handle phoneNumber as either String or Int from GraphQL
    String phoneNumberStr = '';
    if (json['phoneNumber'] != null) {
      phoneNumberStr = json['phoneNumber'].toString();
    } else if (json['phone_number'] != null) {
      phoneNumberStr = json['phone_number'].toString();
    }
    
    return AddressModel(
      id: json['id']?.toString(),
      userId: json['userId']?.toString() ?? json['userDetail']?['id']?.toString() ?? '',
      fullName: json['fullName'] ?? json['full_name'] ?? '',
      phoneNumber: phoneNumberStr,
      pincode: json['pincode'] ?? '',
      addressLine1: json['addressLine1'] ?? json['address_line1'] ?? '',
      addressLine2: json['addressLine2'] ?? json['address_line2'],
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? 'India',
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'pincode': pincode,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'country': country,
      'isDefault': isDefault,
    };
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2 != null && addressLine2!.isNotEmpty) addressLine2,
      city,
      state,
      pincode,
      country,
    ].where((part) => part != null && part.isNotEmpty).toList();
    return parts.join(', ');
  }

  AddressModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? phoneNumber,
    String? pincode,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? country,
    bool? isDefault,
  }) {
    return AddressModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pincode: pincode ?? this.pincode,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
