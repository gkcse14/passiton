import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/sample_data.dart';
import '../../core/models/journey_models.dart';
import '../../core/models/gift_models.dart';
import '../../core/repositories/gift_repository.dart';
import '../../core/modal_notifier.dart';
import '../../theme/app_theme.dart';
import '../onboarding_screen/widgets/object_artwork_widget.dart';
import '../gifts/gift_catalogue_sheet.dart';
import '../gifts/gifts_and_support_screen.dart';
import '../gifts/widgets/gift_artwork_widget.dart';
import './widgets/journey_map_widget.dart';
import './widgets/journey_stats_widget.dart';
import './widgets/journey_timeline_widget.dart';
import './widgets/pass_it_on_sheet_widget.dart';

class JourneyDetailScreen extends StatefulWidget {
  final String journeyId;
  const JourneyDetailScreen({required this.journeyId, super.key});

  @override
  State<JourneyDetailScreen> createState() => _JourneyDetailScreenState();
}

class _JourneyDetailScreenState extends State<JourneyDetailScreen>
    with SingleTickerProviderStateMixin {
  late JourneyObject _journey;
  late List<JourneyStop> _stops;
  late TabController _tabController;
  bool _isFollowing = false;
  bool _hasJoined = false;
  final _giftRepo = GiftRepository();
  JourneyGiftSummary? _giftSummary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    final allJourneys = sampleJourneyMaps.map(JourneyObject.fromMap).toList();
    _journey = allJourneys.firstWhere(
      (j) => j.id == widget.journeyId,
      orElse: () => allJourneys.first,
    );
    _stops =
        sampleStopMaps
            .map(JourneyStop.fromMap)
            .where((s) => s.objectId == widget.journeyId)
            .toList()
          ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _isFollowing = _journey.isFollowed;
    _hasJoined = _stops.any((s) => s.participantId == kLocalUserId);
    _giftSummary = _giftRepo.getSummary(_journey.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleFollow() {
    setState(() => _isFollowing = !_isFollowing);
  }

  void _showPassItOnSheet() {
    showManagedModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PassItOnSheetWidget(journey: _journey, stops: _stops),
    );
  }

  void _openGiftCatalogue() {
    final isActive = _journey.state == JourneyState.active;
    if (!isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'This journey is archived. Gifts can be viewed but not added.',
          ),
        ),
      );
      return;
    }
    if (!_hasJoined) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Join this journey first to add a gift.')),
      );
      return;
    }
    final myStop = _stops.firstWhere(
      (s) => s.participantId == kLocalUserId,
      orElse: () => _stops.first,
    );
    showManagedModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GiftCatalogueSheet(
        journey: _journey,
        participantId: kLocalUserId,
        participantName: kLocalUserName,
        participantStopId: myStop.id,
        hasJoined: _hasJoined,
      ),
    ).then(
      (_) => setState(() => _giftSummary = _giftRepo.getSummary(_journey.id)),
    );
  }

  void _openGiftsScreen() {
    final myStop = _stops.firstWhere(
      (s) => s.participantId == kLocalUserId,
      orElse: () => _stops.isNotEmpty ? _stops.first : _stops.first,
    );
    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => GiftsAndSupportScreen(
              journey: _journey,
              participantId: kLocalUserId,
              participantName: kLocalUserName,
              participantStopId:
                  _stops.any((s) => s.participantId == kLocalUserId)
                  ? myStop.id
                  : null,
              hasJoined: _hasJoined,
            ),
          ),
        )
        .then(
          (_) =>
              setState(() => _giftSummary = _giftRepo.getSummary(_journey.id)),
        );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = computeStats(_journey.id, _stops);
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildSliverAppBar(theme, isDark, innerBoxIsScrolled),
          SliverToBoxAdapter(child: _buildHeroInfo(theme, isDark)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: JourneyStatsWidget(stats: stats, journey: _journey),
            ),
          ),
          // Gifts & Support section
          SliverToBoxAdapter(child: _buildGiftsSection(theme, isDark)),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Journey'),
                  Tab(text: 'Map'),
                ],
                labelColor: AppTheme.primary,
                unselectedLabelColor: AppTheme.textSecondaryLight,
                indicatorColor: AppTheme.primary,
                indicatorWeight: 2,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                ),
              ),
              isDark: isDark,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            JourneyTimelineWidget(stops: _stops),
            JourneyMapWidget(stops: _stops, journeyId: _journey.id),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(isDark, bottomPadding),
    );
  }

  Widget _buildGiftsSection(ThemeData theme, bool isDark) {
    final summary = _giftSummary;
    final isActive = _journey.state == JourneyState.active;
    final hasGifts = summary != null && summary.totalGifts > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.card_giftcard_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Text('Gifts & support', style: theme.textTheme.titleSmall),
                const Spacer(),
                if (hasGifts)
                  GestureDetector(
                    onTap: _openGiftsScreen,
                    child: Text(
                      'View all',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            if (!hasGifts) ...[
              Text('No gifts yet.', style: theme.textTheme.bodyMedium),
              const SizedBox(height: 3),
              Text(
                'Leave a little something for its adventure.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ] else ...[
              Text(
                '${summary.totalGifts} gift${summary.totalGifts == 1 ? '' : 's'} · ${summary.distinctSupporters} supporter${summary.distinctSupporters == 1 ? '' : 's'}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 10),
              // Preview illustrations
              Row(
                children: [
                  ...summary.previewItems.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GiftArtworkWidget(item: item, size: 36),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            // Action button
            if (!isActive)
              Text(
                'This journey is archived. Gifts can be viewed but not added.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              )
            else if (!_hasJoined)
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Join this journey to add a gift.'),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 15,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Join to add a gift',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              GestureDetector(
                onTap: _openGiftCatalogue,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.primary.withAlpha(80)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.card_giftcard_rounded,
                        size: 15,
                        color: AppTheme.primary,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Add a gift',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
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

  Widget _buildSliverAppBar(ThemeData theme, bool isDark, bool scrolled) {
    return SliverAppBar(
      expandedHeight: 244,
      pinned: true,
      backgroundColor: isDark
          ? AppTheme.backgroundDark
          : AppTheme.backgroundLight,
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
        icon: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight)
                .withAlpha(230),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 16,
            color: isDark
                ? AppTheme.textPrimaryDark
                : AppTheme.textPrimaryLight,
          ),
        ),
        onPressed: () => context.pop(),
      ),
      actions: [
        IconButton(
          icon: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight)
                  .withAlpha(230),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              ),
            ),
            child: Icon(
              Icons.share_rounded,
              size: 16,
              color: isDark
                  ? AppTheme.textPrimaryDark
                  : AppTheme.textPrimaryLight,
            ),
          ),
          onPressed: _showPassItOnSheet,
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _journey.type.accentColor.withAlpha(31),
                (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight),
              ],
            ),
          ),
          child: Center(
            child: Hero(
              tag: 'object-artwork-${_journey.id}',
              child: ObjectShowcase(type: _journey.type, size: 206),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroInfo(ThemeData theme, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _journey.name,
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              if (_journey.isSampleData)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Sample',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _journey.mission,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.person_rounded,
                size: 13,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                _journey.creatorId == kLocalUserId
                    ? 'Started by You'
                    : 'Started by ${_journey.creatorName}',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.calendar_today_rounded,
                size: 13,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              const SizedBox(width: 4),
              Text(
                _formatDate(_journey.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(bool isDark, double bottomPadding) {
    final isOwner = _journey.creatorId == kLocalUserId;
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        border: Border(
          top: BorderSide(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: _toggleFollow,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isFollowing
                    ? AppTheme.primaryContainer
                    : (isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: _isFollowing
                      ? AppTheme.primary
                      : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
                ),
              ),
              child: Icon(
                _isFollowing
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                size: 20,
                color: _isFollowing
                    ? AppTheme.primary
                    : (isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _showPassItOnSheet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  isOwner || _hasJoined ? 'Pass it on' : 'Join this journey',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _TabBarDelegate(this.tabBar, {required this.isDark});

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_TabBarDelegate oldDelegate) => false;
}
