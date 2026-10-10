import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class StepIndicatorWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicatorWidget({
    required this.currentStep,
    required this.totalSteps,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step ${currentStep + 1} of $totalSteps · ${const ['Choose', 'Your story', 'Ready to go'][currentStep.clamp(0, 2)]}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (i) {
            final isCompleted = i < currentStep;
            final isCurrent = i == currentStep;
            return Row(
              children: [
                AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 300),
                  curve: Curves.easeOutCubic,
                  width: isCurrent ? 28 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent
                        ? AppTheme.primary
                        : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                if (i < totalSteps - 1) const SizedBox(width: 6),
              ],
            );
          }),
        ),
      ],
    );
  }
}
