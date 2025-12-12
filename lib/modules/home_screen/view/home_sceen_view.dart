

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pos/core/routes/paths.dart';
import 'package:pos/custom_widgets/custom_left_drawer/custom_left_drawer.dart';
import 'package:pos/custom_widgets/order_item_card/order_item_card.dart';
import 'package:pos/custom_widgets/pos_button/pos_button.dart';
import 'package:pos/custom_widgets/product_card/product_card.dart';
import 'package:pos/http_client/data/models/items/add_edit_items_model.dart';
import 'package:pos/modules/home_screen/controller/home_sceen_controller.dart';
import 'package:pos/modules/settings/controller/settings_controller.dart';
import 'package:pos/themes/styles/styles.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}


class _HomeScreenViewState extends State<HomeScreenView> {
  final HomeSceenController controller = Get.find();
  final SettingsController settingsController = Get.find();
  final TextEditingController _barcodeController = TextEditingController();
  final FocusNode _barcodeFocus = FocusNode();
  Timer? _scanDebounce;

  @override
  void initState() {
    super.initState();
    // listen for scanner input and debounce to auto-submit
    _barcodeController.addListener(_onBarcodeChanged);
  }

  void _onBarcodeChanged() {
    // cancel previous debounce
    _scanDebounce?.cancel();

    final raw = _barcodeController.text;
    if (raw.isEmpty) return;

    // If scanner sends an enter/newline character, process immediately
    if (raw.contains('\n') || raw.contains('\r')) {
      final code = raw.replaceAll(RegExp(r'[\r\n]'), '').trim();
      _processScannedCode(code);
      return;
    }

    // Otherwise debounce (scanner inputs are fast) and process after short pause
    _scanDebounce = Timer(const Duration(milliseconds: 220), () {
      final code = _barcodeController.text.trim();
      if (code.isNotEmpty) _processScannedCode(code);
    });
  }

  Future<void> _processScannedCode(String code) async {
    // prevent double processing if field cleared rapidly
    if (code.isEmpty) return;

    final found = controller.findAndAddByBarcode(code);
    // clear & refocus for next scan
    _barcodeController.clear();
    _barcodeFocus.requestFocus();

    if (found) {
    } else {
      Get.snackbar(
        'Not found',
        'No product matches the scanned code',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red[300],
      );
    }
  }

  @override
  void dispose() {
    _scanDebounce?.cancel();
    _barcodeController.removeListener(_onBarcodeChanged);
    _barcodeController.dispose();
    _barcodeFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsController>();
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(settingsController.storeName.value.isNotEmpty
            ? settingsController.storeName.value
            : 'POS Desktop Demo')),
        backgroundColor: Colors.grey[200],
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => Get.toNamed(Paths.settingsScreen),
          ),
        ],
      ),


      drawer: CustomLeftDrawer(
        items: [
          'Item Management',
          'Stock',
          'Clients',
        ],
        onItemTap: [
          () => Get.toNamed(Paths.addEditItemScreen,
              arguments: controller.selectedCategory.value),
          () => Get.toNamed(Paths.itemListingScreen),
          () => Get.toNamed(Paths.clients),
        ],
      ),
      body: Row(
        children: [
          // ============================
          // LEFT PANEL: Categories + Products
          // ============================
          Expanded(
            flex: 3,
            child: Column(
              children: [
                // ---------- TOP: Category Selector ----------
                Container(
                  height: 100,
                  color: Colors.grey[100],
                  child: Obx(
                    () => Row(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: controller.categories.length,
                            itemBuilder: (context, index) {
                              final category = controller.categories[index];
                              return GestureDetector(
                                onTap: () => controller.selectedCategory.value =
                                    category,
                                onLongPress: () => _showDeleteCategoryDialog(
                                    context, category),
                                child: Obx(() {
                                  final isSelected =
                                      controller.selectedCategory.value ==
                                          category;
                                  return Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 16),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.grey.shade300,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Text(
                                        category,
                                        style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.black,
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                              );
                            },
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.blue),
                          onPressed: () =>
                              controller.showAddCategoryDialog(context),
                        ),
                      ],
                    ),
                  ),
                ),

                // ---------- BOTTOM: Product Grid ----------
                Expanded(
                  child: Expanded(
                    child: Obx(
                      () => GridView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: controller.filteredProducts.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                          childAspectRatio: 1.25,
                        ),
                        itemBuilder: (context, index) {
                          final p = controller.filteredProducts[index];
                          return ProductCard(
                            productName: p.description ?? '',
                            price: p.sellingPrice ?? 0,
                            onAddToCart: () => controller.addToCart(p),
                            onLongPress: () =>
                                _showDeleteProductDialog(context, p),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ============================
          // RIGHT PANEL: Order / Cart
          // ============================
          Container(
            width: 400,
            color: Colors.grey[100],
            child: Column(
              children: [
                // -------------------------
                // Barcode scan field (auto-submit)
                // -------------------------
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: TextField(
                    controller: _barcodeController,
                    focusNode: _barcodeFocus,
                    textInputAction: TextInputAction.done,
                    autofocus: true,
                    decoration: InputDecoration(
                      hintText: 'Scan barcode here',
                      prefixIcon: const Icon(Icons.qr_code_scanner),
                      // removed check icon to allow automatic submission
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      hintStyle: Styles.hintTextStyle,
                      labelStyle: Styles.labelTextStyle
                    ),
                    onSubmitted: (value) {
                      // keep onSubmitted as fallback
                      final code = value.trim();
                      if (code.isNotEmpty) _processScannedCode(code);
                    },
                  ),
                ),

                // OrderItemCard / cart listing follows
                Expanded(
                  child: Obx(
                    () => ListView.builder(
                      itemCount: controller.cart.length,
                      itemBuilder: (context, index) {
                        final item = controller.cart[index];
                        return OrderItemCard(
                          productName: item.description ?? '',
                          quantity: item.quantity ?? 0,
                          unitPrice: item.sellingPrice ?? 0,
                          onIncrease: () => controller.updateQuantity(index, 1),
                          onDecrease: () =>
                              controller.updateQuantity(index, -1),
                          onRemove: () => controller.removeItem(index),
                        );
                      },
                    ),
                  ),
                ),
                const Divider(),
                Obx(
                  () => Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        Text(
                          'Total: \$${controller.total.toStringAsFixed(2)}',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Total LBP: ${NumberFormat('#,###').format(controller.total * settingsController.exchangeRate.value)} LBP',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                PosButton(
                  text: 'Checkout',
                  icon: Icons.shopping_cart_checkout,
                  backgroundColor: Colors.blue,
                  onPressed: () => Get.toNamed(Paths.checkout, arguments: controller.cart),
                ),

                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteProductDialog(
      BuildContext context, AddEditItemModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content:
            Text('Are you sure you want to delete "${product.description}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteProduct(product);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, String category) {
    final productsInCategory =
        controller.allProducts.where((p) => p.category == category).toList();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Are you sure you want to delete "$category"? This will also delete ${productsInCategory.length} product(s) in this category.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // Show second confirmation if there are products
              if (productsInCategory.isNotEmpty) {
                Navigator.of(context).pop(); // Close first dialog
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Confirm Deletion'),
                    content: const Text(
                        'This category contains products. Deleting it will remove all associated products. Are you absolutely sure?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          controller.deleteCategory(category);
                          Navigator.of(context).pop();
                        },
                        child: const Text('Yes, Delete All'),
                      ),
                    ],
                  ),
                );
              } else {
                controller.deleteCategory(category);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
