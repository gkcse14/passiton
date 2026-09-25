import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../core/models/journey_models.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final String displayName;
  final bool isDark;
  final VoidCallback onEdit;

  const ProfileHeaderWidget({
    required this.displayName,
    required this.isDark,
    required this.onEdit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary.withAlpha(20),
            AppTheme.secondary.withAlpha(13),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Row(
        children: [
          // Illustrated avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(31),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: AppTheme.primary.withAlpha(77),
                width: 2,
              ),
            ),
            child: Center(
              child: ObjectArtworkWidget(type: ObjectType.potato, size: 42),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(displayName, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 2),
                Text(
                  'Your traveller profile',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onEdit,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
              child: Icon(
                Icons.edit_rounded,
                size: 16,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
