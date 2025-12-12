import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pos/themes/styles/styles.dart';

class CustomCheckbox extends StatelessWidget {
  final String label;
  final RxBool value;

  const CustomCheckbox({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return GestureDetector(
        onTap: () => value.toggle(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1.5),
                borderRadius: BorderRadius.circular(5),
                color: value.value ? Colors.blue : Colors.transparent,
              ),
              child: value.value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Styles.labelTextStyle,
            ),
          ],
        ),
      );
    });
  }
}
