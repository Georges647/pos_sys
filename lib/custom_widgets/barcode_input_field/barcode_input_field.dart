import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pos/themes/styles/styles.dart';

class BarcodeInputField extends StatefulWidget {
  final TextEditingController controller;
  final bool isRequired;
  final String? label;
  final String? hint;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Color? enabledBorderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final VoidCallback? onScan;
  final VoidCallback? onChange;

  const BarcodeInputField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.textInputAction = TextInputAction.done,
    this.inputFormatters,
    this.validator,
    this.enabledBorderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.isRequired = false,
    this.onScan,
    this.onChange,
  });

  @override
  State<BarcodeInputField> createState() => _BarcodeInputFieldState();
}

class _BarcodeInputFieldState extends State<BarcodeInputField> {
  final FocusNode _focusNode = FocusNode();
  String _buffer = '';
  DateTime _lastKeyTime = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  bool _isScannerInput(Duration diff) {
    return diff.inMilliseconds < 30;
  }

  void _handleKey(KeyEvent event) {
    if (event is KeyDownEvent && event.logicalKey.keyLabel.isNotEmpty) {
      final now = DateTime.now();
      final diff = now.difference(_lastKeyTime);
      _lastKeyTime = now;

      final key = event.logicalKey.keyLabel;

      if (_isScannerInput(diff)) {
        if (key == 'Enter') {
          widget.controller.text = _buffer;
          if (widget.onScan != null) widget.onScan!();
          _buffer = '';
          return;
        }
        _buffer += key;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      onKeyEvent: _handleKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.label != null)
            Text(
              widget.label!,
              style: Styles.labelTextStyle,
            ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            textInputAction: widget.textInputAction,
            inputFormatters: widget.inputFormatters,
            validator: (val) {
              if (widget.isRequired && (val == null || val.trim().isEmpty)) {
                return 'This field cannot be empty';
              }
              if (widget.validator != null) return widget.validator!(val);
              return null;
            },
            onChanged: (_) => widget.onChange?.call(),
            decoration: InputDecoration(
              labelStyle: Styles.inputTextStyle,
              hintStyle: Styles.hintTextStyle,
              hintText: widget.hint,
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.enabledBorderColor ?? Colors.grey,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: widget.focusedBorderColor ?? Colors.black,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: const BorderRadius.all(Radius.circular(8)),
                borderSide: BorderSide(
                  color: widget.errorBorderColor ?? Colors.red,
                  width: 2,
                ),
              ),
              suffixIcon: IconButton(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: widget.onScan,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
