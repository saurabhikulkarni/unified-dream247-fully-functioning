import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/address_model.dart';
import 'package:unified_dream247/features/shop/services/address_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<AddressModel> addresses = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userId = UserService.getCurrentUserId();
      if (userId == null) {
        setState(() {
          addresses = [];
          _isLoading = false;
          _errorMessage = 'Please login to view your addresses';
        });
        return;
      }

      print('[ADDRESSES_SCREEN] Fetching addresses for user: $userId');
      final fetchedAddresses = await addressService.getAddressesByUserId(userId);
      print('[ADDRESSES_SCREEN] Fetched ${fetchedAddresses.length} addresses from service');
      
      if (mounted) {
        setState(() {
          addresses = fetchedAddresses;
          _isLoading = false;
          _errorMessage = null;
        });
        print('[ADDRESSES_SCREEN] Updated UI with ${addresses.length} addresses');
      } else {
        print('[ADDRESSES_SCREEN] Widget not mounted, skipping setState');
      }
    } catch (e) {
      print('[ADDRESSES_SCREEN] Error loading addresses: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load addresses: ${e.toString()}';
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_errorMessage ?? 'Failed to load addresses'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _setDefaultAddress(String addressId) async {
    try {
      final success = await addressService.setDefaultAddress(addressId);
      if (success) {
        await _loadAddresses(); // Reload to reflect changes
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Default address updated"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to update default address');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update default address: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _deleteAddress(String addressId) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Address'),
        content: const Text('Are you sure you want to delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final success = await addressService.deleteAddress(addressId);
      if (success) {
        await _loadAddresses(); // Reload to reflect changes
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Address deleted"),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to delete address');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to delete address: ${e.toString()}"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Addresses"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.push('/shop/add-address');
              if (result != null && result is Map && result['success'] == true) {
                // Add small delay to ensure Hygraph has published the address
                await Future.delayed(const Duration(milliseconds: 500));
                _loadAddresses(); // Reload addresses from GraphQL
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 80,
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(height: defaultPadding),
                      Text(
                        _errorMessage!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: defaultPadding),
                      ElevatedButton(
                        onPressed: _loadAddresses,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
          : addresses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 80,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: defaultPadding),
                      Text(
                        "No addresses saved",
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: defaultPadding / 2),
                      Text(
                        "Tap the + button to add a new address",
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(defaultPadding),
                  itemCount: addresses.length,
                  itemBuilder: (context, index) {
                    final address = addresses[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: defaultPadding),
                  child: Padding(
                    padding: const EdgeInsets.all(defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                address.fullName,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (address.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      "Default",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: primaryColor,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.edit_outlined, size: 20),
                                  onPressed: () {
                                    context.push('/shop/add-address', extra: {
                                      'addressId': address.id,
                                      'fullName': address.fullName,
                                      'phoneNumber': address.phoneNumber,
                                      'addressLine1': address.addressLine1,
                                      'addressLine2': address.addressLine2,
                                      'pincode': address.pincode,
                                      'city': address.city,
                                      'state': address.state,
                                      'country': address.country,
                                    }).then((result) {
                                      if (result != null && result is Map && result['success'] == true) {
                                        _loadAddresses();
                                      }
                                    });
                                  },
                                  tooltip: 'Edit Address',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
                                  onPressed: address.id != null ? () => _deleteAddress(address.id!) : null,
                                  tooltip: 'Delete Address',
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: defaultPadding / 2),
                        Text(
                          '${address.addressLine1}${address.addressLine2 != null && address.addressLine2!.isNotEmpty ? ", ${address.addressLine2}" : ""}, ${address.city}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (address.phoneNumber.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              'Phone: ${address.phoneNumber}',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                            ),
                          ),
                        if (!address.isDefault && address.id != null) ...[
                          const SizedBox(height: defaultPadding / 2),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: () => _setDefaultAddress(address.id!),
                              icon: const Icon(Icons.check_circle_outline, size: 16),
                              label: const Text("Set as Default"),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
