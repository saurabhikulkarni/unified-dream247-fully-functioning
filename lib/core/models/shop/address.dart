/// Address model for delivery addresses
class Address {
  final String id;
  final String name;
  final String phone;
  final String addressLine1;
  final String addressLine2;
  final String city;
  final String state;
  final String pincode;
  final String country;
  final bool isDefault;
  final String? landmark;
  final AddressType type;

  Address({
    required this.id,
    required this.name,
    required this.phone,
    required this.addressLine1,
    required this.addressLine2,
    required this.city,
    required this.state,
    required this.pincode,
    required this.country,
    required this.isDefault,
    this.landmark,
    required this.type,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String? ?? '',
      city: json['city'] as String,
      state: json['state'] as String,
      pincode: json['pincode'] as String,
      country: json['country'] as String? ?? 'India',
      isDefault: json['isDefault'] as bool? ?? false,
      landmark: json['landmark'] as String?,
      type: AddressType.fromString(json['type'] as String? ?? 'home'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'state': state,
      'pincode': pincode,
      'country': country,
      'isDefault': isDefault,
      'landmark': landmark,
      'type': type.value,
    };
  }

  String get fullAddress {
    final parts = [
      addressLine1,
      if (addressLine2.isNotEmpty) addressLine2,
      if (landmark != null && landmark!.isNotEmpty) landmark,
      city,
      state,
      pincode,
      country,
    ];
    return parts.join(', ');
  }

  Address copyWith({
    String? id,
    String? name,
    String? phone,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? state,
    String? pincode,
    String? country,
    bool? isDefault,
    String? landmark,
    AddressType? type,
  }) {
    return Address(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      addressLine1: addressLine1 ?? this.addressLine1,
      addressLine2: addressLine2 ?? this.addressLine2,
      city: city ?? this.city,
      state: state ?? this.state,
      pincode: pincode ?? this.pincode,
      country: country ?? this.country,
      isDefault: isDefault ?? this.isDefault,
      landmark: landmark ?? this.landmark,
      type: type ?? this.type,
    );
  }
}

enum AddressType {
  home,
  office,
  other;

  String get value {
    switch (this) {
      case AddressType.home:
        return 'home';
      case AddressType.office:
        return 'office';
      case AddressType.other:
        return 'other';
    }
  }

  String get displayName {
    switch (this) {
      case AddressType.home:
        return 'Home';
      case AddressType.office:
        return 'Office';
      case AddressType.other:
        return 'Other';
    }
  }

  static AddressType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'home':
        return AddressType.home;
      case 'office':
        return AddressType.office;
      default:
        return AddressType.other;
    }
  }
}
