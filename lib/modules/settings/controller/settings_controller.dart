
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:pos/http_client/local_storage/hive_service.dart';
import 'package:pos/http_client/services/excel_service.dart';

class SettingsController extends GetxController {
  final storeName = 'POS'.obs;
  final exchangeRate = 0.0.obs;
  final tva = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    loadSettings();
  }

  void loadSettings() {
    storeName.value = HiveService.getSetting('storeName') ?? '';
    exchangeRate.value = (HiveService.getSetting('exchangeRate') as num?)?.toDouble() ?? 0.0;
    tva.value = (HiveService.getSetting('tva') as num?)?.toDouble() ?? 0.0;
  }


  Future<void> saveSettings() async {
    await HiveService.storeSetting('storeName', storeName.value);
    await HiveService.storeSetting('exchangeRate', exchangeRate.value);
    await HiveService.storeSetting('tva', tva.value);
    Get.back();
  }
  Future<void> exportData() async {
    try {
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final filePath = await ExcelService.exportToExcel();
      
      if (filePath != null) {
        Get.back();
        
        Get.snackbar(
          'Export Successful',
          'Data exported successfully to: $filePath',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.back();
        
        Get.snackbar(
          'Export Failed',
          'Failed to export data to Excel',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      
      Get.snackbar(
        'Export Error',
        'Error exporting data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> importData() async {
    try {
      final confirm = await Get.dialog(
        AlertDialog(
          title: const Text('Import Data'),
          content: const Text(
            'This will replace all existing data with data from the Excel file. This action cannot be undone. Continue?'
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Import', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final success = await ExcelService.importFromExcel();
      
      if (success) {
        Get.back();
        
        loadSettings();
        
        Get.snackbar(
          'Import Successful',
          'Data imported successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } else {
        Get.back();
        
        Get.snackbar(
          'Import Failed',
          'Failed to import data from Excel',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      
      Get.snackbar(
        'Import Error',
        'Error importing data: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
