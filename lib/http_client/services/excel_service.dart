import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../local_storage/hive_service.dart';

class ExcelService {
  static const String _settingsSheet = 'Settings';
  static const String _clientsSheet = 'Clients';
  static const String _itemsSheet = 'Items';
  static const String _salesSheet = 'Sales';

  static Future<String?> exportToExcel() async {
    try {
      final excel = Excel.createExcel();
      
      excel.delete('Sheet1');

      await _exportSettings(excel);
      
      await _exportClients(excel);
      
      await _exportItems(excel);
      
      await _exportSales(excel);

      final directory = await getApplicationDocumentsDirectory();
      final fileName = 'POS_Backup_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      final bytes = excel.encode();
      await file.writeAsBytes(bytes!);

      return filePath;
    } catch (e) {
      debugPrint('Error exporting to Excel: $e');
      return null;
    }
  }

  static Future<bool> importFromExcel() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );

      if (result == null || result.files.isEmpty) {
        return false;
      }

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      await _importSettings(excel);
      
      await _importClients(excel);
      
      await _importItems(excel);
      
      await _importSales(excel);

      return true;
    } catch (e) {
      debugPrint('Error importing from Excel: $e');
      return false;
    }
  }

  static Future<void> _exportSettings(Excel excel) async {
    final sheet = excel[_settingsSheet];
    if (sheet.rows.isEmpty) {
      sheet.appendRow([
        'Key',
        'Value',
      ]);
    }

    try {
      final settingsData = HiveService.getBox('settingsBox');
      if (settingsData != null) {
        for (var entry in settingsData.entries) {
          sheet.appendRow([
            entry.key.toString(),
            entry.value?.toString() ?? '',
          ]);
        }
      }
    } catch (e) {
      debugPrint('Error exporting settings: $e');
    }
  }

  static Future<void> _exportClients(Excel excel) async {
    final sheet = excel[_clientsSheet];
    if (sheet.rows.isEmpty) {
      sheet.appendRow([
        'ID',
        'Name',
        'Phone',
        'Created Date',
        'Status',
      ]);
    }


    try {
      final clients = HiveService.getValue('clients');
      if (clients != null) {
        for (var client in clients) {
          if (client is Map<String, dynamic>) {
            sheet.appendRow([
              client['id'] ?? '',
              client['name'] ?? '',
              client['phone'] ?? '',
              client['createdDate'] ?? '',
              client['status'] ?? 'active',
            ]);
          }
        }
      }
    } catch (e) {
      debugPrint('Error exporting clients: $e');
    }
  }

  static Future<void> _exportItems(Excel excel) async {
    final sheet = excel[_itemsSheet];
    if (sheet.rows.isEmpty) {
      sheet.appendRow([
        'Description',
        'Category',
        'Barcode',
        'Quantity',
        'Cost Price',
        'TVA Percent',
        'Price After TVA',
        'Profit Percent',
        'Selling Price',
      ]);
    }

    try {
      final products = HiveService.getValue('products');
      if (products != null) {
        for (var product in products) {
          if (product is Map<String, dynamic>) {
            sheet.appendRow([
              product['description'] ?? '',
              product['category'] ?? '',
              product['barcode'] ?? '',
              product['quantity'] ?? 0,
              product['cost_price'] ?? 0.0,
              product['tva_percent'] ?? 0.0,
              product['price_after_tva'] ?? 0.0,
              product['profit_percent'] ?? 0.0,
              product['selling_price'] ?? 0.0,
            ]);
          }
        }
      }

      final categories = HiveService.getValue('categories');
      if (categories != null) {
        sheet.appendRow([]);
        sheet.appendRow(['Categories:']);
        for (var category in categories) {
          if (category is Map<String, dynamic>) {
            sheet.appendRow([category['name'] ?? '']);
          } else if (category is String) {
            sheet.appendRow([category]);
          }
        }
      }
    } catch (e) {
      debugPrint('Error exporting items: $e');
    }
  }

  static Future<void> _exportSales(Excel excel) async {
    final sheet = excel[_salesSheet];
    if (sheet.rows.isEmpty) {
      sheet.appendRow([
        'ID',
        'Type',
        'Client ID',
        'Items',
        'Total USD',
        'Total LBP',
        'Exchange Rate',
        'TVA',
        'Date',
        'Status',
      ]);
    }

    try {
      final salesMap = HiveService.getBox('salesBox');
      for (var entry in salesMap.entries) {
        final sale = entry.value;
        if (sale is Map<String, dynamic>) {
          sheet.appendRow([
            sale['id'] ?? '',
            sale['type'] ?? '',
            sale['clientId'] ?? '',
            sale['items']?.toString() ?? '',
            sale['totalUSD'] ?? 0.0,
            sale['totalLBP'] ?? 0.0,
            sale['exchangeRate'] ?? 0.0,
            sale['tva'] ?? 0.0,
            sale['date'] ?? '',
            sale['status'] ?? '',
          ]);
        }
      }
        } catch (e) {
      debugPrint('Error exporting sales: $e');
    }
  }

  static Future<void> _importSettings(Excel excel) async {
    try {
      final sheet = excel[_settingsSheet];
      if (sheet.rows.isEmpty) return;

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        if (row.length >= 2 && row[0]?.value != null && row[1]?.value != null) {
          final keyValue = row[0]?.value;
          final valueValue = row[1]?.value;
          if (keyValue != null && valueValue != null) {
            String key = keyValue.toString();
            String valueString = valueValue.toString();
            
            if (key.isNotEmpty) {
              await HiveService.storeSetting(key, valueString);
            }
          }
        }
      }
    } catch (e) {
      debugPrint('Error importing settings: $e');
    }
  }


  static Future<void> _importClients(Excel excel) async {
    try {
      final sheet = excel[_clientsSheet];
      if (sheet.rows.isEmpty) return;

      final clients = <Map<String, dynamic>>[];
      
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];

        if (row.length >= 5 && row.every((cell) => cell != null && cell!.value != null)) {
          final client = {
            'id': _getCellString(row[0]?.value),
            'name': _getCellString(row[1]?.value),
            'phone': _getCellString(row[2]?.value),
            'createdDate': _getCellString(row[3]?.value),
            'status': _getCellString(row[4]?.value),
          };
          clients.add(client);
        }
      }
      
      await HiveService.setValue('clients', clients);
    } catch (e) {
      debugPrint('Error importing clients: $e');
    }
  }

  static Future<void> _importItems(Excel excel) async {
    try {
      final sheet = excel[_itemsSheet];
      if (sheet.rows.isEmpty) return;

      final products = <Map<String, dynamic>>[];
      final categories = <String>{};
      
      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.isEmpty || row.every((cell) => cell?.value == null)) continue;
        
        if (row.length == 1 && (row[0]?.value?.toString().contains('Categories:') ?? false)) {
          continue;
        }
        

        if (row.length >= 9) {
          final product = {
            'description': _getCellString(row[0]?.value),
            'category': _getCellString(row[1]?.value),
            'barcode': _getCellString(row[2]?.value),
            'quantity': _parseInt(row[3]?.value?.toString()),
            'cost_price': _parseDouble(row[4]?.value?.toString()),
            'tva_percent': _parseDouble(row[5]?.value?.toString()),
            'price_after_tva': _parseDouble(row[6]?.value?.toString()),
            'profit_percent': _parseDouble(row[7]?.value?.toString()),
            'selling_price': _parseDouble(row[8]?.value?.toString()),
          };
          
          if (product['description'].toString().isNotEmpty) {
            products.add(product);
            if (product['category'].toString().isNotEmpty) {
              categories.add(product['category'].toString());
            }
          }
        }
      }
      
      await HiveService.setValue('products', products);
      await HiveService.setValue('categories', categories.map((c) => {'name': c}).toList());
    } catch (e) {
      debugPrint('Error importing items: $e');
    }
  }

  static Future<void> _importSales(Excel excel) async {
    try {
      final sheet = excel[_salesSheet];
      if (sheet.rows.isEmpty) return;

      for (int i = 1; i < sheet.rows.length; i++) {
        final row = sheet.rows[i];
        if (row.length >= 10 && row.every((cell) => cell?.value != null)) {
          final sale = {
            'id': _getCellString(row[0]?.value),
            'type': _getCellString(row[1]?.value),
            'clientId': _getCellString(row[2]?.value),
            'items': _getCellString(row[3]?.value),
            'totalUSD': _parseDouble(row[4]?.value?.toString()),
            'totalLBP': _parseDouble(row[5]?.value?.toString()),
            'exchangeRate': _parseDouble(row[6]?.value?.toString()),
            'tva': _parseDouble(row[7]?.value?.toString()),
            'date': _getCellString(row[8]?.value),
            'status': _getCellString(row[9]?.value),
          };
          
          await HiveService.storeSale(sale['id'].toString(), sale);
        }
      }
    } catch (e) {
      debugPrint('Error importing sales: $e');
    }
  }




  static dynamic _parseNumericValue(String value) {
    if (value.isEmpty) return '';
    
    final intValue = int.tryParse(value);
    if (intValue != null) return intValue;
    
    final doubleValue = double.tryParse(value);
    if (doubleValue != null) return doubleValue;
    
    return value;
  }

  static double? _parseDouble(String? value) {
    if (value == null || value.isEmpty) return 0.0;
    return double.tryParse(value) ?? 0.0;
  }

  static int? _parseInt(String? value) {
    if (value == null || value.isEmpty) return 0;
    return int.tryParse(value) ?? 0;
  }

  static String _getCellString(Object? value) {
    if (value == null) return '';
    if (value is String) return value;
    return value.toString();
  }
}
