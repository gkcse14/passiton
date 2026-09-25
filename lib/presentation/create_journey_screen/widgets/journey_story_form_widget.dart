import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';
import '../../../theme/app_theme.dart';
import '../../onboarding_screen/widgets/object_artwork_widget.dart';

class JourneyStoryFormWidget extends StatefulWidget {
  final ObjectType objectType;
  final String name;
  final String mission;
  final String openingNote;
  final GoalType goalType;
  final int? goalTarget;
  final LocationVisibility originVisibility;
  final String? originCity;
  final String? originCountry;
  final ValueChanged<String> onNameChanged;
  final ValueChanged<String> onMissionChanged;
  final ValueChanged<String> onOpeningNoteChanged;
  final ValueChanged<GoalType> onGoalTypeChanged;
  final ValueChanged<int?> onGoalTargetChanged;
  final ValueChanged<LocationVisibility> onOriginVisibilityChanged;
  final ValueChanged<String?> onOriginCityChanged;
  final ValueChanged<String?> onOriginCountryChanged;

  const JourneyStoryFormWidget({
    required this.objectType,
    required this.name,
    required this.mission,
    required this.openingNote,
    required this.goalType,
    required this.goalTarget,
    required this.originVisibility,
    required this.originCity,
    required this.originCountry,
    required this.onNameChanged,
    required this.onMissionChanged,
    required this.onOpeningNoteChanged,
    required this.onGoalTypeChanged,
    required this.onGoalTargetChanged,
    required this.onOriginVisibilityChanged,
    required this.onOriginCityChanged,
    required this.onOriginCountryChanged,
    super.key,
  });

  @override
  State<JourneyStoryFormWidget> createState() => _JourneyStoryFormWidgetState();
}

class _JourneyStoryFormWidgetState extends State<JourneyStoryFormWidget> {
  late TextEditingController _nameController;
  late TextEditingController _missionController;
  late TextEditingController _noteController;
  late TextEditingController _goalTargetController;

  List<String> get _nameSuggestions {
    switch (widget.objectType) {
      case ObjectType.potato:
        return ['The Internet Potato', 'Spud the Explorer', 'Captain Tater'];
      case ObjectType.heart:
        return ['A Little Kindness', 'Heart of Gold', 'Warm Wishes'];
      case ObjectType.lotus:
        return ['The Quiet Lotus', 'Peaceful Petal', 'Still Waters'];
      case ObjectType.paperPlane:
        return ['One Brave Paper Plane', 'Folded Dreams', 'Paper Voyager'];
      case ObjectType.star:
        return ['The Wandering Star', 'Wish Upon a Star', 'Lucky Star'];
      case ObjectType.seedling:
        return ['Seeds of Hope', 'Little Green', 'The Growing Thing'];
    }
  }

