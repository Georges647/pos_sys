import 'package:get/get.dart';
import 'package:pos/modules/items/add_edit_item/controller/add_edit_item_controller.dart';
import 'package:pos/modules/settings/controller/settings_controller.dart';

class AddEditItemBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => AddEditItemController(),
    );
    Get.lazyPut(
      () => SettingsController(),
    );
  }
}
