import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/custom_widgets/form_input_field/form_input_field.dart';
import 'package:pos/custom_widgets/pos_button/pos_button.dart';
import 'package:pos/modules/settings/controller/settings_controller.dart';
import 'package:pos/themes/styles/styles.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final storeNameController = TextEditingController();
    final exchangeRateController = TextEditingController();
    final tvaController = TextEditingController();

    // Initialize controllers with current values
    storeNameController.text = controller.storeName.value;
    exchangeRateController.text = controller.exchangeRate.value.toString();
    tvaController.text = controller.tva.value.toString();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.grey[200],
        centerTitle: true,
      ),
      body: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: Styles.generaleWidth,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                FormInputField(
                  controller: storeNameController,
                  label: 'Store Name',
                  hint: 'Enter store name',
                  isRequired: true,
                  onChange: () =>
                      controller.storeName.value = storeNameController.text,
                ),
                const SizedBox(height: 16),
                FormInputField(
                  controller: exchangeRateController,
                  label: 'Exchange Rate to LBP',
                  hint: 'Enter exchange rate',
                  keyboardType: TextInputType.number,
                  allowDecimal: true,
                  isRequired: true,
                  onChange: () => controller.exchangeRate.value =
                      double.tryParse(exchangeRateController.text) ?? 0.0,
                ),
                const SizedBox(height: 16),
                FormInputField(
                  controller: tvaController,
                  label: 'TVA %',
                  hint: 'Enter TVA percentage',
                  keyboardType: TextInputType.number,
                  allowDecimal: true,
                  isRequired: true,
                  onChange: () => controller.tva.value =
                      double.tryParse(tvaController.text) ?? 0.0,
                ),
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerRight,
                  child: PosButton(
                    text: 'Save Settings',
                    icon: Icons.save,
                    backgroundColor: Colors.blue,
                    onPressed: () => controller.saveSettings(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
