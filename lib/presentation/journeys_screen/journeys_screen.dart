import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/data/sample_data.dart';
import '../../core/models/journey_models.dart';
import '../../core/repositories/journey_repository.dart';
import '../../core/services/nearby_journeys.dart';
import '../../routes/app_routes.dart';
import '../onboarding_screen/widgets/object_artwork_widget.dart';
import 'widgets/discovery_area_sheet.dart';
import 'widgets/journey_discovery_widgets.dart';

class JourneysScreen extends StatefulWidget {
  final JourneyRepository? repository;
  final NearbyLocationService? locationService;
  const JourneysScreen({this.repository, this.locationService, super.key});
  @override
  State<JourneysScreen> createState() => _JourneysScreenState();
}

class _JourneysScreenState extends State<JourneysScreen> {
  late final JourneyRepository _repo =
      widget.repository ?? JourneyRepository.instance;
  DiscoveryArea? _area;
  ObjectType? _type;
  bool _everywhere = false;
  double _radius = 50;
  int _collection = 0;
  bool _saving = false;
  static const _areaKey = 'journey_discovery_city_v1';

  @override
  void initState() {
    super.initState();
    _restoreArea();
  }

  Future<void> _restoreArea() async {
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString(_areaKey);
    for (final city in discoveryCities) {
      if ('${city.city}|${city.country}' == key && mounted) {
        setState(() => _area = city);
      }
    }
  }

