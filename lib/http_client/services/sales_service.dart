import 'package:uuid/uuid.dart';
import '../local_storage/hive_service.dart';

class SalesService {
  static const String _salesBox = 'salesBox';
  static final Uuid uuid = Uuid();

  // Save a completed sale
  static Future<void> saveSale(List<Map<String, dynamic>> items, double totalUSD, double totalLBP, double exchangeRate, double tva) async {
    final saleId = uuid.v4();
    final sale = {
      'id': saleId,
      'items': items,
      'totalUSD': totalUSD,
      'totalLBP': totalLBP,
      'exchangeRate': exchangeRate,
      'tva': tva,
      'date': DateTime.now().toIso8601String(),
      'type': 'immediate', // immediate or tab
    };
    await HiveService.storeSale(saleId, sale);
  }

  // Save a tab (unpaid sale)
  static Future<void> saveTab(String clientId, List<Map<String, dynamic>> items, double totalUSD, double totalLBP, double exchangeRate, double tva) async {
    final uuid = Uuid();
    final tabId = uuid.v4();
    final tab = {
      'id': tabId,
      'clientId': clientId,
      'items': items,
      'totalUSD': totalUSD,
      'totalLBP': totalLBP,
      'exchangeRate': exchangeRate,
      'tva': tva,
      'date': DateTime.now().toIso8601String(),
      'type': 'tab',
      'status': 'open', // open, paid
    };
    await HiveService.storeSale(tabId, tab);
  }

  // Get all sales
  static Map<String, dynamic> getAllSales() {
    return HiveService.getBox(_salesBox);
  }

  // Get sales by date range
  static List<Map<String, dynamic>> getSalesByDateRange(DateTime startDate, DateTime endDate) {
    final allSales = getAllSales().values.toList();
    return allSales.cast<Map<String, dynamic>>().where((sale) {
      final saleDate = DateTime.parse(sale['date']);
      return saleDate.isAfter(startDate) && saleDate.isBefore(endDate);
    }).toList();
  }

  // Get tabs for a client
  static Map<String, dynamic> getClientTabs(String clientId) {
    final allSales = getAllSales();
    final clientTabs = <String, dynamic>{};

    allSales.forEach((key, value) {
      if (value is Map && value['type'] == 'tab' && value['clientId'] == clientId) {
        clientTabs[key] = value;
      }
    });
    return clientTabs;
  }

  // Mark tab as paid
  static Future<void> markTabAsPaid(String tabId) async {
    final sale = HiveService.getSale(tabId);
    final tab = sale != null ? Map<String, dynamic>.from(sale) : null;
    if (tab != null && tab['type'] == 'tab') {
      tab['status'] = 'paid';
      tab['paidAt'] = DateTime.now().toIso8601String();
      await HiveService.storeSale(tabId, tab);
    }
  }

  // Delete tab
  static Future<void> deleteTab(String tabId) async {
    await HiveService.deleteData(_salesBox, tabId);
  }
}
