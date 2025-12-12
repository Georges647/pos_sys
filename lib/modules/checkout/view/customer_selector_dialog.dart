import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/modules/clients/controller/clients_controller.dart';

class CustomerSelectorDialog extends StatefulWidget {
  const CustomerSelectorDialog({super.key});

  @override
  State<CustomerSelectorDialog> createState() => _CustomerSelectorDialogState();
}

class _CustomerSelectorDialogState extends State<CustomerSelectorDialog> {
  final TextEditingController _searchController = TextEditingController();
  final ClientsController _clientsController = Get.find<ClientsController>();
  final RxList<Map<String, dynamic>> _searchResults = <Map<String, dynamic>>[].obs;
  final RxBool _isSearching = false.obs;

  @override
  void initState() {
    super.initState();
    // Load all clients initially
    _searchResults.assignAll(_clientsController.clients);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  void _searchClients(String query) {
    if (query.isEmpty) {
      // Load all clients with their balances

      final clientsWithBalance = _clientsController.clients.map((client) {
        // Add safety check for empty client
        if (client.isEmpty) {
          return <String, dynamic>{'id': '', 'name': 'Invalid Client', 'balance': 0.0};
        }
        
        final clientWithBalance = Map<String, dynamic>.from(client);
        final clientId = client['id'] as String? ?? '';
        clientWithBalance['balance'] = _clientsController.getClientBalance(clientId);
        return clientWithBalance;
      }).toList();
      _searchResults.assignAll(clientsWithBalance);
      return;
    }

    _isSearching.value = true;
    // Use a small delay to avoid too many search requests
    Future.delayed(const Duration(milliseconds: 300), () {
      final results = _clientsController.searchClients(query);

      // Add balance information to search results
      final resultsWithBalance = results.map((client) {
        // Add safety check for empty client
        if (client.isEmpty) {
          return <String, dynamic>{'id': '', 'name': 'Invalid Client', 'balance': 0.0};
        }
        
        final clientWithBalance = Map<String, dynamic>.from(client);
        final clientId = client['id'] as String? ?? '';
        clientWithBalance['balance'] = _clientsController.getClientBalance(clientId);
        return clientWithBalance;
      }).toList();
      _searchResults.assignAll(resultsWithBalance);
      _isSearching.value = false;
    });
  }

  void _showAddClientDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('Add New Client'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Client Name',
                hintText: 'Enter client name',
              ),
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: 'Enter phone number',
              ),
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = nameController.text.trim();
              final phone = phoneController.text.trim();

              if (name.isEmpty) {
                Get.snackbar('Error', 'Please enter client name');
                return;
              }

              try {
                await _clientsController.addNewClient(name, phone);
                Get.back(); // Close add client dialog
                
                // Refresh search results to include the new client
                _searchClients(_searchController.text);
                
                Get.snackbar('Success', 'Client added successfully');
              } catch (e) {
                Get.snackbar('Error', 'Failed to add client: $e');
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: double.maxFinite,
        constraints: const BoxConstraints(maxHeight: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Select Customer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Get.back(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(),
            
            // Search Field
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search customers',
                  hintText: 'Search by name or phone',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(),
                ),
                onChanged: _searchClients,
                textInputAction: TextInputAction.search,
              ),
            ),
            
            // Results
            Obx(() {
              if (_isSearching.value) {
                return const Padding(
                  padding: EdgeInsets.all(32.0),
                  child: CircularProgressIndicator(),
                );
              }

              if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
                // No results found - show add new client option
                return Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_add,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No customer found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Add a new customer',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddClientDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Add New Customer'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Show results list
              return Expanded(

                child: ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final client = _searchResults[index];
                    

                    // Add safety check for empty client
                    if (client.isEmpty) {
                      return const ListTile(
                        title: Text('Invalid Client Data'),
                        subtitle: Text('Client information is missing'),
                      );
                    }
                    
                    final clientName = client['name'] as String? ?? 'Unknown';
                    final clientPhone = client['phone'] as String? ?? '';
                    final clientBalance = client['balance'] as double? ?? 0.0;
                    final clientId = client['id'] as String? ?? '';

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          clientName.isNotEmpty ? clientName[0].toUpperCase() : '?',
                        ),
                      ),
                      title: Text(clientName),
                      subtitle: clientPhone.isNotEmpty 
                          ? Text(clientPhone) 
                          : null,
                      trailing: clientBalance > 0 
                          ? Text(
                              '\$${clientBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            )
                          : null,
                      onTap: () {
                        // Close dialog and pass client data
                        Get.back(result: {
                          'id': clientId,
                          'name': clientName,
                          'phone': clientPhone,
                        });
                      },
                    );
                  },
                ),
              );
            }),
            
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
