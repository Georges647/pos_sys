import 'package:get/get.dart';
import 'package:pos/http_client/services/clients_service.dart';
import 'package:pos/http_client/services/sales_service.dart';

class ClientsController extends GetxController {
  RxList<Map<String, dynamic>> clients = <Map<String, dynamic>>[].obs;
  RxMap<String, dynamic> clientTabs = <String, dynamic>{}.obs;
  RxString selectedClientId = ''.obs;
  RxString selectedClientName = ''.obs;
  RxMap<String, dynamic> clientStats = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadClients();
  }

  void loadClients() {
    try {
      final loadedClients = ClientsService.getAllClients();
      clients.assignAll(loadedClients);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load clients: $e');
    }
  }


  void loadClientTabs(String clientId) {
    try {
      selectedClientId.value = clientId;

      final client = ClientsService.getClientById(clientId);
      if (client != null && client.isNotEmpty) {
        selectedClientName.value = client['name'] ?? 'Unknown';
      } else {
        selectedClientName.value = 'Unknown Client';
        Get.snackbar('Warning', 'Client not found');
        return;
      }

      final tabs = SalesService.getClientTabs(clientId);
      clientTabs.assignAll(tabs);

      final stats = ClientsService.getClientStats(clientId);
      clientStats.assignAll(stats);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load client tabs: $e');
    }
  }

  Future<void> deleteTab(String tabId) async {
    try {
      await SalesService.deleteTab(tabId);
      loadClientTabs(selectedClientId.value);
      Get.snackbar('Success', 'Tab deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete tab: $e');
    }
  }

  Future<void> convertTabToSale(String tabId) async {
    try {
      await SalesService.markTabAsPaid(tabId);
      loadClientTabs(selectedClientId.value);
      Get.snackbar('Success', 'Tab converted to sale');
    } catch (e) {
      Get.snackbar('Error', 'Failed to convert tab: $e');
    }
  }

  Future<void> addNewClient(String name, String phone) async {
    try {
      await ClientsService.addClient(name, phone);
      loadClients();
      Get.snackbar('Success', 'Client added successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to add client: $e');
    }
  }

  Future<void> updateClient(String clientId, String name, String phone) async {
    try {
      await ClientsService.updateClient(clientId, name, phone);
      loadClients();
      Get.snackbar('Success', 'Client updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to update client: $e');
    }
  }

  Future<void> deleteClient(String clientId) async {
    try {
      await ClientsService.deleteClient(clientId);
      loadClients();
      Get.snackbar('Success', 'Client deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete client: $e');
    }
  }

  double getClientBalance(String clientId) {
    return ClientsService.getClientBalance(clientId);
  }

  List<Map<String, dynamic>> searchClients(String query) {
    return ClientsService.searchClients(query);
  }
}