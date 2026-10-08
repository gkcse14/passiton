import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/journey_models.dart';
import '../../../theme/app_theme.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class ObjectPickerWidget extends StatelessWidget {
  final ObjectType? selectedType;
  final ValueChanged<ObjectType> onSelect;

  const ObjectPickerWidget({
    required this.selectedType,
    required this.onSelect,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Who\'s going on\nan adventure?',
            style: theme.textTheme.headlineLarge,
          ),
          const SizedBox(height: 6),
          Text(
            'Choose your traveller.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 24),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: MediaQuery.sizeOf(context).width < 350
                ? 0.70
                : 0.80,
            children: ObjectType.values.map((type) {
              final isSelected = selectedType == type;
              return _ObjectTile(
                type: type,
                isSelected: isSelected,
                isDark: isDark,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(type);
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ObjectTile extends StatelessWidget {
  final ObjectType type;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _ObjectTile({
    required this.type,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryContainer
              : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(38),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: type.accentColor.withAlpha(18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return AnimatedScale(
                        scale: isSelected ? 1.06 : 1.0,
                        duration: MediaQuery.disableAnimationsOf(context)
                            ? Duration.zero
                            : const Duration(milliseconds: 350),
                        curve: Curves.easeOutBack,
                        child: ObjectShowcase(
                          type: type,
                          size: (constraints.maxWidth * 0.88).clamp(
                            64.0,
                            108.0,
                          ),
                          animate: isSelected,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.displayName,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppTheme.textPrimaryDark
                          : AppTheme.textPrimaryLight,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    type.personality,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
