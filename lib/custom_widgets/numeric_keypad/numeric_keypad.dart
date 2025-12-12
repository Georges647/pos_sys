import 'package:flutter/material.dart';

/// A customizable numeric keypad widget for inputting numbers.
///
/// This widget provides a grid of buttons for digits 0-9, a decimal point,
/// a backspace, and a clear button. It's highly flexible with callbacks
/// for each button press and customizable styling.
class NumericKeypad extends StatelessWidget {
  const NumericKeypad({
    super.key,
    required this.onKeyPressed,
    this.buttonColor,
    this.textColor,
    this.iconColor,
    this.buttonTextStyle,
  });

  /// Callback function when any key on the keypad is pressed.
  /// The [value] parameter will be the string representation of the key ('0'-'9', '.', 'DEL', 'CLR').
  final ValueChanged<String> onKeyPressed;

  final Color? buttonColor;
  final Color? textColor;
  final Color? iconColor;
  final TextStyle? buttonTextStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultButtonColor =
        buttonColor ?? theme.colorScheme.surfaceContainerHighest;
    final defaultTextColor = textColor ?? theme.colorScheme.onSurfaceVariant;
    final defaultIconColor = iconColor ?? theme.colorScheme.onSurfaceVariant;
    final defaultButtonTextStyle = buttonTextStyle ??
        theme.textTheme.headlineSmall?.copyWith(color: defaultTextColor);

    Widget buildKey(String text, {IconData? icon, bool isAction = false}) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: ElevatedButton(
            onPressed: () => onKeyPressed(text),
            style: ElevatedButton.styleFrom(
              backgroundColor: isAction
                  ? theme.colorScheme.primaryContainer
                  : defaultButtonColor,
              foregroundColor: isAction
                  ? theme.colorScheme.onPrimaryContainer
                  : defaultTextColor,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: icon != null
                ? Icon(icon,
                    color: isAction
                        ? theme.colorScheme.onPrimaryContainer
                        : defaultIconColor)
                : Text(
                    text,
                    style: isAction
                        ? theme.textTheme.headlineSmall?.copyWith(
                            color: theme.colorScheme.onPrimaryContainer)
                        : defaultButtonTextStyle,
                  ),
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            buildKey('1'),
            buildKey('2'),
            buildKey('3'),
          ],
        ),
        Row(
          children: [
            buildKey('4'),
            buildKey('5'),
            buildKey('6'),
          ],
        ),
        Row(
          children: [
            buildKey('7'),
            buildKey('8'),
            buildKey('9'),
          ],
        ),
        Row(
          children: [
            buildKey('.', isAction: true),
            buildKey('0'),
            buildKey('DEL', icon: Icons.backspace_outlined, isAction: true),
          ],
        ),
        Row(
          children: [
            buildKey('CLR', icon: Icons.clear_all_outlined, isAction: true),
          ],
        ),
      ],
    );
  }
}
