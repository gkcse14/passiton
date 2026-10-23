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

  static const _labels = ['Pick an object', 'Name & mission', 'Review'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final label = _labels[currentStep.clamp(0, _labels.length - 1)];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Step ${currentStep + 1} of $totalSteps · $label',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(totalSteps, (i) {
            final done = i <= currentStep;
            return Padding(
              padding: EdgeInsets.only(right: i == totalSteps - 1 ? 0 : 6),
              child: AnimatedContainer(
                duration: MediaQuery.disableAnimationsOf(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 300),
                curve: Curves.easeOutCubic,
                width: i == currentStep ? 36 : 10,
                height: 8,
                decoration: BoxDecoration(
                  color: done
                      ? AppTheme.primary
                      : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
