import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.outlined = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(58)),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      textStyle: const WidgetStatePropertyAll(
        TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
      ),
    );
    return SizedBox(
      width: double.infinity,
      child: outlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: style.copyWith(
                foregroundColor: const WidgetStatePropertyAll(AppColors.red),
                side: const WidgetStatePropertyAll(
                  BorderSide(color: AppColors.red, width: 2),
                ),
              ),
              child: child,
            )
          : FilledButton(
              onPressed: onPressed,
              style: style.copyWith(
                backgroundColor: const WidgetStatePropertyAll(AppColors.red),
                foregroundColor: const WidgetStatePropertyAll(Colors.white),
              ),
              child: child,
            ),
    );
  }
}
