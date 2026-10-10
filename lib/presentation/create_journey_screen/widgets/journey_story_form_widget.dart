import 'package:flutter/material.dart';
import '../../../core/models/journey_models.dart';

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
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
      children: [
        Text('Give it a story', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 8),
        const Text('A name and a simple mission are all you need.'),
        const SizedBox(height: 28),
        TextField(
          controller: _nameController,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          onChanged: widget.onNameChanged,
          decoration: InputDecoration(
            labelText: 'Journey name',
            hintText: 'e.g. Spud the Explorer',
            helperText: 'At least 3 characters',
            errorText: widget.name.isNotEmpty && widget.name.trim().length < 3
                ? 'Use at least 3 characters.'
                : null,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _nameSuggestions
              .take(2)
              .map(
                (name) => ActionChip(
                  label: Text(name),
                  onPressed: () {
                    _nameController.text = name;
                    widget.onNameChanged(name);
                  },
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 24),
        TextField(
          controller: _missionController,
          maxLength: 160,
          minLines: 2,
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
          onChanged: widget.onMissionChanged,
          decoration: InputDecoration(
            labelText: 'Its mission',
            hintText: 'What would you like it to inspire?',
            helperText: 'At least 5 characters',
            errorText:
                widget.mission.isNotEmpty && widget.mission.trim().length < 5
                ? 'Use at least 5 characters.'
                : null,
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              final mission = _missionSuggestions.first;
              _missionController.text = mission;
              widget.onMissionChanged(mission);
            },
            icon: const Icon(Icons.auto_awesome_outlined, size: 18),
            label: const Text('Use a suggested mission'),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: ExpansionTile(
            key: const PageStorageKey('optional-story-details'),
            shape: const Border(),
            collapsedShape: const Border(),
            title: const Text('Add a little more'),
            subtitle: const Text('Optional note and goal'),
            childrenPadding: const EdgeInsets.all(20),
            children: [
              TextField(
                controller: _noteController,
                maxLength: 240,
                minLines: 2,
                maxLines: 4,
                onChanged: widget.onOpeningNoteChanged,
                decoration: const InputDecoration(
                  labelText: 'Opening note',
                  hintText: 'A kind word for the next person…',
                ),
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: Text('Set a goal', style: theme.textTheme.titleMedium),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final option in [
                      (GoalType.none, 'No goal'),
                      (GoalType.people, 'People'),
                      (GoalType.countries, 'Countries'),
                    ])
                      ChoiceChip(
                        label: Text(option.$2),
                        selected: widget.goalType == option.$1,
                        onSelected: (_) => widget.onGoalTypeChanged(option.$1),
                      ),
                  ],
                ),
              ),
              if (widget.goalType != GoalType.none) ...[
                const SizedBox(height: 16),
                TextField(
                  controller: _goalTargetController,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  onChanged: (v) => widget.onGoalTargetChanged(int.tryParse(v)),
                  decoration: const InputDecoration(
                    labelText: 'Target number',
                    helperText: 'Enter a whole number greater than zero.',
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text('Starting location', style: theme.textTheme.titleLarge),
        const SizedBox(height: 8),
        Text(
          'Choose what appears in your first chapter.',
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final option in [
              (LocationVisibility.hidden, 'Hidden'),
              (LocationVisibility.countryOnly, 'Country only'),
              (LocationVisibility.city, 'City'),
            ])
              ChoiceChip(
                label: Text(option.$2),
                selected: widget.originVisibility == option.$1,
                onSelected: (_) => widget.onOriginVisibilityChanged(option.$1),
              ),
          ],
        ),
        if (widget.originVisibility != LocationVisibility.hidden) ...[
          const SizedBox(height: 16),
          if (widget.originVisibility == LocationVisibility.city) ...[
            TextFormField(
              key: const ValueKey('origin-city'),
              initialValue: widget.originCity,
              maxLength: 60,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'City',
                hintText: 'e.g. Mumbai',
              ),
              onChanged: widget.onOriginCityChanged,
            ),
            const SizedBox(height: 12),
          ],
          TextFormField(
            key: const ValueKey('origin-country'),
            initialValue: widget.originCountry,
            maxLength: 60,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Country',
              hintText: 'e.g. India',
            ),
            onChanged: widget.onOriginCountryChanged,
          ),
        ],
        const SizedBox(height: 16),
        Text(
          widget.originVisibility == LocationVisibility.hidden
              ? 'Your location stays private.'
              : 'Only the location you enter is shown. Your precise device location is never published.',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