  List<String> get _missionSuggestions {
    switch (widget.objectType) {
      case ObjectType.potato:
        return [
          'Help me visit 20 countries.',
          'Find the world\'s best kitchens.',
          'Make someone smile today.',
        ];
      case ObjectType.heart:
        return [
          'Leave a kind word for the next person.',
          'Spread warmth wherever you go.',
          'Be someone\'s good news today.',
        ];
      case ObjectType.lotus:
        return [
          'Carry a moment of stillness to someone who needs it.',
          'Find peace in every city.',
          'Share a breath of calm.',
        ];
      case ObjectType.paperPlane:
        return [
          'Fold me and send me somewhere new.',
          'Reach every continent.',
          'Find the highest point.',
        ];
      case ObjectType.star:
        return [
          'Find a night sky that takes your breath away.',
          'Shine in 10 countries.',
          'Be someone\'s lucky star.',
        ];
      case ObjectType.seedling:
        return [
          'Plant a small act of hope wherever you are.',
          'Grow something beautiful.',
          'Leave the world greener.',
        ];
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _missionController = TextEditingController(text: widget.mission);
    _noteController = TextEditingController(text: widget.openingNote);
    _goalTargetController = TextEditingController(
      text: widget.goalTarget?.toString() ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _missionController.dispose();
    _noteController.dispose();
    _goalTargetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Object mini preview
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.objectType.accentColor.withAlpha(31),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: ObjectArtworkWidget(type: widget.objectType, size: 32),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Give it a story', style: theme.textTheme.headlineSmall),
                  Text(
                    widget.objectType.displayName,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Name field
          _FormSection(
            label: 'Name',
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OutlinedField(
                  controller: _nameController,
                  hint: 'e.g. The Internet Potato',
                  maxLength: 40,
                  isDark: isDark,
                  onChanged: widget.onNameChanged,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _nameSuggestions
                      .map(
                        (s) => _SuggestionChip(
                          label: s,
                          isDark: isDark,
                          onTap: () {
                            _nameController.text = s;
                            widget.onNameChanged(s);
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Mission field
          _FormSection(
            label: 'Mission',
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _OutlinedField(
                  controller: _missionController,
                  hint: 'e.g. Help me visit 20 countries.',
                  maxLength: 160,
                  maxLines: 3,
                  isDark: isDark,
                  onChanged: widget.onMissionChanged,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: _missionSuggestions
                      .map(
                        (s) => _SuggestionChip(
                          label: s,
                          isDark: isDark,
                          onTap: () {
                            _missionController.text = s;
                            widget.onMissionChanged(s);
                          },
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Opening note
          _FormSection(
            label: 'Opening note (optional)',
            isDark: isDark,
            child: _OutlinedField(
              controller: _noteController,
              hint: 'A personal message to start the journey...',
              maxLength: 240,
              maxLines: 3,
              isDark: isDark,
              onChanged: widget.onOpeningNoteChanged,
            ),
          ),
          const SizedBox(height: 16),
          // Goal
          _FormSection(
            label: 'Goal (optional)',
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _GoalChip(
                      label: 'No goal',
                      isSelected: widget.goalType == GoalType.none,
                      isDark: isDark,
                      onTap: () => widget.onGoalTypeChanged(GoalType.none),
                    ),
                    const SizedBox(width: 8),
                    _GoalChip(
                      label: 'People',
                      isSelected: widget.goalType == GoalType.people,
                      isDark: isDark,
                      onTap: () => widget.onGoalTypeChanged(GoalType.people),
                    ),
                    const SizedBox(width: 8),
                    _GoalChip(
                      label: 'Countries',
                      isSelected: widget.goalType == GoalType.countries,
                      isDark: isDark,
                      onTap: () => widget.onGoalTypeChanged(GoalType.countries),
                    ),
                  ],
                ),
                if (widget.goalType != GoalType.none) ...[
                  const SizedBox(height: 10),
                  _OutlinedField(
                    controller: _goalTargetController,
                    hint: 'Target number (e.g. 20)',
                    maxLength: 4,
                    keyboardType: TextInputType.number,
                    isDark: isDark,
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      widget.onGoalTargetChanged(n);
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Location visibility
          _FormSection(
            label: 'Origin location',
            isDark: isDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _GoalChip(
                      label: 'City',
                      isSelected:
                          widget.originVisibility == LocationVisibility.city,
                      isDark: isDark,
                      onTap: () => widget.onOriginVisibilityChanged(
                        LocationVisibility.city,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _GoalChip(
                      label: 'Country only',
                      isSelected:
                          widget.originVisibility ==
                          LocationVisibility.countryOnly,
                      isDark: isDark,
                      onTap: () => widget.onOriginVisibilityChanged(
                        LocationVisibility.countryOnly,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _GoalChip(
                      label: 'Hidden',
                      isSelected:
                          widget.originVisibility == LocationVisibility.hidden,
                      isDark: isDark,
                      onTap: () => widget.onOriginVisibilityChanged(
                        LocationVisibility.hidden,
                      ),
                    ),
                  ],
                ),
                if (widget.originVisibility == LocationVisibility.city) ...[
                  const SizedBox(height: 10),
                  _CityPickerField(
                    isDark: isDark,
                    onCitySelected: (city, country) {
                      widget.onOriginCityChanged(city);
                      widget.onOriginCountryChanged(country);
                    },
                    selectedCity: widget.originCity,
                    selectedCountry: widget.originCountry,
                  ),
                ],
                if (widget.originVisibility ==
                    LocationVisibility.countryOnly) ...[
                  const SizedBox(height: 10),
                  _CountryPickerField(
                    isDark: isDark,
                    onCountrySelected: widget.onOriginCountryChanged,
                    selectedCountry: widget.originCountry,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FormSection extends StatelessWidget {
  final String label;
  final Widget child;
  final bool isDark;

  const _FormSection({
    required this.label,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

class _OutlinedField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLength;
  final int maxLines;
  final bool isDark;
  final ValueChanged<String> onChanged;
  final TextInputType? keyboardType;

  const _OutlinedField({
    required this.controller,
    required this.hint,
    required this.maxLength,
    required this.isDark,
    required this.onChanged,
    this.maxLines = 1,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onChanged: onChanged,
      maxLength: maxLength,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontSize: 14,
        color: isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
      ),
      decoration: InputDecoration(
        hintText: hint,
        counterStyle: TextStyle(
          fontSize: 11,
          color: isDark
              ? AppTheme.textSecondaryDark
              : AppTheme.textSecondaryLight,
        ),
        filled: true,
        fillColor: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const _SuggestionChip({
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primary.withAlpha(77)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}

class _GoalChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _GoalChip({
    required this.label,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary
              : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}

class _CityPickerField extends StatelessWidget {
  final bool isDark;
  final Function(String city, String country) onCitySelected;
  final String? selectedCity;
  final String? selectedCountry;

  const _CityPickerField({
    required this.isDark,
    required this.onCitySelected,
    required this.selectedCity,
    required this.selectedCountry,
  });

  static const List<Map<String, String>> _cities = [
    {'city': 'Delhi', 'country': 'India'},
    {'city': 'Mumbai', 'country': 'India'},
    {'city': 'Bangalore', 'country': 'India'},
    {'city': 'London', 'country': 'UK'},
    {'city': 'Paris', 'country': 'France'},
    {'city': 'New York', 'country': 'USA'},
    {'city': 'Tokyo', 'country': 'Japan'},
    {'city': 'Dubai', 'country': 'UAE'},
    {'city': 'Singapore', 'country': 'Singapore'},
    {'city': 'Sydney', 'country': 'Australia'},
    {'city': 'São Paulo', 'country': 'Brazil'},
    {'city': 'Lagos', 'country': 'Nigeria'},
    {'city': 'Cairo', 'country': 'Egypt'},
    {'city': 'Berlin', 'country': 'Germany'},
    {'city': 'Toronto', 'country': 'Canada'},
    {'city': 'Seoul', 'country': 'South Korea'},
    {'city': 'Bangkok', 'country': 'Thailand'},
    {'city': 'Buenos Aires', 'country': 'Argentina'},
    {'city': 'Nairobi', 'country': 'Kenya'},
    {'city': 'Stockholm', 'country': 'Sweden'},
  ];

  @override
  Widget build(BuildContext context) {
    final displayText = selectedCity != null
        ? '$selectedCity, $selectedCountry'
        : 'Select a city (limited coverage)';

    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.location_on_rounded, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                displayText,
                style: TextStyle(
                  fontSize: 14,
                  color: selectedCity != null
                      ? (isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight)
                      : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
                ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CityPickerSheet(
        cities: _cities,
        isDark: isDark,
        onSelected: onCitySelected,
      ),
    );
  }
}

class _CityPickerSheet extends StatefulWidget {
  final List<Map<String, String>> cities;
  final bool isDark;
  final Function(String, String) onSelected;

  const _CityPickerSheet({
    required this.cities,
    required this.isDark,
    required this.onSelected,
  });

  @override
  State<_CityPickerSheet> createState() => _CityPickerSheetState();
}

class _CityPickerSheetState extends State<_CityPickerSheet> {
  String _query = '';

  List<Map<String, String>> get _filtered => widget.cities
      .where(
        (c) =>
            c['city']!.toLowerCase().contains(_query.toLowerCase()) ||
            c['country']!.toLowerCase().contains(_query.toLowerCase()),
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: BoxDecoration(
        color: widget.isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: widget.isDark ? AppTheme.borderDark : AppTheme.borderLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose a city',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: widget.isDark
                        ? AppTheme.textPrimaryDark
                        : AppTheme.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Limited to representative cities',
                  style: TextStyle(
                    fontSize: 12,
                    color: widget.isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) => setState(() => _query = v),
                  decoration: InputDecoration(
                    hintText: 'Search cities...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 18),
                    filled: true,
                    fillColor: widget.isDark
                        ? AppTheme.backgroundDark
                        : AppTheme.backgroundLight,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.only(bottom: bottomPadding),
              itemCount: _filtered.length,
              itemBuilder: (context, i) {
                final city = _filtered[i];
                return ListTile(
                  leading: Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  title: Text(city['city']!),
                  subtitle: Text(city['country']!),
                  onTap: () {
                    widget.onSelected(city['city']!, city['country']!);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CountryPickerField extends StatelessWidget {
  final bool isDark;
  final ValueChanged<String?> onCountrySelected;
  final String? selectedCountry;

  static const List<String> _countries = [
    'India',
    'UK',
    'USA',
    'Japan',
    'UAE',
    'Singapore',
    'Australia',
    'Brazil',
    'Nigeria',
    'Egypt',
    'Germany',
    'Canada',
    'South Korea',
    'Thailand',
    'Argentina',
    'Kenya',
    'Sweden',
    'France',
    'Ghana',
    'Morocco',
    'China',
    'Indonesia',
    'Mexico',
    'South Africa',
    'Turkey',
    'Italy',
  ];

  const _CountryPickerField({
    required this.isDark,
    required this.onCountrySelected,
    required this.selectedCountry,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.public_rounded, size: 16, color: AppTheme.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selectedCountry ?? 'Select a country',
                style: TextStyle(
                  fontSize: 14,
                  color: selectedCountry != null
                      ? (isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight)
                      : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
                ),
              ),
            ),
            Icon(
              Icons.expand_more_rounded,
              size: 18,
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.55,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 16),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _countries.length,
                itemBuilder: (ctx, i) => ListTile(
                  leading: Icon(
                    Icons.public_rounded,
                    size: 18,
                    color: AppTheme.primary,
                  ),
                  title: Text(_countries[i]),
                  onTap: () {
                    onCountrySelected(_countries[i]);
                    Navigator.pop(ctx);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
