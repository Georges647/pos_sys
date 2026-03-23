import 'package:flutter/widgets.dart';
import 'package:pos/http_client/local_storage/hive_service.dart';
import 'package:pos/http_client/services/sales_service.dart';

class ClientsService {

  static List<Map<String, dynamic>> getAllClients() {
    try {
      final clients = HiveService.getValue('clients') ?? [];
      return List<Map<String, dynamic>>.from(clients);
    } catch (e) {
      debugPrint('Error getting clients: $e');
      return [];
    }
  }



  static Map<String, dynamic>? getClientById(String clientId) {
    try {
      final clients = getAllClients();
      final client = clients.firstWhere(
        (client) => client['id'] == clientId,
        orElse: () => <String, dynamic>{},
      );
      
      if (client.isEmpty) {
        return null;
      }
      
      return client;
    } catch (e) {
      debugPrint('Error getting client: $e');
      return null;
    }
  }

  static Future<void> addClient(String name, String phone) async {
    try {
      final newClient = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': name,
        'phone': phone,
        'createdDate': DateTime.now().toString(),
        'status': 'active',
      };

      final clients = getAllClients();
      clients.add(newClient);

      await HiveService.setValue('clients', clients);
    } catch (e) {
      debugPrint('Error adding client: $e');
      rethrow;
    }
  }

  static Future<void> updateClient(
    String clientId,
    String name,
    String phone,
  ) async {
    try {
      final clients = getAllClients();
      final index = clients.indexWhere((client) => client['id'] == clientId);

      if (index != -1) {
        clients[index] = {
          ...clients[index],
          'name': name,
          'phone': phone,
          'updatedDate': DateTime.now().toString(),
        };

        await HiveService.setValue('clients', clients);
      }
    } catch (e) {
      debugPrint('Error updating client: $e');
      rethrow;
    }
  }

  static Future<void> deleteClient(String clientId) async {
    try {
      final clients = getAllClients();
      clients.removeWhere((client) => client['id'] == clientId);

      await HiveService.setValue('clients', clients);
    } catch (e) {
      debugPrint('Error deleting client: $e');
      rethrow;
    }
  }

  static double getClientBalance(String clientId) {
    try {
      final tabsMap = SalesService.getClientTabs(clientId);
      double totalBalance = 0.0;

      for (var tabData in tabsMap.values) {
        if (tabData is Map<String, dynamic> && tabData['status'] == 'open') {
          totalBalance += (tabData['totalUSD'] ?? 0.0) as double;
        }
      }
      return totalBalance;
    } catch (e) {
      debugPrint('Error calculating client balance: $e');
      return 0.0;
    }
  }

  static List<Map<String, dynamic>> getClientPaymentHistory(String clientId) {
    try {
      final history = HiveService.getValue('client_${clientId}_history') ?? [];
      return List<Map<String, dynamic>>.from(history);
    } catch (e) {
      debugPrint('Error getting payment history: $e');
      return [];
    }
  }

  static Future<void> addPaymentToHistory(
    String clientId,
    Map<String, dynamic> payment,
  ) async {
    try {
      final history = getClientPaymentHistory(clientId);
      history.add({
        ...payment,
        'date': DateTime.now().toString(),
      });

      await HiveService.setValue('client_${clientId}_history', history);
    } catch (e) {
      debugPrint('Error adding payment to history: $e');
      rethrow;
    }
  }

  static List<Map<String, dynamic>> searchClients(String query) {
    try {
      final clients = getAllClients();
      final lowerQuery = query.toLowerCase();

      return clients
          .where((client) =>
              (client['name'] ?? '').toLowerCase().contains(lowerQuery) ||
              (client['phone'] ?? '').toLowerCase().contains(lowerQuery))
          .toList();
    } catch (e) {
      debugPrint('Error searching clients: $e');
      return [];
    }
  }

  static Map<String, dynamic> getClientStats(String clientId) {
    try {
      final tabsMap = SalesService.getClientTabs(clientId);
      int openTabsCount = 0;
      double totalOwed = 0.0;

      for (var tabData in tabsMap.values) {
        if (tabData is Map<String, dynamic> && tabData['status'] == 'open') {
          openTabsCount++;
          totalOwed += (tabData['totalUSD'] ?? 0.0) as double;
        }
      }
      final totalTabsCount = tabsMap.length;

      return {
        'totalTabs': totalTabsCount,
        'openTabs': openTabsCount,
        'totalOwed': totalOwed,
        'closedTabs': totalTabsCount - openTabsCount,
      };
    } catch (e) {
      debugPrint('Error getting client stats: $e');
      return {
        'totalTabs': 0,
        'openTabs': 0,
        'totalOwed': 0.0,
        'closedTabs': 0,
      };
    }
  }
}