import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/http_client/data/models/items/add_edit_items_model.dart';
import 'package:pos/http_client/local_storage/local_storage_helpers.dart';

class HomeSceenController extends GetxController {
  final RxList<String> categories = <String>[].obs;
  final selectedCategory = ''.obs;
  final RxMap<String, bool> expandedCategories = <String, bool>{}.obs;

  final TextEditingController categoryController = TextEditingController();

  final RxList<AddEditItemModel> allProducts = <AddEditItemModel>[].obs;

  final cart = <AddEditItemModel>[].obs;

  @override
  void onInit() {
    allProducts.clear();
    super.onInit();
    loadCategories();
    loadProducts();
  }

  void loadCategories() {
    final loaded = LocalStorageHelpers.getJsonList('itemsBox', 'categories');
    if (loaded != null) {
      categories.assignAll(loaded.map((c) => c['name'] as String));
      // Initialize expanded state for all categories
      for (var category in categories) {
        expandedCategories[category] = false;
      }
    }
  }

  void loadProducts() {
    final loaded = LocalStorageHelpers.getJsonList('itemsBox', 'products');
    if (loaded != null) {
      allProducts.assignAll(loaded.map((p) => AddEditItemModel.fromJson(p)));
    }
  }

  void addProduct(AddEditItemModel product) {
    allProducts.add(product);
    saveProducts();
  }

  void saveProducts() {
    LocalStorageHelpers.storeJsonList('itemsBox', 'products', allProducts.map((p) => p.toJson()).toList());
  }

  void saveCategories() {
    LocalStorageHelpers.storeJsonList('itemsBox', 'categories', categories.map((c) => {'name': c}).toList());
  }

  void addToCart(AddEditItemModel product) {
    final existingIndex =
        cart.indexWhere((item) => item.description == product.description);
    if (existingIndex >= 0) {
      cart[existingIndex].quantity = (cart[existingIndex].quantity ?? 0) + 1;
      cart.refresh();
    } else {
      final cartItem = AddEditItemModel.fromJson(product.toJson());
      cartItem.quantity = 1;
      cart.add(cartItem);
    }
  }

  void showAddCategoryDialog(BuildContext context) {
    categoryController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Category'),
        content: TextField(
          controller: categoryController,
          decoration: const InputDecoration(hintText: 'Enter category name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final category = categoryController.text.trim();
              if (category.isNotEmpty) {
                addCategory(category);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void updateQuantity(int index, int change) {
    cart[index].quantity = (cart[index].quantity ?? 0) + change;
    if ((cart[index].quantity ?? 0) <= 0) {
      cart.removeAt(index);
    } else {
      cart.refresh();
    }
  }

  void removeItem(int index) => cart.removeAt(index);

  double get total =>
      cart.fold(0, (sum, item) => sum + (item.quantity ?? 0) * (item.sellingPrice ?? 0));

  List<AddEditItemModel> get filteredProducts => allProducts
      .where((p) => p.category == selectedCategory.value)
      .toList();

  void clearCart() => cart.clear();

  void addCategory(String category) {
    if (!categories.contains(category)) {
      categories.add(category);
      expandedCategories[category] = false;
      saveCategories();
    }
  }

  void deleteProduct(AddEditItemModel product) {
    allProducts.remove(product);
    saveProducts();
  }

  void updateProduct(AddEditItemModel product) {
    final index = allProducts.indexWhere((p) => p.description == product.description);
    if (index >= 0) {
      allProducts[index] = product;
      allProducts.refresh();
      saveProducts();
    }
  }

  void deleteCategory(String category) {
    categories.remove(category);
    expandedCategories.remove(category);
    saveCategories();
    // Remove all products in this category
    allProducts.removeWhere((p) => p.category == category);
    saveProducts();
  }

  void toggleCategoryExpanded(String category) {
    expandedCategories[category] = !(expandedCategories[category] ?? false);
    expandedCategories.refresh(); // Force refresh
  }

  List<AddEditItemModel> getProductsByCategory(String category) {
    return allProducts.where((p) => p.category == category).toList();
  }

  // New: find product by barcode-like fields and add to cart
  bool findAndAddByBarcode(String code) {
    final query = code.trim();
    if (query.isEmpty) return false;
    for (final p in allProducts) {
      try {
        final map = p.toJson();
        final keys = ['barcode', 'barCode', 'code', 'sku', 'serial'];
        for (final k in keys) {
          if (map.containsKey(k) && map[k]?.toString() == query) {
            addToCart(p);
            return true;
          }
        }
      } catch (_) {
        // if model doesn't implement toJson or structure differs, ignore and continue
      }
    }
    return false;
  }
}
