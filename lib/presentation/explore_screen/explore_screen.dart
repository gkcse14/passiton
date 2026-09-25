import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/models/journey_models.dart';
import '../../core/models/gift_models.dart';
import '../../core/repositories/gift_repository.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../onboarding_screen/widgets/object_artwork_widget.dart';
import '../gifts/widgets/gift_artwork_widget.dart';
import './widgets/explore_journey_card_widget.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  late List<JourneyObject> _allJourneys;
  late List<JourneyStop> _allStops;
  List<JourneyObject> _filtered = [];
  String _searchQuery = '';
  ObjectType? _filterType;
  final bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  final _giftRepo = GiftRepository();

  @override
  void initState() {
    super.initState();
    _allJourneys = sampleJourneyMaps.map(JourneyObject.fromMap).toList();
    _allStops = sampleStopMaps.map(JourneyStop.fromMap).toList();
    _filtered = List.from(_allJourneys);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    setState(() {
      _filtered = _allJourneys.where((j) {
        final matchesSearch =
            _searchQuery.isEmpty ||
            j.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            j.mission.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesType = _filterType == null || j.type == _filterType;
        return matchesSearch && matchesType;
      }).toList();
    });
  }

  void _toggleFollow(JourneyObject journey) {
    setState(() {
      final idx = _allJourneys.indexWhere((j) => j.id == journey.id);
      if (idx >= 0) {
        _allJourneys[idx] = _allJourneys[idx].copyWith(
          isFollowed: !journey.isFollowed,
        );
        _applyFilters();
      }
    });
  }

  List<JourneyObject> get _featured =>
      _allJourneys.where((j) => j.isSampleData).take(3).toList();

  List<JourneyObject> get _kindness => _allJourneys
      .where((j) => j.type == ObjectType.heart || j.type == ObjectType.seedling)
      .toList();

  List<JourneyObject> get _justStarted => _allJourneys
      .where((j) => DateTime.now().difference(j.createdAt).inDays < 60)
      .take(4)
      .toList();

  /// Journeys with at least one gift, sorted by supporter count
  List<JourneyObject> get _lovedJourneys {
    final eligibleIds = _allJourneys
        .where((j) => j.state == JourneyState.active && j.isSampleData)
        .map((j) => j.id)
        .toList();
    final ranked = _giftRepo.rankByMostSupported(eligibleIds);
    return ranked
        .where((id) => _giftRepo.getSummary(id).totalGifts > 0)
        .map(
          (id) => _allJourneys.firstWhere(
            (j) => j.id == id,
            orElse: () => _allJourneys.first,
          ),
        )
        .take(6)
        .toList();
  }

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
              child: _buildHeader(theme, isDark),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: _buildSearchBar(isDark),
            ),
          ),
          SliverToBoxAdapter(child: _buildTypeFilters(isDark)),
          // Sample content note
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 13,
                      color: AppTheme.secondary,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Explore currently shows sample journeys',
                      style: TextStyle(fontSize: 12, color: AppTheme.secondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty || _filterType != null)
            _buildSearchResults(isDark, theme)
          else ...[
            // Loved along the way section
            if (_lovedJourneys.isNotEmpty) ...[
              SliverToBoxAdapter(child: _buildLovedHeader(isDark, theme)),
              SliverToBoxAdapter(
                child: _buildLovedSection(_lovedJourneys, isDark),
              ),
            ],
            // Featured section
            SliverToBoxAdapter(
              child: _buildSectionHeader('Featured adventures', isDark, theme),
            ),
            SliverToBoxAdapter(
              child: _buildHorizontalSection(_featured, isDark),
            ),
            // Kindness section
            SliverToBoxAdapter(
              child: _buildSectionHeader('A little kindness', isDark, theme),
            ),
            SliverToBoxAdapter(
              child: _buildHorizontalSection(_kindness, isDark),
            ),
            // Just getting started
            SliverToBoxAdapter(
              child: _buildSectionHeader('Just getting started', isDark, theme),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final journey = _justStarted[index];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: ExploreJourneyCardWidget(
                    journey: journey,
                    stops: _allStops,
                    onTap: () => context.push(
                      AppRoutes.journeyDetailScreen,
                      extra: journey.id,
                    ),
                    onFollow: () => _toggleFollow(journey),
                  ),
                );
              }, childCount: _justStarted.length),
            ),
          ],
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
    );
  }

  Widget _buildLovedHeader(bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.favorite_rounded,
                size: 16,
                color: AppTheme.primary,
              ),
              const SizedBox(width: 6),
              Text('Loved along the way', style: theme.textTheme.titleLarge),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Little journeys with a lot of support.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLovedSection(List<JourneyObject> journeys, bool isDark) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: journeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final journey = journeys[i];
          final summary = _giftRepo.getSummary(journey.id);
          return _LovedJourneyCard(
            journey: journey,
            stops: _allStops,
            summary: summary,
            isDark: isDark,
            onTap: () =>
                context.push(AppRoutes.journeyDetailScreen, extra: journey.id),
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Small things.\nBig adventures.',
          style: theme.textTheme.headlineLarge,
        ),
        const SizedBox(height: 6),
        Text(
          'Find a journey worth continuing.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            size: 18,
            color: isDark
                ? AppTheme.textSecondaryDark
                : AppTheme.textSecondaryLight,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (v) {
                setState(() => _searchQuery = v);
                _applyFilters();
              },
              decoration: InputDecoration(
                hintText: 'Search journeys...',
                border: InputBorder.none,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() => _searchQuery = '');
                _applyFilters();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypeFilters(bool isDark) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          _TypeChip(
            label: 'All',
            isSelected: _filterType == null,
            isDark: isDark,
            onTap: () {
              setState(() => _filterType = null);
              _applyFilters();
            },
          ),
          const SizedBox(width: 8),
          ...ObjectType.values.map(
            (type) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _TypeChip(
                label: '${type.emoji} ${type.displayName}',
                isSelected: _filterType == type,
                isDark: isDark,
                onTap: () {
                  setState(
                    () => _filterType = _filterType == type ? null : type,
                  );
                  _applyFilters();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(title, style: theme.textTheme.titleLarge),
    );
  }

  Widget _buildHorizontalSection(List<JourneyObject> journeys, bool isDark) {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: journeys.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final journey = journeys[i];
          return _HorizontalJourneyCard(
            journey: journey,
            stops: _allStops,
            isDark: isDark,
            onTap: () =>
                context.push(AppRoutes.journeyDetailScreen, extra: journey.id),
          );
        },
      ),
    );
  }

  Widget _buildSearchResults(bool isDark, ThemeData theme) {
    if (_filtered.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              const SizedBox(height: 16),
              Text('No journeys found', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Try a different search or filter.',
                style: TextStyle(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      );
    }
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final journey = _filtered[index];
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: ExploreJourneyCardWidget(
            journey: journey,
            stops: _allStops,
            onTap: () =>
                context.push(AppRoutes.journeyDetailScreen, extra: journey.id),
            onFollow: () => _toggleFollow(journey),
          ),
        );
      }, childCount: _filtered.length),
    );
  }
}

