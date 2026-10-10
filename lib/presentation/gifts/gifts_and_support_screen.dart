import 'package:flutter/material.dart';
import '../../widgets/page_layout.dart';

import '../../core/models/gift_models.dart';
import '../../core/models/journey_models.dart';
import '../../core/repositories/gift_repository.dart';
import '../../theme/app_theme.dart';
import '../onboarding_screen/widgets/object_artwork_widget.dart';
import './gift_catalogue_sheet.dart';
import './widgets/gift_artwork_widget.dart';

class GiftsAndSupportScreen extends StatefulWidget {
  final JourneyObject journey;
  final String participantId;
  final String participantName;
  final String? participantStopId;
  final bool hasJoined;

  const GiftsAndSupportScreen({
    required this.journey,
    required this.participantId,
    required this.participantName,
    this.participantStopId,
    required this.hasJoined,
    super.key,
  });

  @override
  State<GiftsAndSupportScreen> createState() => _GiftsAndSupportScreenState();
}

class _GiftsAndSupportScreenState extends State<GiftsAndSupportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _repo = GiftRepository();
  late List<GiftGroupedItem> _grouped;
  late List<GiftSupporter> _supporters;
  bool _sortByMostReceived = false;
  bool _sortSupportersByGifts = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  void _loadData() {
    _grouped = _repo.getGroupedCollection(widget.journey.id);
    _supporters = _repo.getSupporters(widget.journey.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<GiftGroupedItem> get _sortedGrouped {
    final list = List<GiftGroupedItem>.from(_grouped);
    if (_sortByMostReceived) {
      list.sort((a, b) => b.totalCount.compareTo(a.totalCount));
    } else {
      list.sort((a, b) => b.mostRecentDate.compareTo(a.mostRecentDate));
    }
    return list;
  }

  List<GiftSupporter> get _sortedSupporters {
    final list = List<GiftSupporter>.from(_supporters);
    if (_sortSupportersByGifts) {
      list.sort((a, b) => b.giftCount.compareTo(a.giftCount));
    } else {
      list.sort((a, b) => b.mostRecentAt.compareTo(a.mostRecentAt));
    }
    return list;
  }

  void _openCatalogue() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GiftCatalogueSheet(
        journey: widget.journey,
        participantId: widget.participantId,
        participantName: widget.participantName,
        participantStopId: widget.participantStopId,
        hasJoined: widget.hasJoined,
      ),
    ).then((_) => setState(_loadData));
  }

  void _showContributionHistory(GiftGroupedItem group) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  GiftArtworkWidget(item: group.catalogItem, size: 36),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          group.catalogItem.name,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${group.totalCount} contribution${group.totalCount == 1 ? '' : 's'}',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: group.contributions.length,
                itemBuilder: (context, i) {
                  final c = group.contributions[i];
                  return _ContributionTile(contribution: c, isDark: isDark);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSupporterContributions(GiftSupporter supporter) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final contribs = _repo
        .getContributions(widget.journey.id)
        .where((c) => c.senderParticipantId == supporter.participantId)
        .toList();
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
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTheme.primaryContainer,
                    child: Text(
                      supporter.displayName.isNotEmpty
                          ? supporter.displayName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          supporter.displayName,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          '${supporter.giftCount} gift${supporter.giftCount == 1 ? '' : 's'} to this journey',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: isDark
                                    ? AppTheme.textSecondaryDark
                                    : AppTheme.textSecondaryLight,
                              ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: contribs.length,
                itemBuilder: (context, i) => _ContributionTile(
                  contribution: contribs[i],
                  isDark: isDark,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalGifts = _grouped.fold(0, (sum, g) => sum + g.totalCount);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final isActive = widget.journey.state == JourneyState.active;

    return PageFrame(
      maxWidth: 840,
      child: Scaffold(
        backgroundColor: isDark
            ? AppTheme.backgroundDark
            : AppTheme.backgroundLight,
        appBar: AppBar(
          backgroundColor: isDark
              ? AppTheme.backgroundDark
              : AppTheme.backgroundLight,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text('Gifts & support'),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Divider(
              height: 1,
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
            ),
          ),
        ),
        body: Column(
          children: [
            // Object header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: widget.journey.type.accentColor.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: ObjectArtworkWidget(
                        type: widget.journey.type,
                        size: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.journey.name,
                          style: theme.textTheme.titleLarge,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$totalGifts gift${totalGifts == 1 ? '' : 's'} · ${_supporters.length} supporter${_supporters.length == 1 ? '' : 's'}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isDark
                                ? AppTheme.textSecondaryDark
                                : AppTheme.textSecondaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Tab bar
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: isDark ? AppTheme.surfaceDark : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
              child: TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Collection'),
                  Tab(text: 'Supporters'),
                ],
                labelColor: Colors.white,
                unselectedLabelColor: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
                indicator: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 4),
            // Tab content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildCollection(theme, isDark),
                  _buildSupporters(theme, isDark),
                ],
              ),
            ),
            // Bottom add gift
            if (isActive)
              Container(
                padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppTheme.backgroundDark
                      : AppTheme.backgroundLight,
                  border: Border(
                    top: BorderSide(
                      color: isDark
                          ? AppTheme.borderDark
                          : AppTheme.borderLight,
                    ),
                  ),
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _openCatalogue,
                    icon: const Icon(Icons.card_giftcard_rounded, size: 18),
                    label: const Text(
                      'Add a gift',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCollection(ThemeData theme, bool isDark) {
    if (_grouped.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.card_giftcard_outlined,
                size: 48,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              const SizedBox(height: 16),
              Text('No gifts yet.', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'Leave a little something for its adventure.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Sort control
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            children: [
              Text(
                'Sort:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Recent',
                selected: !_sortByMostReceived,
                isDark: isDark,
                onTap: () => setState(() => _sortByMostReceived = false),
              ),
              const SizedBox(width: 6),
              _SortChip(
                label: 'Most received',
                selected: _sortByMostReceived,
                isDark: isDark,
                onTap: () => setState(() => _sortByMostReceived = true),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            itemCount: _sortedGrouped.length,
            itemBuilder: (context, i) {
              final group = _sortedGrouped[i];
              return _GroupedGiftTile(
                group: group,
                isDark: isDark,
                onTap: () => _showContributionHistory(group),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSupporters(ThemeData theme, bool isDark) {
    if (_supporters.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.people_outline_rounded,
                size: 48,
                color: isDark
                    ? AppTheme.textSecondaryDark
                    : AppTheme.textSecondaryLight,
              ),
              const SizedBox(height: 16),
              Text('No supporters yet.', style: theme.textTheme.titleMedium),
              const SizedBox(height: 6),
              Text(
                'A little support can start something big.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
          child: Row(
            children: [
              Text(
                'Sort:',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight,
                ),
              ),
              const SizedBox(width: 8),
              _SortChip(
                label: 'Recent',
                selected: !_sortSupportersByGifts,
                isDark: isDark,
                onTap: () => setState(() => _sortSupportersByGifts = false),
              ),
              const SizedBox(width: 6),
              _SortChip(
                label: 'Most gifts',
                selected: _sortSupportersByGifts,
                isDark: isDark,
                onTap: () => setState(() => _sortSupportersByGifts = true),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
            itemCount: _sortedSupporters.length,
            itemBuilder: (context, i) {
              final supporter = _sortedSupporters[i];
              return _SupporterTile(
                supporter: supporter,
                isDark: isDark,
                onTap: () => _showSupporterContributions(supporter),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _GroupedGiftTile extends StatelessWidget {
  final GiftGroupedItem group;
  final bool isDark;
  final VoidCallback onTap;

  const _GroupedGiftTile({
    required this.group,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Row(
          children: [
            GiftArtworkWidget(item: group.catalogItem, size: 48),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          group.catalogItem.name,
                          style: theme.textTheme.titleSmall,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (group.totalCount > 1)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '×${group.totalCount}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Most recent: ${_formatDate(group.mostRecentDate)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
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
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

class _SupporterTile extends StatelessWidget {
  final GiftSupporter supporter;
  final bool isDark;
  final VoidCallback onTap;

  const _SupporterTile({
    required this.supporter,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppTheme.primaryContainer,
              child: Text(
                supporter.displayName.isNotEmpty
                    ? supporter.displayName[0].toUpperCase()
                    : '?',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supporter.displayName,
                    style: theme.textTheme.titleSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Text(
                        '${supporter.giftCount} gift${supporter.giftCount == 1 ? '' : 's'}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                      const SizedBox(width: 8),
                      ...supporter.giftedItems
                          .take(3)
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(right: 3),
                              child: GiftArtworkWidget(item: item, size: 18),
                            ),
                          ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
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
}

class _ContributionTile extends StatelessWidget {
  final GiftContribution contribution;
  final bool isDark;

  const _ContributionTile({required this.contribution, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = contribution.catalogueGiftId.isNotEmpty
        ? _safeItem(contribution.catalogueGiftId)
        : null;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item != null)
            GiftArtworkWidget(item: item, size: 36)
          else
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.borderLight,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        contribution.senderDisplayName,
                        style: theme.textTheme.titleSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      _formatDate(contribution.createdAt),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                if (contribution.message != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    '"${contribution.message}"',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isDark
                          ? AppTheme.textSecondaryDark
                          : AppTheme.textSecondaryLight,
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (contribution.source == GiftSource.demoPaid ||
                    contribution.source == GiftSource.seededDemo) ...[
                  const SizedBox(height: 3),
                  Text(
                    'Demo gift',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.primary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  GiftCatalogItem? _safeItem(String id) {
    try {
      final repo = GiftRepository();
      return repo.getCatalogue().firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
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
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

class _SortChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _SortChip({
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppTheme.primary
                : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppTheme.primary
                : (isDark
                      ? AppTheme.textSecondaryDark
                      : AppTheme.textSecondaryLight),
          ),
        ),
      ),
    );
  }
}
