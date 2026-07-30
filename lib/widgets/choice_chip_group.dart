import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class AppChoiceChip<T> extends StatelessWidget {
  const AppChoiceChip({
    super.key,
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.onSelected,
  });

  final String label;
  final T value;
  final T selectedValue;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = value == selectedValue;
    return ChoiceChip(
      selected: selected,
      showCheckmark: false,
      label: Text(label),
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.ink,
        fontWeight: FontWeight.w700,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      backgroundColor: Colors.white,
      selectedColor: AppColors.red,
      side: BorderSide(
        color: selected ? AppColors.red : AppColors.border,
        width: 1.4,
      ),
      shape: const StadiumBorder(),
      onSelected: (_) => onSelected(value),
    );
  }
}