  Future<void> _chooseArea() async {
    final area = await showModalBottomSheet<DiscoveryArea>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: JourneyColors(context).surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => DiscoveryAreaSheet(
        service: widget.locationService ?? NearbyLocationService(),
      ),
    );
    if (area == null || !mounted) return;
    setState(() {
      _area = area;
      _everywhere = false;
    });
    final prefs = await SharedPreferences.getInstance();
    if (area.fromDevice) {
      await prefs.remove(_areaKey);
    } else {
      await prefs.setString(_areaKey, '${area.city}|${area.country}');
    }
  }

  void _open(JourneyObject journey) => context.push(
    '${AppRoutes.journeyDetailScreen}?id=${Uri.encodeComponent(journey.id)}',
  );
  void _create() => context.push(AppRoutes.createJourneyScreen);

  Future<void> _save(JourneyObject journey) async {
    setState(() => _saving = true);
    try {
      await _repo.follow(journey.id, !journey.isFollowed);
      HapticFeedback.selectionClick();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t save that change. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _howItWorks() {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (context) => SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(26, 0, 26, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Little moments. Lasting stories.',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 20),
              for (final step in const [
                (
                  '01',
                  'Find your little traveller',
                  'Meet an object nearby or give a new one a name and a mission.',
                ),
                (
                  '02',
                  'Become part of the story',
                  'Join a journey and leave a kind note. Your chapter stays in its timeline.',
                ),
                (
                  '03',
                  'Let the story keep going',
                  'Save a favourite and pass its invitation to someone who might love it.',
                ),
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundColor: JourneyColors(context).sage,
                        child: Text(
                          step.$1,
                          style: TextStyle(
                            color: JourneyColors(context).ink,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              step.$2,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 5),
                            Text(
                              step.$3,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Let’s explore'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = JourneyColors(context);
    return Scaffold(
      backgroundColor: c.canvas,
      body: ListenableBuilder(
        listenable: _repo,
        builder: (context, _) {
          final items = discoverJourneys(
            _repo.journeys,
            _repo.stops,
            area: _everywhere ? null : _area,
            radiusKm: _radius,
            type: _type,
          );
          final personal = _repo.journeys.where((j) {
            final started = j.creatorId == kLocalUserId;
            final joined = _repo.stops.any(
              (s) =>
                  s.objectId == j.id &&
                  s.participantId == kLocalUserId &&
                  !s.isOrigin,
            );
            return switch (_collection) {
              1 => started,
              2 => joined,
              3 => j.isFollowed,
              _ => started || joined || j.isFollowed,
            };
          }).toList();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: CustomScrollView(
                key: const PageStorageKey('journey-home-scroll'),
                slivers: [
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      22,
                      MediaQuery.paddingOf(context).top + 20,
                      22,
                      0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _header(c),
                          const SizedBox(height: 24),
                          JourneyWelcome(onCreate: _create),
                          const SizedBox(height: 28),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _area != null && !_everywhere
                                          ? 'Around your corner'
                                          : 'Find your next connection',
                                      style: TextStyle(
                                        fontSize: 22,
                                        letterSpacing: -.65,
                                        fontWeight: FontWeight.w700,
                                        color: c.ink,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      _area != null && !_everywhere
                                          ? 'Within ${_radius.round()} km · approximate city locations'
                                          : 'Little travellers. A world of possibility.',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: c.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_area != null)
                                PopupMenuButton<int>(
                                  tooltip: 'Discovery distance',
                                  icon: Icon(
                                    Icons.tune_rounded,
                                    color: c.ink,
                                    size: 21,
                                  ),
                                  onSelected: (value) => setState(() {
                                    _everywhere = value == 0;
                                    if (value > 0) _radius = value.toDouble();
                                  }),
                                  itemBuilder: (_) => const [
                                    PopupMenuItem(
                                      value: 50,
                                      child: Text('Within 50 km'),
                                    ),
                                    PopupMenuItem(
                                      value: 250,
                                      child: Text('Within 250 km'),
                                    ),
                                    PopupMenuItem(
                                      value: 0,
                                      child: Text('Explore everywhere'),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                          if (_area == null) ...[
                            const SizedBox(height: 16),
                            _locationPrompt(c),
                          ],
                          const SizedBox(height: 15),
                        ],
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(child: _objectFilters(c)),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: items.isEmpty
                          ? Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 22,
                              ),
                              child: _emptyNearby(c),
                            )
                          : SizedBox(
                              height: 316,
                              child: ListView.separated(
                                key: ValueKey(
                                  '${_type?.name}-${_area?.label}-$_everywhere-$_radius',
                                ),
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                ),
                                itemCount: items.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 14),
                                itemBuilder: (context, i) => SizedBox(
                                  width: 238,
                                  child: DiscoveryJourneyCard(
                                    item: items[i],
                                    onOpen: () => _open(items[i].journey),
                                    saving: _saving,
                                    onSave: () => _save(items[i].journey),
                                  ),
                                ),
                              ),
                            ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 26, 22, 0),
                    sliver: SliverToBoxAdapter(
                      child: Material(
                        color: c.sage,
                        borderRadius: BorderRadius.circular(22),
                        child: InkWell(
                          onTap: _howItWorks,
                          borderRadius: BorderRadius.circular(22),
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Row(
                              children: [
                                ObjectArtworkWidget(
                                  type: ObjectType.seedling,
                                  size: 48,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Good things grow when shared.',
                                        style: TextStyle(
                                          color: c.ink,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        'Find it. Add your chapter. Pass it on.',
                                        style: TextStyle(
                                          color: c.muted,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: c.ink,
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 30, 22, 0),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your little world',
                            style: TextStyle(
                              fontSize: 22,
                              letterSpacing: -.65,
                              fontWeight: FontWeight.w700,
                              color: c.ink,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Every connection leaves a little mark.',
                            style: TextStyle(fontSize: 11, color: c.muted),
                          ),
                          const SizedBox(height: 15),
                          Wrap(
                            spacing: 7,
                            runSpacing: 7,
                            children: List.generate(
                              4,
                              (i) => ChoiceChip(
                                label: Text(
                                  const [
                                    'All',
                                    'Started',
                                    'Joined',
                                    'Saved',
                                  ][i],
                                ),
                                selected: _collection == i,
                                showCheckmark: false,
                                selectedColor: c.sage,
                                backgroundColor: c.canvas,
                                labelStyle: TextStyle(
                                  fontSize: 11,
                                  color: c.ink,
                                ),
                                side: BorderSide(
                                  color: _collection == i
                                      ? Colors.transparent
                                      : c.line,
                                ),
                                shape: const StadiumBorder(),
                                onSelected: (_) =>
                                    setState(() => _collection = i),
                              ),
                            ),
                          ),
                          const SizedBox(height: 15),
                          if (personal.isEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: c.surface,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(color: c.line),
                              ),
                              child: Column(
                                children: [
                                  ObjectArtworkWidget(
                                    type: ObjectType.paperPlane,
                                    size: 70,
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _collection == 3
                                        ? 'Make room for a favourite.'
                                        : 'Your next chapter is waiting.',
                                    style: TextStyle(
                                      color: c.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _collection == 3
                                        ? 'Tap a bookmark on a traveller you love.'
                                        : 'Start a journey or join one that speaks to you.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: c.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                  if (_collection != 3)
                                    TextButton(
                                      onPressed: _create,
                                      child: const Text('Start a journey'),
                                    ),
                                ],
                              ),
                            ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final width = constraints.maxWidth > 650
                                  ? (constraints.maxWidth - 14) / 2
                                  : constraints.maxWidth;
                              return Wrap(
                                spacing: 14,
                                runSpacing: 12,
                                children: personal
                                    .map(
                                      (j) => SizedBox(
                                        width: width,
                                        child: PersonalJourneyCard(
                                          journey: j,
                                          stops: _repo.stops,
                                          onOpen: () => _open(j),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              );
                            },
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: Text(
                              'A small act can travel a long way.',
                              style: TextStyle(
                                color: c.muted,
                                fontSize: 11,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              'Preview journeys are examples. Your creations are saved on this device.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: c.muted,
                                fontSize: 9,
                                height: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _header(JourneyColors c) => Row(
    children: [
      Container(
        width: 39,
        height: 39,
        decoration: BoxDecoration(color: c.sage, shape: BoxShape.circle),
        child: const Icon(
          Icons.all_inclusive_rounded,
          color: JourneyColors.green,
          size: 26,
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'pass it on',
              style: TextStyle(
                fontSize: 22,
                letterSpacing: -.8,
                color: c.ink,
                fontWeight: FontWeight.w800,
              ),
            ),
            InkWell(
              onTap: _chooseArea,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.near_me_outlined, size: 12, color: c.muted),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        _area?.label ?? 'Find objects near you',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: c.muted, fontSize: 10),
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 16,
                      color: c.muted,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'How journeys work',
        onPressed: _howItWorks,
        icon: Icon(Icons.auto_awesome_outlined, color: c.ink, size: 21),
      ),
      IconButton(
        tooltip: 'Your profile',
        onPressed: () => context.go(AppRoutes.youScreen),
        style: IconButton.styleFrom(
          backgroundColor: c.surface,
          side: BorderSide(color: c.line),
        ),
        icon: Icon(Icons.person_outline_rounded, color: c.ink, size: 21),
      ),
    ],
  );

  Widget _locationPrompt(JourneyColors c) => Material(
    color: c.sage,
    borderRadius: BorderRadius.circular(18),
    child: InkWell(
      onTap: _chooseArea,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.radar_rounded, color: c.ink, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Something lovely could be close by.',
                    style: TextStyle(
                      color: c.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Choose your area to discover nearby objects',
                    style: TextStyle(color: c.muted, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_forward_rounded, color: c.ink, size: 17),
          ],
        ),
      ),
    ),
  );

  Widget _objectFilters(JourneyColors c) => SizedBox(
    height: 42,
    child: ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      scrollDirection: Axis.horizontal,
      itemCount: ObjectType.values.length + 1,
      separatorBuilder: (_, __) => const SizedBox(width: 8),
      itemBuilder: (context, i) {
        final type = i == 0 ? null : ObjectType.values[i - 1];
        final selected = _type == type;
        return ChoiceChip(
          showCheckmark: false,
          selected: selected,
          avatar: type == null
              ? Icon(
                  Icons.apps_rounded,
                  size: 16,
                  color: selected ? Colors.white : c.ink,
                )
              : ObjectArtworkWidget(type: type, size: 24),
          label: Text(type?.displayName ?? 'All objects'),
          labelStyle: TextStyle(
            color: selected ? Colors.white : c.ink,
            fontSize: 11,
          ),
          selectedColor: JourneyColors.green,
          backgroundColor: c.surface,
          side: BorderSide(color: selected ? JourneyColors.green : c.line),
          shape: const StadiumBorder(),
          onSelected: (_) {
            HapticFeedback.selectionClick();
            setState(() => _type = type);
          },
        );
      },
    ),
  );

  Widget _emptyNearby(JourneyColors c) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: c.surface,
      borderRadius: BorderRadius.circular(26),
      border: Border.all(color: c.line),
    ),
    child: Column(
      children: [
        ObjectShowcase(type: _type ?? ObjectType.lotus, size: 110),
        Text(
          'A little quiet around here.',
          style: TextStyle(
            color: c.ink,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'No matching journeys in this area yet.\nStart one, or explore a little further.',
          textAlign: TextAlign.center,
          style: TextStyle(color: c.muted, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            FilledButton(
              onPressed: _create,
              child: const Text('Start a journey'),
            ),
            TextButton(
              onPressed: () => setState(() {
                _everywhere = true;
                _type = null;
              }),
              child: const Text('Explore everywhere'),
            ),
          ],
        ),
      ],
    ),
  );
}
