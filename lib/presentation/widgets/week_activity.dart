import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/core/constants/app_assets.dart';
import 'package:brainbox/presentation/widgets/asset_icon.dart';

class WeekActivity extends StatelessWidget {
  const WeekActivity({required this.activity, super.key});

  /// Monday..Sunday flags; true when the learner was active that day.
  final List<bool> activity;

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final activeDays = activity.where((a) => a).length;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderDefault),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '$activeDays/7 days',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.accentPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(days.length, (index) {
              final isActive = index < activity.length && activity[index];
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child:
                      Column(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: 36,
                                alignment: Alignment.center,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? AppColors.accentPrimary
                                      : AppColors.bgTertiary,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isActive
                                        ? Colors.transparent
                                        : AppColors.borderDefault,
                                  ),
                                ),
                                child: isActive
                                    ? Padding(
                                        padding: const EdgeInsets.all(9),
                                        child: const AssetIcon(
                                          AppAssets.fire,
                                          size: 18,
                                        ),
                                      )
                                    : Text(
                                        days[index],
                                        style: TextStyle(
                                          color: AppColors.textMuted,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                days[index],
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: isActive
                                          ? AppColors.accentPrimary
                                          : AppColors.textMuted,
                                      fontWeight: isActive
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                    ),
                              ),
                            ],
                          )
                          .animate()
                          .fadeIn(delay: (index * 50).ms)
                          .scale(delay: (index * 50).ms),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
