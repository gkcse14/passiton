import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/featured_journey_card_widget.dart';
import './widgets/journey_card_widget.dart';

class JourneysScreen extends StatefulWidget {
  const JourneysScreen({super.key});

  @override
  State<JourneysScreen> createState() => _JourneysScreenState();
}

class _JourneysScreenState extends State<JourneysScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod for production
  late List<JourneyObject> _allJourneys;
  late List<JourneyStop> _allStops;
  late List<JourneyObject> _filteredJourneys;
  int _filterIndex = 0; // 0=All, 1=Started, 2=Joined, 3=Following
  late AnimationController _listAnimController;

  static const List<String> _filters = [
    'All',
    'Started',
    'Joined',
    'Following',
  ];

  @override
  void initState() {
    super.initState();
    _allJourneys = sampleJourneyMaps.map(JourneyObject.fromMap).toList();
    _allStops = sampleStopMaps.map(JourneyStop.fromMap).toList();
    _filteredJourneys = List.from(_allJourneys);
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _listAnimController.dispose();
    super.dispose();
  }

  void _applyFilter(int index) {
    setState(() {
      _filterIndex = index;
      switch (index) {
        case 0:
          _filteredJourneys = List.from(_allJourneys);
          break;
        case 1:
          _filteredJourneys = _allJourneys
              .where((j) => j.creatorId == kLocalUserId)
              .toList();
          break;
        case 2:
          _filteredJourneys = _allJourneys.where((j) {
            return _allStops.any(
              (s) =>
                  s.objectId == j.id &&
                  s.participantId == kLocalUserId &&
                  !s.isOrigin,
            );
          }).toList();
          break;
        case 3:
          _filteredJourneys = _allJourneys.where((j) => j.isFollowed).toList();
          break;
      }
    });
    _listAnimController.reset();
    _listAnimController.forward();
  }

  JourneyObject get _featuredJourney => _allJourneys.first;

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
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: FeaturedJourneyCardWidget(
                journey: _featuredJourney,
                stops: _allStops,
                onTap: () => context.push(
                  AppRoutes.journeyDetailScreen,
                  extra: _featuredJourney.id,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: _buildSectionHeader(theme),
            ),
          ),
          SliverToBoxAdapter(child: _buildFilterChips(theme)),
          if (_filteredJourneys.isEmpty)
            SliverFillRemaining(
              child: EmptyStateWidget(
                title: 'Your first adventure starts here.',
                subtitle: 'Create a journey and watch it travel the world.',
                actionLabel: 'Start a journey',
                onAction: () => context.push(AppRoutes.createJourneyScreen),
                objectType: ObjectType.potato,
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final journey = _filteredJourneys[index];
                final delay = index * 60;
                return AnimatedBuilder(
                  animation: _listAnimController,
                  builder: (context, child) {
                    final t = Curves.easeOutCubic.transform(
                      (((_listAnimController.value * 1000) - delay) / 350)
                          .clamp(0.0, 1.0),
                    );
                    return Transform.translate(
                      offset: Offset(0, 20 * (1 - t)),
                      child: Opacity(opacity: t, child: child),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                    child: JourneyCardWidget(
                      journey: journey,
                      stops: _allStops,
                      onTap: () => context.push(
                        AppRoutes.journeyDetailScreen,
                        extra: journey.id,
                      ),
                    ),
                  ),
                );
              }, childCount: _filteredJourneys.length),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 120)),
        ],
      ),
      floatingActionButton: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).padding.bottom + 80,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoutes.createJourneyScreen),
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          icon: const Icon(Icons.add_rounded, size: 20),
          label: const Text(
            'New journey',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildHeader(ThemeData theme, bool isDark) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Your journeys', style: theme.textTheme.headlineLarge),
              const SizedBox(height: 4),
              Text(
                'Little things, heading somewhere.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {},
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: const Icon(Icons.person_outline_rounded, size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('All journeys', style: theme.textTheme.titleLarge),
        TextButton(
          onPressed: () {},
          child: Text(
            'View all',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChips(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final selected = i == _filterIndex;
          return GestureDetector(
            onTap: () => _applyFilter(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: selected
                    ? AppTheme.primary
                    : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected
                      ? AppTheme.primary
                      : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                ),
              ),
              child: Text(
                _filters[i],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: selected
                      ? Colors.white
                      : (isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
