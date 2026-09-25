import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/data/sample_data.dart';
import '../../core/models/journey_models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/demo_controls_widget.dart';
import './widgets/profile_header_widget.dart';
import './widgets/profile_stats_widget.dart';
import './widgets/settings_section_widget.dart';

class YouScreen extends StatefulWidget {
  const YouScreen({super.key});

  @override
  State<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends State<YouScreen> {
  // TODO: Replace with Riverpod for production
  String _displayName = 'Traveller';
  String _themeMode = 'System'; // System / Light / Dark
  bool _haptics = true;
  bool _reduceMotion = false;
  String _defaultLocation = 'city';
  late List<JourneyObject> _journeys;
  late List<JourneyStop> _stops;

  @override
  void initState() {
    super.initState();
    _journeys = sampleJourneyMaps.map(JourneyObject.fromMap).toList();
    _stops = sampleStopMaps.map(JourneyStop.fromMap).toList();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _displayName = prefs.getString('display_name') ?? 'Traveller';
      _themeMode = prefs.getString('theme_mode') ?? 'System';
      _haptics = prefs.getBool('haptics') ?? true;
      _reduceMotion = prefs.getBool('reduce_motion') ?? false;
      _defaultLocation = prefs.getString('default_location') ?? 'city';
    });
  }

  Future<void> _savePrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('display_name', _displayName);
    await prefs.setString('theme_mode', _themeMode);
    await prefs.setBool('haptics', _haptics);
    await prefs.setBool('reduce_motion', _reduceMotion);
    await prefs.setString('default_location', _defaultLocation);
  }

  int get _startedCount =>
      _journeys.where((j) => j.creatorId == kLocalUserId).length;

  int get _joinedCount => _stops
      .where((s) => s.participantId == kLocalUserId && !s.isOrigin)
      .map((s) => s.objectId)
      .toSet()
      .length;

  int get _followingCount => _journeys.where((j) => j.isFollowed).length;

  void _editDisplayName() {
    final controller = TextEditingController(text: _displayName);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final bottomPadding = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit name', style: Theme.of(ctx).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                maxLength: 30,
                decoration: InputDecoration(
                  hintText: 'Your display name',
                  filled: true,
                  fillColor: isDark
                      ? AppTheme.backgroundDark
                      : AppTheme.backgroundLight,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    setState(
                      () => _displayName = controller.text.trim().isNotEmpty
                          ? controller.text.trim()
                          : _displayName,
                    );
                    _savePrefs();
                    Navigator.pop(ctx);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _confirmReset() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset app data?'),
        content: const Text(
          'This will delete all your local journeys, stops, follows, and profile changes, '
          'and restore the original sample content. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Reset', style: TextStyle(color: AppTheme.error)),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      setState(() {
        _displayName = 'Traveller';
        _themeMode = 'System';
        _haptics = true;
        _reduceMotion = false;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('App data reset to defaults')),
      );
    }
  }

  void _showHowJourneysWork() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'How journeys work',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            ..._howSteps.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryContainer,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Text(
                          '${_howSteps.indexOf(step) + 1}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        step,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: isDark
                              ? AppTheme.textPrimaryDark
                              : AppTheme.textPrimaryLight,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const List<String> _howSteps = [
    'Create an object — a potato, heart, star, or any traveller.',
    'Pass it along to someone — they join and leave a message.',
    'Each person adds a stop to the journey.',
    'Group sharing creates branches — the object travels many paths at once.',
    'Return to see its story grow across the world.',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, topPadding + 16, 20, 0),
              child: _buildScreenHeader(theme, isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: ProfileHeaderWidget(
                displayName: _displayName,
                isDark: isDark,
                onEdit: _editDisplayName,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: ProfileStatsWidget(
                started: _startedCount,
                joined: _joinedCount,
                following: _followingCount,
                isDark: isDark,
              ),
            ),
          ),
          // Appearance section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: SettingsSectionWidget(
                title: 'Appearance',
                isDark: isDark,
                items: [
                  SettingsItem(
                    icon: Icons.palette_outlined,
                    label: 'Theme',
                    trailing: _ThemeSelector(
                      selected: _themeMode,
                      isDark: isDark,
                      onChanged: (v) {
                        setState(() => _themeMode = v);
                        _savePrefs();
                      },
                    ),
                  ),
                  SettingsItem(
                    icon: Icons.vibration_rounded,
                    label: 'Haptics',
                    trailing: Switch(
                      value: _haptics,
                      onChanged: (v) {
                        setState(() => _haptics = v);
                        _savePrefs();
                      },
                      activeThumbColor: AppTheme.primary,
                    ),
                  ),
                  SettingsItem(
                    icon: Icons.animation_rounded,
                    label: 'Reduce motion',
                    trailing: Switch(
                      value: _reduceMotion,
                      onChanged: (v) {
                        setState(() => _reduceMotion = v);
                        _savePrefs();
                      },
                      activeThumbColor: AppTheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Preferences section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SettingsSectionWidget(
                title: 'Preferences',
                isDark: isDark,
                items: [
                  SettingsItem(
                    icon: Icons.location_on_rounded,
                    label: 'Default location visibility',
                    trailing: _LocationSelector(
                      selected: _defaultLocation,
                      isDark: isDark,
                      onChanged: (v) {
                        setState(() => _defaultLocation = v);
                        _savePrefs();
                      },
                    ),
                  ),
                  SettingsItem(
                    icon: Icons.notifications_outlined,
                    label: 'Notifications',
                    subtitle: 'Local preferences only',
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          // About section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SettingsSectionWidget(
                title: 'About',
                isDark: isDark,
                items: [
                  SettingsItem(
                    icon: Icons.help_outline_rounded,
                    label: 'How journeys work',
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                    onTap: _showHowJourneysWork,
                  ),
                  SettingsItem(
                    icon: Icons.info_outline_rounded,
                    label: 'About Pass It On',
                    subtitle: 'Version 1.0.0 (preview)',
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),
          // Demo controls section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: DemoControlsWidget(
                isDark: isDark,
                onReplayOnboarding: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('onboarding_seen', false);
                  if (!context.mounted) return;
                  context.go(AppRoutes.onboardingScreen);
                },
                onResetDemo: _confirmReset,
              ),
            ),
          ),
          // Danger zone
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: SettingsSectionWidget(
                title: 'Danger zone',
                isDark: isDark,
                items: [
                  SettingsItem(
                    icon: Icons.delete_outline_rounded,
                    label: 'Reset all app data',
                    labelColor: AppTheme.error,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      size: 18,
                      color: AppTheme.error.withAlpha(153),
                    ),
                    onTap: _confirmReset,
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildScreenHeader(ThemeData theme, bool isDark) {
    return Text('You', style: theme.textTheme.headlineLarge);
  }
}

class _ThemeSelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _ThemeSelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            selected,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: ['System', 'Light', 'Dark'].map((opt) {
              final isSelected = opt == selected;
              return ListTile(
                title: Text(opt),
                trailing: isSelected
                    ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                    : null,
                onTap: () {
                  onChanged(opt);
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }
}

class _LocationSelector extends StatelessWidget {
  final String selected;
  final bool isDark;
  final ValueChanged<String> onChanged;

  const _LocationSelector({
    required this.selected,
    required this.isDark,
    required this.onChanged,
  });

  String get _label {
    switch (selected) {
      case 'city':
        return 'City';
      case 'countryOnly':
        return 'Country only';
      case 'hidden':
        return 'Hidden';
      default:
        return 'City';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.expand_more_rounded,
            size: 16,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ],
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children:
                [
                  {'value': 'city', 'label': 'City'},
                  {'value': 'countryOnly', 'label': 'Country only'},
                  {'value': 'hidden', 'label': 'Hidden'},
                ].map((opt) {
                  final isSelected = opt['value'] == selected;
                  return ListTile(
                    title: Text(opt['label']!),
                    trailing: isSelected
                        ? const Icon(
                            Icons.check_rounded,
                            color: AppTheme.primary,
                          )
                        : null,
                    onTap: () {
                      onChanged(opt['value']!);
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
          ),
        );
      },
    );
  }
}
