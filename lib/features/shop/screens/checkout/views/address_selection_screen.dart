import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/address_model.dart';
import 'package:unified_dream247/features/shop/services/address_service.dart';
import 'package:unified_dream247/features/shop/services/user_service.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';

class AddressSelectionScreen extends StatefulWidget {
  const AddressSelectionScreen({super.key});

  @override
  State<AddressSelectionScreen> createState() => _AddressSelectionScreenState();
}

class _AddressSelectionScreenState extends State<AddressSelectionScreen> {
  List<AddressModel> addresses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _selectedAddressId;

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
          _errorMessage = 'Please login to select an address';
        });
        return;
      }

      final fetchedAddresses = await addressService.getAddressesByUserId(userId);
      setState(() {
        addresses = fetchedAddresses;
        _isLoading = false;
        // Auto-select default address if available, otherwise select first address
        if (addresses.isNotEmpty) {
          try {
            final defaultAddress = addresses.firstWhere((addr) => addr.isDefault);
            _selectedAddressId = defaultAddress.id;
          } catch (e) {
            // No default address found, select first address
            _selectedAddressId = addresses.first.id;
          }
        }
      });
    } catch (e) {
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

  void _proceedWithSelectedAddress() {
    if (_selectedAddressId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Return selected address ID
    Navigator.pop(context, _selectedAddressId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Delivery Address'),
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
                            "Add an address to continue",
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: defaultPadding * 2),
                          ElevatedButton.icon(
                            onPressed: () async {
                              final result = await context.push<Map>(
                                '/shop/add-address',
                              );
                              if (result != null && result is Map && result['success'] == true) {
                                _loadAddresses();
                              }
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Add Address'),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(defaultPadding),
                            itemCount: addresses.length,
                            itemBuilder: (context, index) {
                              final address = addresses[index];
                              final isSelected = _selectedAddressId == address.id;
                              return Card(
                                margin: const EdgeInsets.only(bottom: defaultPadding),
                                color: isSelected
                                    ? primaryColor.withOpacity(0.1)
                                    : null,
                                elevation: isSelected ? 4 : 1,
                                child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      _selectedAddressId = address.id;
                                    });
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(defaultPadding),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Radio button
                                        Radio<String>(
                                          value: address.id ?? '',
                                          groupValue: _selectedAddressId,
                                          onChanged: (value) {
                                            setState(() {
                                              _selectedAddressId = value;
                                            });
                                          },
                                        ),
                                        const SizedBox(width: defaultPadding / 2),
                                        // Address details
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      address.fullName,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .titleSmall
                                                          ?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                    ),
                                                  ),
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
                                                          fontWeight: FontWeight.w600,
                                                        ),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: defaultPadding / 4),
                                              Text(
                                                address.fullAddress,
                                                style: Theme.of(context).textTheme.bodyMedium,
                                              ),
                                              if (address.phoneNumber.isNotEmpty)
                                                Padding(
                                                  padding: const EdgeInsets.only(top: 4),
                                                  child: Text(
                                                    'Phone: ${address.phoneNumber}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: Colors.grey[600],
                                                        ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        // Add new address button
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: defaultPadding,
                            vertical: defaultPadding / 2,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 10,
                                offset: const Offset(0, -5),
                              ),
                            ],
                          ),
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final result = await context.push<Map>(
                                '/shop/add-address',
                              );
                              if (result != null && result is Map && result['success'] == true) {
                                _loadAddresses();
                              }
                            },
                            icon: const Icon(Icons.add_location_alt),
                            label: const Text('Add New Address'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
      bottomNavigationBar: addresses.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(defaultPadding),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _proceedWithSelectedAddress,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Proceed with Selected Address'),
                ),
              ),
            )
          : null,
    );
  }
}

