import 'package:flutter/material.dart';
import 'package:gym_pro_manager/core/theme/app_spacing.dart';

class AppFilterOption {
  const AppFilterOption({required this.value, required this.label});

  final String value;
  final String label;
}

class AppFilterChips extends StatelessWidget {
  const AppFilterChips({
    super.key,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  final List<AppFilterOption> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        children: options.map((opt) {
          final isSelected = opt.value == selected;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilterChip(
              label: Text(opt.label),
              selected: isSelected,
              onSelected: (_) => onSelected(opt.value),
              showCheckmark: true,
            ),
          );
        }).toList(),
      ),
    );
  }
}
