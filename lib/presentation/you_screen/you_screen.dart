import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/data/sample_data.dart';
import '../../core/data/gift_catalogue.dart';
import '../../core/models/journey_models.dart';
import '../../core/repositories/journey_repository.dart';
import '../../core/repositories/gift_repository.dart';
import '../../core/theme_notifier.dart';
import '../../core/motion_notifier.dart';
import '../../core/modal_notifier.dart';
import '../../routes/app_routes.dart';
import '../../widgets/page_layout.dart';
import '../gifts/widgets/gift_artwork_widget.dart';

class YouScreen extends StatefulWidget {
  const YouScreen({super.key});
  @override
  State<YouScreen> createState() => _YouScreenState();
}

class _YouScreenState extends State<YouScreen> {
  final _repo = JourneyRepository.instance;
  final _gifts = GiftRepository();
  String _name = 'Traveller';
  String _theme = 'System';
  String _visibility = 'hidden';
  bool _motion = false;
  bool _haptics = true;
  bool _resetting = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _name = prefs.getString('display_name') ?? 'Traveller';
      _theme = prefs.getString('theme_mode') ?? 'System';
      _visibility = prefs.getString('default_location') ?? 'hidden';
      _motion = prefs.getBool('reduce_motion') ?? false;
      _haptics = prefs.getBool('haptics') ?? true;
    });
  }

  Future<void> _save(String key, Object value) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = value is bool
          ? await prefs.setBool(key, value)
          : await prefs.setString(key, value as String);
      if (!saved) throw StateError('Save failed');
      if (key == 'theme_mode') await initThemeMode();
      if (key == 'reduce_motion') reduceMotionNotifier.value = value as bool;
      if (key == 'haptics') hapticsNotifier.value = value as bool;
      await _load();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t save your preference. Please try again.'),
          ),
        );
      }
    }
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _name);
    final result = await showManagedDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Your display name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 30,
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(
            labelText: 'Name',
            helperText: 'Used for new journeys and chapters.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Save name'),
          ),
        ],
      ),
    );
    if (result != null) await _save('display_name', result);
    // The dialog's route transition can still reference its controller.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    controller.dispose();
  }

  void _info(String title, String body) => showManagedDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(child: Text(body)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Got it'),
        ),
      ],
    ),
  );

  Future<void> _reset() async {
    final confirmed = await showManagedDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset this device?'),
        content: const Text(
          'Your created journeys, chapters, saved items, gifts, and preferences will be removed. The original preview journeys will return. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Keep my data'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset app data'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _resetting = true);
    try {
      await _repo.reset();
      await _gifts.reset();
      final prefs = await SharedPreferences.getInstance();
      for (final key in [
        'display_name',
        'theme_mode',
        'reduce_motion',
        'haptics',
        'default_location',
        'journey_discovery_city_v1',
        'onboarding_seen',
      ]) {
        await prefs.remove(key);
      }
      await initThemeMode();
      await initMotionPreference();
      await _load();
      if (mounted) context.go(AppRoutes.onboardingScreen);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reset could not finish. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _resetting = false);
    }
  }

  void _activity(String title, List<JourneyObject> journeys) {
    showManagedModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            if (journeys.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Nothing here yet. Explore a journey or start your own.',
                ),
              ),
            Expanded(
              child: ListView.separated(
                itemCount: journeys.length,
                separatorBuilder: (_, _) => const Divider(),
                itemBuilder: (context, i) => ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  title: Text(journeys[i].name),
                  subtitle: Text(
                    journeys[i].mission,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.arrow_forward_rounded),
                  onTap: () {
                    Navigator.pop(context);
                    this.context.push(
                      '${AppRoutes.journeyDetailScreen}?id=${Uri.encodeComponent(journeys[i].id)}',
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showGifts() {
    final gifts = _gifts.getGiftsSentByUser(kLocalUserId);
    showManagedModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      builder: (context) => SizedBox(
        height: MediaQuery.sizeOf(context).height * .65,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
              child: Text(
                'Gifts you’ve sent',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            if (gifts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Join a journey to leave a little gift for its adventure.',
                ),
              ),
            Expanded(
              child: ListView.builder(
                itemCount: gifts.length,
                itemBuilder: (context, i) {
                  final gift = gifts[i];
                  final item = catalogItemById(gift.catalogueGiftId);
                  final journey = _repo.find(gift.objectId);
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    leading: item == null
                        ? const Icon(Icons.card_giftcard_outlined)
                        : GiftArtworkWidget(item: item, size: 44),
                    title: Text(item?.name ?? 'Gift'),
                    subtitle: Text(
                      journey?.name ?? 'Journey no longer available',
                    ),
                    trailing: journey == null
                        ? null
                        : const Icon(Icons.chevron_right_rounded),
                    onTap: journey == null
                        ? null
                        : () {
                            Navigator.pop(context);
                            this.context.push(
                              '${AppRoutes.journeyDetailScreen}?id=${Uri.encodeComponent(journey.id)}',
                            );
                          },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title, List<Widget> children) => Padding(
    padding: const EdgeInsets.only(top: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(indent: 20, endIndent: 20),
                children[i],
              ],
            ],
          ),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: PageFrame(
      maxWidth: 800,
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([_repo, _gifts]),
          builder: (context, _) {
            final started = _repo.journeys
                .where((j) => j.creatorId == kLocalUserId)
                .toList();
            final joinedIds = _repo.stops
                .where((s) => s.participantId == kLocalUserId && !s.isOrigin)
                .map((s) => s.objectId)
                .toSet();
            final joined = _repo.journeys
                .where((j) => joinedIds.contains(j.id))
                .toList();
            final saved = _repo.journeys.where((j) => j.isFollowed).toList();
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              children: [
                const PageHeading(
                  title: 'You',
                  subtitle: 'Your journeys, your little corner of the world.',
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                          child: const Icon(
                            Icons.person_outline_rounded,
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Personal profile · this device',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: 'Edit display name',
                          onPressed: _editName,
                          icon: const Icon(Icons.edit_outlined),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                LayoutBuilder(
                  builder: (context, box) => Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      for (final entry in [
                        ('Started', started),
                        ('Joined', joined),
                        ('Saved', saved),
                      ])
                        SizedBox(
                          width: (box.maxWidth - 24) / 3,
                          child: Card(
                            clipBehavior: Clip.antiAlias,
                            child: InkWell(
                              onTap: () =>
                                  _activity('${entry.$1} journeys', entry.$2),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 20,
                                  horizontal: 4,
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      '${entry.$2.length}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      entry.$1,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                _section('Your activity', [
                  ListTile(
                    leading: const Icon(Icons.card_giftcard_outlined),
                    title: const Text('Gifts you’ve sent'),
                    subtitle: Text(
                      '${_gifts.getGiftsSentByUser(kLocalUserId).length} gifts along the way',
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: _showGifts,
                  ),
                ]),
                _section('Make it yours', [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Appearance',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final mode in ['System', 'Light', 'Dark'])
                              ChoiceChip(
                                label: Text(mode),
                                selected: _theme == mode,
                                onSelected: (_) => _save('theme_mode', mode),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Reduce motion'),
                    subtitle: const Text(
                      'Use calmer transitions and still artwork.',
                    ),
                    value: _motion,
                    onChanged: (v) => _save('reduce_motion', v),
                  ),
                  SwitchListTile.adaptive(
                    title: const Text('Touch feedback'),
                    subtitle: const Text(
                      'Gentle haptics on supported devices.',
                    ),
                    value: _haptics,
                    onChanged: (v) => _save('haptics', v),
                  ),
                ]),
                _section('Privacy', [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location on new journeys',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Choose what your starting chapter shows. You can change it when creating a journey.',
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final option in [
                              ('hidden', 'Hidden'),
                              ('countryOnly', 'Country'),
                              ('city', 'City'),
                            ])
                              ChoiceChip(
                                label: Text(option.$2),
                                selected: _visibility == option.$1,
                                onSelected: (_) =>
                                    _save('default_location', option.$1),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ]),
                _section('Help & about', [
                  ListTile(
                    leading: const Icon(Icons.help_outline_rounded),
                    title: const Text('How journeys work'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _info(
                      'How journeys work',
                      '1. Find a journey or create one. Each object has a name and a mission.\n\n2. Join and leave a kind note. Your chapter becomes part of the timeline.\n\n3. Save favourites, leave a gift, or share an invitation to keep the story going.\n\nPreview journeys are examples. Your changes are stored on this device.',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded),
                    title: const Text('About Pass It On'),
                    subtitle: const Text('Version 1.0 · local preview'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _info(
                      'Small things. Big stories.',
                      'Pass It On connects little objects with acts of kindness.\n\nThis version is a local preview: journeys, gifts, and preferences are saved on this device. There is no shared account, cloud sync, payment processing, or notification delivery.\n\nClearing your browser or app storage removes your local data.',
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.replay_rounded),
                    title: const Text('Replay the introduction'),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => context.go(AppRoutes.onboardingScreen),
                  ),
                ]),
                const SizedBox(height: 28),
                const InfoNotice(
                  'Your activity is saved on this device. Preview journeys help you try things out.',
                  icon: Icons.devices_outlined,
                ),
                const SizedBox(height: 20),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                  onPressed: _resetting ? null : _reset,
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: Text(_resetting ? 'Resetting…' : 'Reset app data'),
                ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
