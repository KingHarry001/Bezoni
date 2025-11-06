// File: lib/screens/profile/screens/addresses_screen.dart
import 'package:flutter/material.dart';
import '../../../themes/theme_extensions.dart';
import '../../../models/address.dart';
import '../widgets/profile_modals.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Address> addresses = [
    Address(
      id: '1',
      label: 'Home',
      address: '123 Main Street, Victoria Island, Lagos',
      isDefault: true,
    ),
    Address(
      id: '2',
      label: 'Work',
      address: '456 Business District, Ikoyi, Lagos',
      isDefault: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        backgroundColor: context.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Addresses',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: context.textColor,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: context.primaryColor),
            onPressed: () => _showAddAddressModal(context),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: addresses.length,
        itemBuilder: (context, index) {
          final address = addresses[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(12),
              border: address.isDefault
                  ? Border.all(color: context.primaryColor, width: 2)
                  : null,
              boxShadow: ThemeUtils.createShadow(context, elevation: 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: address.isDefault
                            ? context.primaryColor
                            : context.colors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        address.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: address.isDefault
                              ? Colors.white
                              : context.subtitleColor,
                        ),
                      ),
                    ),
                    if (address.isDefault) ...[
                      const SizedBox(width: 8),
                      Icon(
                        Icons.check_circle,
                        size: 16,
                        color: context.primaryColor,
                      ),
                      Text(
                        'Default',
                        style: TextStyle(
                          fontSize: 12,
                          color: context.primaryColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const Spacer(),
                    PopupMenuButton<String>(
                      onSelected: (value) =>
                          _handleAddressAction(value, address),
                      itemBuilder: (context) => [
                        if (!address.isDefault)
                          const PopupMenuItem(
                            value: 'set_default',
                            child: Text('Set as Default'),
                          ),
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        color: context.subtitleColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  address.address,
                  style: TextStyle(
                    fontSize: 14,
                    color: context.subtitleColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddAddressModal(context),
        backgroundColor: context.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _handleAddressAction(String action, Address address) {
    switch (action) {
      case 'set_default':
        setState(() {
          for (var addr in addresses) {
            addr.isDefault = addr.id == address.id;
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Default address updated'),
            backgroundColor: context.successColor,
          ),
        );
        break;
      case 'edit':
        _showEditAddressModal(context, address);
        break;
      case 'delete':
        _showDeleteConfirmation(context, address);
        break;
    }
  }

  void _showAddAddressModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAddressModal(
        onAddAddress: (address) {
          setState(() {
            addresses.add(address); // FIXED: was 'addres'
          });
        },
      ),
    );
  }

  void _showEditAddressModal(BuildContext context, Address address) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAddressModal(
        address: address,
        onAddAddress: (editedAddress) {
          setState(() {
            final index = addresses.indexWhere((a) => a.id == address.id);
            if (index != -1) {
              addresses[index] = editedAddress;
            }
          });
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Address address) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.surfaceColor,
        title: Text('Delete Address', style: TextStyle(color: context.textColor)),
        content: Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(color: context.subtitleColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: context.subtitleColor)),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                addresses.removeWhere((a) => a.id == address.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Address deleted'),
                  backgroundColor: context.successColor,
                ),
              );
            },
            child: Text('Delete', style: TextStyle(color: context.errorColor)),
          ),
        ],
      ),
    );
  }
}