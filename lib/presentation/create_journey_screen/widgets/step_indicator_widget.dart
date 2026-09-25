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

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (i) {
        final isCompleted = i < currentStep;
        final isCurrent = i == currentStep;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
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
    );
  }
}
