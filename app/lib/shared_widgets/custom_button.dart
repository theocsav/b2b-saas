import 'package:flutter/material.dart';

class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final double borderRadius;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 44.0,
    this.backgroundColor,
    this.textColor,
    this.borderRadius = 8.0,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor ?? theme.colorScheme.primary,
          foregroundColor: textColor ?? theme.colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        ).copyWith(
           elevation: WidgetStateProperty.resolveWith<double?>(
            (Set<WidgetState> states) {
              if (states.contains(WidgetState.disabled)) return 0;
              if (states.contains(WidgetState.pressed)) return 4.0;
              return 2.0;
            },
          ),
        ),
        child: Text(
          text,
          style: textStyle ?? theme.textTheme.labelLarge?.copyWith(fontSize: 15),
        ),
      ),
    );
  }
}
