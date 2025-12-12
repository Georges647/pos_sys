import 'package:get/get.dart';
import 'package:pos/http_client/local_storage/hive_service.dart';

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
}
