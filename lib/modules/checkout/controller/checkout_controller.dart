


import 'dart:developer';

import 'package:get/get.dart';
import 'package:pos/core/routes/paths.dart';
import 'package:pos/http_client/data/models/items/add_edit_items_model.dart';
import 'package:pos/http_client/services/sales_service.dart';
import 'package:pos/modules/settings/controller/settings_controller.dart';
import 'package:pos/modules/home_screen/controller/home_sceen_controller.dart';
import 'package:pos/modules/clients/controller/clients_controller.dart';
import '../view/customer_selector_dialog.dart';

class CheckoutController extends GetxController {
  // Observable variables
  RxDouble totalUSD = 0.0.obs;
  RxDouble totalLBP = 0.0.obs;
  RxDouble exchangeRate = 0.0.obs;
  RxDouble tva = 0.0.obs;
  RxDouble remainingAmount = 0.0.obs;
  RxList<AddEditItemModel> cartItems = <AddEditItemModel>[].obs;
  RxString selectedCustomerId = ''.obs;

  final List<double> predefinedBills = [1, 5, 10, 20, 50, 100];

  @override
  void onInit() {
    super.onInit();
    final settingsController = Get.isRegistered<SettingsController>()
        ? Get.find<SettingsController>()
        : Get.put(SettingsController());
    exchangeRate.value = settingsController.exchangeRate.value;
    tva.value = settingsController.tva.value;
    final args = Get.arguments;
    if (args != null && args is List<AddEditItemModel>) {
      cartItems.assignAll(args);
    }
    calculateTotals();
  }

  void addToCart(AddEditItemModel item) {
    cartItems.add(item);
    calculateTotals();
  }

  void removeFromCart(int index) {
    cartItems.removeAt(index);
    calculateTotals();
  }

  void updateQuantity(int index, int quantity) {
    if (quantity > 0) {
      cartItems[index].quantity = quantity;
      calculateTotals();
    }
  }

  void calculateTotals() {
    double total = 0.0;
    for (var item in cartItems) {
      total += (item.sellingPrice ?? 0.0) * (item.quantity ?? 1);
    }
    totalUSD.value = total;
    totalLBP.value = total * exchangeRate.value;
    remainingAmount.value = totalUSD.value;
  }

  void applyPredefinedBill(double billAmount) {
    remainingAmount.value -= billAmount;
    if (remainingAmount.value < 0) {
      remainingAmount.value = 0;
    }
  }

  void updateExchangeRate(double newRate) {
    exchangeRate.value = newRate;
    calculateTotals();
  }

  Future<void> payNow() async {
    try {
      final items = cartItems.map((item) => item.toJson()).toList();
      await SalesService.saveSale(
          items, totalUSD.value, totalLBP.value, exchangeRate.value, tva.value);

      cartItems.clear();
      calculateTotals();

      final homeController = Get.find<HomeSceenController>();
      homeController.clearCart();

      Get.offNamed(Paths.homeScreen);
    } catch (e) {
      log('Error in payNow: $e');
      Get.offNamed(Paths.homeScreen);
    }
  }

  Future<void> payLater(String customerId) async {
    try {
      selectedCustomerId.value = customerId;
      final items = cartItems.map((item) => item.toJson()).toList();
      await SalesService.saveTab(customerId, items, totalUSD.value,
          totalLBP.value, exchangeRate.value, tva.value);

      cartItems.clear();
      calculateTotals();

      final homeController = Get.find<HomeSceenController>();
      homeController.clearCart();

      Get.offNamed(Paths.homeScreen);
    } catch (e) {
      log('Error in payLater: $e');
      Get.offNamed(Paths.homeScreen);
    }

  }

  void showCustomerSelector() {
    // Ensure ClientsController is available
    if (!Get.isRegistered<ClientsController>()) {
      Get.put(ClientsController());
    }

    // Show customer selector dialog
    Get.dialog(
      const CustomerSelectorDialog(),
      barrierDismissible: false,
    ).then((result) {
      if (result != null && result is Map<String, dynamic>) {

        final customerId = result['id'] as String? ?? '';
        if (customerId.isNotEmpty) {
          payLater(customerId);
        } else {
          // No customer selected
          Get.snackbar('Info', 'Please select a customer');
        }
      } else {
        // Dialog was dismissed without selection
        Get.snackbar('Info', 'Customer selection cancelled');
      }
    });
  }
}
