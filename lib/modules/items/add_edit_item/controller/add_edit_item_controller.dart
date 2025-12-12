import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/core/base_classes/base_form_getx_controller/base_form_getx_controller.dart';
import 'package:pos/http_client/data/models/items/add_edit_items_model.dart';
import 'package:pos/modules/home_screen/controller/home_sceen_controller.dart';
import 'package:pos/modules/settings/controller/settings_controller.dart';

class AddEditItemController extends BaseFormGetxController {
  final Rx<String?> selectedCategory = Rx<String?>(null);

  final formKey = GlobalKey<FormState>();

  late TextEditingController descriptionController,
      barcodeController,
      quantityController,
      costPriceController,
      tvaPercentController,
      priceAfterTvaController,
      profitPercentController,
      sellingPriceController;

  @override
  void onInit() {
    final category = Get.arguments;
    if (category is String && category.isNotEmpty) {
      selectedCategory.value = category; 
    }
    super.onInit();
  }

  @override
  Future<void> initializeForm() async {
    await fillFormData();
    await setFormInitialValue();
    isEditing = false;
    update();
  }

  @override
  void onClose() {
    descriptionController.dispose();
    barcodeController.dispose();
    quantityController.dispose();
    costPriceController.dispose();
    tvaPercentController.dispose();
    priceAfterTvaController.dispose();
    profitPercentController.dispose();
    sellingPriceController.dispose();
    super.onClose();
  }

  void calculatePriceAfterTva() {
    double cost = double.tryParse(costPriceController.text) ?? 0;
    double tva = double.tryParse(tvaPercentController.text) ?? 0;
    double priceAfter = cost * (1 + tva / 100);
    priceAfterTvaController.text = priceAfter.toStringAsFixed(2);
    calculateSellingPrice();
  }

  void calculateSellingPrice() {
    double priceAfter = double.tryParse(priceAfterTvaController.text) ?? 0;
    double profit = double.tryParse(profitPercentController.text) ?? 0;
    double selling = priceAfter * (1 + profit / 100);
    sellingPriceController.text = selling.toStringAsFixed(2);
  }

  void calculateTvaPercent() {
    double cost = double.tryParse(costPriceController.text) ?? 0;
    double priceAfter = double.tryParse(priceAfterTvaController.text) ?? 0;
    if (cost != 0) {
      double tva = ((priceAfter / cost) - 1) * 100;
      tvaPercentController.text = tva.toStringAsFixed(2);
    }
  }

  void calculateProfitPercent() {
    double priceAfter = double.tryParse(priceAfterTvaController.text) ?? 0;
    double selling = double.tryParse(sellingPriceController.text) ?? 0;
    if (priceAfter != 0) {
      double profit = ((selling / priceAfter) - 1) * 100;
      profitPercentController.text = profit.toStringAsFixed(2);
    }
  }

  @override
  editedItemDataBind() {
    throw UnimplementedError();
  }

  @override
  Future<void> fillFormData() async {
    descriptionController = TextEditingController();
    barcodeController = TextEditingController();
    quantityController = TextEditingController();
    costPriceController = TextEditingController();
    tvaPercentController = TextEditingController();
    priceAfterTvaController = TextEditingController();
    profitPercentController = TextEditingController();
    sellingPriceController = TextEditingController();
  }

  @override
  AddEditItemModel newItemDataBind() {
    return AddEditItemModel(
      description: descriptionController.text,
      category: selectedCategory.value,
      barcode: barcodeController.text,
      quantity: int.tryParse(quantityController.text),
      costPrice: double.tryParse(costPriceController.text),
      tvaPercent: double.tryParse(tvaPercentController.text),
      priceAfterTva: double.tryParse(priceAfterTvaController.text),
      profitPercent: double.tryParse(profitPercentController.text),
      sellingPrice: double.tryParse(sellingPriceController.text),
    );
  }

  @override
  Future<void> saveEditedItem({required editedItem}) {
    throw UnimplementedError();
  }

  @override
  Future<void> saveNewItem({required newItem}) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final homeController = Get.find<HomeSceenController>();
    homeController.addProduct(newItem);
    Get.back();
  }

  @override
  Future<void> setFormInitialValue() async {
    final settingsController = Get.find<SettingsController>();
    tvaPercentController.text = settingsController.tva.value.toString();
  }

  @override
  Future<void> setFormValuesFromItemToEdit() {
    throw UnimplementedError();
  }
}
