import 'package:get/get.dart';

abstract class BaseFormGetxController extends GetxController {
  bool isEditing = false;
  RxBool isLoading = true.obs;

  @override
  void onInit() {
    initializeForm();
    super.onInit();
  }

  Future<void> initializeForm() async {
    await fillFormData();
    await setFormInitialValue();
    isEditing = Get.arguments != null && Get.arguments['itemToEdit'] != null;
    if (isEditing) await setFormValuesFromItemToEdit();
    update();
  }

  void onReturnFromAnotherPage() async {
    await fillFormData();
    setFormInitialValue();
    isEditing = false;
  }

  Future<void> fillFormData();

  Future<void> setFormInitialValue();

  Future<void> setFormValuesFromItemToEdit();

  dynamic newItemDataBind();

  dynamic editedItemDataBind();

  Future<void> saveNewItem({required dynamic newItem});

  Future<void> saveEditedItem({required dynamic editedItem});

  void submitForm() {
    if (isEditing) {
      saveEditedItem(editedItem: editedItemDataBind());
    } else {
      saveNewItem(newItem: newItemDataBind());
    }
  }
}
