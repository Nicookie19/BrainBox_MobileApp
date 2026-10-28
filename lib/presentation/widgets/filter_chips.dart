import 'package:flutter/material.dart';
import 'package:brainbox/core/constants/app_colors.dart';

class FilterChips<T> extends StatelessWidget {
  const FilterChips({
    required this.label,
    required this.options,
    required this.selected,
    required this.getLabel,
    required this.onChanged,
    super.key,
  });

  final String label;
  final List<T> options;
  final T selected;
  final String Function(T) getLabel;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: AppColors.textMuted,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final option = options[index];
              final isSelected = option == selected;
              return FilterChip(
                label: Text(getLabel(option)),
                selected: isSelected,
                onSelected: (_) => onChanged(option),
                selectedColor: AppColors.accentPrimarySoft,
                checkmarkColor: AppColors.accentPrimary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.accentPrimary : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                side: BorderSide(
                  color: isSelected ? AppColors.accentPrimary : AppColors.borderDefault,
                ),
                backgroundColor: AppColors.bgTertiary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              );
            },
          ),
        ),
      ],
    );
  }
}