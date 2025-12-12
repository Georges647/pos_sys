import 'package:get/get.dart';
import 'package:pos/modules/items/listing_items/controller/listing_items_controller.dart';

class ListingItemsBinding extends Bindings {
  @override
  dependencies() {
    Get.lazyPut(
      () => ListingItemsController(),
    );
  }
}
