import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../theme/app_theme.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class JourneyPreviewWidget extends StatefulWidget {
  final ObjectType objectType;
  final String name;
  final String mission;
  final String openingNote;
  final GoalType goalType;
  final int? goalTarget;
  final LocationVisibility originVisibility;
  final String? originCity;
  final String? originCountry;

  const JourneyPreviewWidget({
    required this.objectType,
    required this.name,
    required this.mission,
    required this.openingNote,
    required this.goalType,
    required this.goalTarget,
    required this.originVisibility,
    required this.originCity,
    required this.originCountry,
    super.key,
  });

  @override
  State<JourneyPreviewWidget> createState() => _JourneyPreviewWidgetState();
}

class _JourneyPreviewWidgetState extends State<JourneyPreviewWidget> {
  String _audience = 'Anyone with the link';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Preview', style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text(
            'This is how your journey will look.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          // Journey card preview
          Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E4038), Color(0xFF0D2820)],
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E4038).withAlpha(102),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(38),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.objectType.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.name.isNotEmpty
                            ? widget.name
                            : 'Your journey name',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.mission.isNotEmpty
                            ? widget.mission
                            : 'Your mission statement',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_rounded,
                            size: 14,
                            color: Colors.white54,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            '1 person',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (widget.originCity != null ||
                              widget.originCountry != null) ...[
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: Colors.white54,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _originDisplay,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                ObjectShowcase(type: widget.objectType, size: 98),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Summary
          _SummarySection(isDark: isDark, theme: theme, widget: widget),
          const SizedBox(height: 20),
          // Audience
          _FormLabel(label: 'Audience', isDark: isDark),
          const SizedBox(height: 8),
          _AudienceSelector(
            selected: _audience,
            isDark: isDark,
            onChanged: (v) => setState(() => _audience = v),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Audience settings are saved for the preview. Nothing is published online.',
              style: TextStyle(
                fontSize: 12,
                color: AppTheme.secondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String get _originDisplay {
    switch (widget.originVisibility) {
      case LocationVisibility.city:
        return [
          widget.originCity,
          widget.originCountry,
        ].where((e) => e != null).join(', ');
      case LocationVisibility.countryOnly:
        return widget.originCountry ?? '';
      case LocationVisibility.hidden:
        return 'Hidden';
    }
  }
}

class _SummarySection extends StatelessWidget {
  final bool isDark;
  final ThemeData theme;
  final JourneyPreviewWidget widget;

  const _SummarySection({
    required this.isDark,
    required this.theme,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Name',
            value: widget.name.isNotEmpty ? widget.name : '—',
            isDark: isDark,
          ),
          _divider(isDark),
          _SummaryRow(
            label: 'Mission',
            value: widget.mission.isNotEmpty ? widget.mission : '—',
            isDark: isDark,
          ),
          if (widget.openingNote.isNotEmpty) ...[
            _divider(isDark),
            _SummaryRow(
              label: 'Opening note',
              value: widget.openingNote,
              isDark: isDark,
            ),
          ],
          _divider(isDark),
          _SummaryRow(
            label: 'Goal',
            value: widget.goalType == GoalType.none
                ? 'None'
                : '${widget.goalTarget ?? '—'} ${widget.goalType.name}',
            isDark: isDark,
          ),
          _divider(isDark),
          _SummaryRow(
            label: 'Origin',
            value: widget.originVisibility.name,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _divider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Divider(
        height: 1,
        color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  final bool isDark;

  const _FormLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppTheme.textSecondaryDark
            : AppTheme.textSecondaryLight,
      ),
    );
  }
}

class _AudienceSelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _AudienceSelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = ['Anyone with the link', 'Public'];
    return Row(
      children: options.map((opt) {
        final isSelected = opt == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: GestureDetector(
              onTap: () => onChanged(opt),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.primaryContainer
                      : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.primary
                        : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  opt,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected
                        ? AppTheme.primary
                        : (isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight),
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