class _LovedJourneyCard extends StatelessWidget {
  final JourneyObject journey;
  final List<JourneyStop> stops;
  final JourneyGiftSummary summary;
  final bool isDark;
  final VoidCallback onTap;

  const _LovedJourneyCard({
    required this.journey,
    required this.stops,
    required this.summary,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: journey.type.accentColor.withAlpha(80)),
          boxShadow: [
            BoxShadow(
              color: journey.type.accentColor.withAlpha(20),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ObjectArtworkWidget(type: journey.type, size: 40),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.favorite_rounded,
                        size: 10,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        '${summary.distinctSupporters}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              journey.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 3),
            Text(
              journey.mission,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            // Gift preview
            if (summary.previewItems.isNotEmpty)
              Row(
                children: [
                  ...summary.previewItems
                      .take(3)
                      .map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(right: 4),
                          child: GiftArtworkWidget(item: item, size: 22),
                        ),
                      ),
                  const SizedBox(width: 4),
                  Text(
                    '${summary.distinctSupporters} supporter${summary.distinctSupporters == 1 ? '' : 's'} · ${summary.totalGifts} gift${summary.totalGifts == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _TypeChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
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

class _HorizontalJourneyCard extends StatelessWidget {
  final JourneyObject journey;
  final List<JourneyStop> stops;
  final bool isDark;
  final VoidCallback onTap;

  const _HorizontalJourneyCard({
    required this.journey,
    required this.stops,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final stats = computeStats(journey.id, stops);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              journey.type.accentColor.withAlpha(38),
              journey.type.accentColor.withAlpha(13),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: journey.type.accentColor.withAlpha(64)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ObjectArtworkWidget(type: journey.type, size: 52),
            const Spacer(),
            Text(
              journey.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppTheme.textPrimaryDark
                    : AppTheme.textPrimaryLight,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              '${stats.people} people · ${stats.countries} countries',
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
