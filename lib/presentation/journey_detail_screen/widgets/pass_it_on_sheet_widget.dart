import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/models/journey_models.dart';
import '../../../theme/app_theme.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class PassItOnSheetWidget extends StatelessWidget {
  final JourneyObject journey;
  final List<JourneyStop> stops;

  const PassItOnSheetWidget({
    required this.journey,
    required this.stops,
    super.key,
  });

  String get _invitationText =>
      'Meet ${journey.name} ${journey.type.emoji}\n'
      'Its mission: ${journey.mission}\n'
      'Created with the Pass It On app preview.\n\n'
      '(Live invitation links will be added when sharing is connected.)';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 0, 24, bottomPadding + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Object preview
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: journey.type.accentColor.withAlpha(31),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: ObjectArtworkWidget(type: journey.type, size: 36),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(journey.name, style: theme.textTheme.titleMedium),
                    Text(
                      journey.mission,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Invitation preview box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.backgroundDark
                  : AppTheme.backgroundLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: Text(
              _invitationText,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Local note
          Text(
            'Live invitation links will be added when sharing is connected.',
            style: TextStyle(
              fontSize: 11,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          // Actions
          _ActionButton(
            icon: Icons.copy_rounded,
            label: 'Copy invitation text',
            onTap: () {
              Clipboard.setData(ClipboardData(text: _invitationText));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
            isDark: isDark,
          ),
          const SizedBox(height: 10),
          _ActionButton(
            icon: Icons.preview_rounded,
            label: 'Preview receiving',
            onTap: () => Navigator.pop(context),
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDark;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
