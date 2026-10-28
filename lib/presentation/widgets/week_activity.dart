import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:brainbox/core/constants/app_colors.dart';
import 'package:brainbox/data/services/storage_service.dart';

class WeekActivity extends StatelessWidget {
  const WeekActivity({super.key});

  @override
  Widget build(BuildContext context) {
    const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final activity = StorageService.getActivityForWeek(DateTime.now());

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
              Text(
                'This Week',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              Text(
                '${activity.where((active) => active).length}/7 days',
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
              final isActive = activity[index];
              return Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 36,
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
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 20,
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
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
                  .scale(delay: (index * 50).ms);
            }),
          ),
        ],
      ),
    );
  }
}
