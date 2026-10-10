import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/models/journey_models.dart';
import '../../core/repositories/journey_repository.dart';
import '../../core/repositories/gift_repository.dart';
import '../../routes/app_routes.dart';
import '../../widgets/page_layout.dart';
import '../onboarding_screen/widgets/object_artwork_widget.dart';

class ExploreScreen extends StatefulWidget {
  final JourneyRepository? repository;
  const ExploreScreen({this.repository, super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late final _repo = widget.repository ?? JourneyRepository.instance;
  final _search = TextEditingController();
  ObjectType? _type;
  bool _savedOnly = false;
  String _sort = 'Newest';
  final Set<String> _saving = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _save(JourneyObject journey) async {
    setState(() => _saving.add(journey.id));
    try {
      await _repo.follow(journey.id, !journey.isFollowed);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Couldn’t save this journey. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving.remove(journey.id));
    }
  }

  void _clear() => setState(() {
    _search.clear();
    _type = null;
    _savedOnly = false;
  });

  @override
  Widget build(BuildContext context) => Scaffold(
    body: PageFrame(
      child: SafeArea(
        bottom: false,
        child: ListenableBuilder(
          listenable: Listenable.merge([_repo, GiftRepository()]),
          builder: (context, _) {
            final query = _search.text.trim().toLowerCase();
            final journeys = _repo.journeys
                .where(
                  (j) =>
                      (query.isEmpty ||
                          '${j.name} ${j.mission} ${j.type.displayName}'
                              .toLowerCase()
                              .contains(query)) &&
                      (_type == null || j.type == _type) &&
                      (!_savedOnly || j.isFollowed),
                )
                .toList();
            journeys.sort(
              (a, b) => switch (_sort) {
                'Name' => a.name.compareTo(b.name),
                'Most supported' =>
                  GiftRepository()
                      .getSummary(b.id)
                      .distinctSupporters
                      .compareTo(
                        GiftRepository().getSummary(a.id).distinctSupporters,
                      ),
                _ => b.createdAt.compareTo(a.createdAt),
              },
            );
            final filtered = query.isNotEmpty || _type != null || _savedOnly;
            return CustomScrollView(
              key: const PageStorageKey('explore-scroll'),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  sliver: SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const PageHeading(
                          title: 'Explore',
                          subtitle: 'Find a story you’d love to be part of.',
                        ),
                        const SizedBox(height: 24),
                        TextField(
                          controller: _search,
                          onChanged: (_) => setState(() {}),
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search journeys, missions, or objects',
                            prefixIcon: const Icon(Icons.search_rounded),
                            suffixIcon: query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: 'Clear search',
                                    onPressed: () => setState(_search.clear),
                                    icon: const Icon(Icons.close_rounded),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ChoiceChip(
                              label: const Text('All objects'),
                              selected: _type == null,
                              onSelected: (_) => setState(() => _type = null),
                            ),
                            for (final type in ObjectType.values)
                              ChoiceChip(
                                label: Text(type.displayName),
                                selected: _type == type,
                                onSelected: (_) => setState(() => _type = type),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 12,
                          runSpacing: 8,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            FilterChip(
                              avatar: const Icon(
                                Icons.bookmark_outline_rounded,
                                size: 18,
                              ),
                              label: const Text('Saved only'),
                              selected: _savedOnly,
                              onSelected: (v) => setState(() => _savedOnly = v),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'Sort journeys',
                              initialValue: _sort,
                              onSelected: (v) => setState(() => _sort = v),
                              itemBuilder: (_) => [
                                for (final value in [
                                  'Newest',
                                  'Name',
                                  'Most supported',
                                ])
                                  PopupMenuItem(
                                    value: value,
                                    child: Text(value),
                                  ),
                              ],
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                  horizontal: 8,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.sort_rounded, size: 20),
                                    const SizedBox(width: 8),
                                    Text(_sort),
                                    const Icon(
                                      Icons.expand_more_rounded,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (filtered)
                              TextButton(
                                onPressed: _clear,
                                child: const Text('Clear filters'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const InfoNotice(
                          'Preview journeys are examples. Your journeys and saved items stay on this device.',
                        ),
                        const SizedBox(height: 28),
                        Semantics(
                          liveRegion: true,
                          child: Text(
                            '${journeys.length} ${journeys.length == 1 ? 'journey' : 'journeys'}${filtered ? ' found' : ' to discover'}',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
                if (journeys.isEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.all(24),
                    sliver: SliverToBoxAdapter(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(28),
                          child: Column(
                            children: [
                              const ObjectArtworkWidget(
                                type: ObjectType.paperPlane,
                                size: 100,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No journeys found',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Try another search or clear your filters.',
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 20),
                              OutlinedButton(
                                onPressed: _clear,
                                child: const Text('Clear filters'),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.crossAxisExtent >= 840
                            ? 3
                            : constraints.crossAxisExtent >= 560
                            ? 2
                            : 1;
                        // Rows size to their content, including the user's text scale.
                        return SliverList.builder(
                          itemCount: (journeys.length / columns).ceil(),
                          itemBuilder: (context, row) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (var col = 0; col < columns; col++) ...[
                                  if (col > 0) const SizedBox(width: 16),
                                  Expanded(
                                    child:
                                        row * columns + col >= journeys.length
                                        ? const SizedBox.shrink()
                                        : _card(journeys[row * columns + col]),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            );
          },
        ),
      ),
    ),
  );

  Widget _card(JourneyObject journey) {
    final colors = Theme.of(context).colorScheme;
    final stops = _repo.stops.where((s) => s.objectId == journey.id).length;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Material(
                color: journey.type.accentColor.withAlpha(24),
                child: InkWell(
                  onTap: () => context.push(
                    '${AppRoutes.journeyDetailScreen}?id=${Uri.encodeComponent(journey.id)}',
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 180,
                    child: Center(
                      child: ObjectArtworkWidget(type: journey.type, size: 150),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    journey.isSampleData ? 'Preview' : 'Your journey',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
              ),
              Positioned(
                top: 6,
                right: 6,
                child: IconButton.filledTonal(
                  tooltip:
                      '${journey.isFollowed ? 'Unsave' : 'Save'} ${journey.name}',
                  onPressed: _saving.contains(journey.id)
                      ? null
                      : () => _save(journey),
                  icon: Icon(
                    journey.isFollowed
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  journey.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  journey.mission,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '$stops ${stops == 1 ? 'chapter' : 'chapters'} · ${journey.state == JourneyState.active ? 'Active' : 'Archived'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                      '${AppRoutes.journeyDetailScreen}?id=${Uri.encodeComponent(journey.id)}',
                    ),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('View journey'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
