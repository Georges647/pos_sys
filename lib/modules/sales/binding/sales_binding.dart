import 'package:get/get.dart';
import 'package:pos/modules/sales/controller/sales_controller.dart';

class SalesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(
      () => SalesController(),
    );
  }
}
