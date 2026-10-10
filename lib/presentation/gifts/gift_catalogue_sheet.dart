import 'package:flutter/material.dart';
import 'package:passiton/core/motion_notifier.dart';

import '../../../core/modal_notifier.dart';
import '../../../core/models/gift_models.dart';
import '../../../core/models/journey_models.dart';
import '../../../core/repositories/gift_repository.dart';
import '../../../theme/app_theme.dart';
import '../onboarding_screen/widgets/object_artwork_widget.dart';
import './widgets/gift_artwork_widget.dart';

enum _CatalogueFilter { all, free, paid }

/// Full gift catalogue sheet. Opens from journey detail.
class GiftCatalogueSheet extends StatefulWidget {
  final JourneyObject journey;
  final String participantId;
  final String participantName;
  final String? participantStopId;
  final bool hasJoined;

  const GiftCatalogueSheet({
    required this.journey,
    required this.participantId,
    required this.participantName,
    this.participantStopId,
    required this.hasJoined,
    super.key,
  });

  @override
  State<GiftCatalogueSheet> createState() => _GiftCatalogueSheetState();
}

class _GiftCatalogueSheetState extends State<GiftCatalogueSheet> {
  _CatalogueFilter _filter = _CatalogueFilter.all;
  GiftCatalogItem? _selected;
  final _repo = GiftRepository();
  late List<GiftCatalogItem> _catalogue;

  @override
  void initState() {
    super.initState();
    _catalogue = List<GiftCatalogItem>.from(_repo.getCatalogue())
      ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
  }

  List<GiftCatalogItem> get _filtered {
    switch (_filter) {
      case _CatalogueFilter.free:
        return _catalogue.where((g) => g.isFree).toList();
      case _CatalogueFilter.paid:
        return _catalogue.where((g) => !g.isFree).toList();
      case _CatalogueFilter.all:
        // Free first
        final free = _catalogue.where((g) => g.isFree).toList();
        final paid = _catalogue.where((g) => !g.isFree).toList();
        return [...free, ...paid];
    }
  }

  bool _isSentFree(GiftCatalogItem item) {
    if (!item.isFree) return false;
    return _repo.hasSentFreeGift(
      widget.participantId,
      widget.journey.id,
      item.id,
    );
  }

  void _onContinue() {
    if (_selected == null) return;
    Navigator.of(context).pop();
    showManagedModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => GiftConfirmationSheet(
        journey: widget.journey,
        selectedItem: _selected!,
        participantId: widget.participantId,
        participantName: widget.participantName,
        participantStopId: widget.participantStopId,
        hasJoined: widget.hasJoined,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount =
        screenWidth < 420 || MediaQuery.textScalerOf(context).scale(14) > 18
        ? 2
        : 3;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Handle
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Text(
                  'Give this journey a little joy',
                  style: theme.textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: widget.journey.type.accentColor.withAlpha(40),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: ObjectArtworkWidget(
                          type: widget.journey.type,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'For ${widget.journey.name}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Add a gift to this journey’s collection on your device.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppTheme.textSecondaryDark
                        : AppTheme.textSecondaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Local preview · No real charges',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Row(
              children: _CatalogueFilter.values.map((f) {
                final label = f == _CatalogueFilter.all
                    ? 'All'
                    : f == _CatalogueFilter.free
                    ? 'Free'
                    : 'Demo gifts';
                final selected = _filter == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => setState(() => _filter = f),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary
                            : (isDark
                                  ? AppTheme.surfaceDark
                                  : AppTheme.backgroundLight),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primary
                              : (isDark
                                    ? AppTheme.borderDark
                                    : AppTheme.borderLight),
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : (isDark
                                    ? AppTheme.textPrimaryDark
                                    : AppTheme.textPrimaryLight),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          // Grid
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final item = _filtered[index];
                final isSelected = _selected?.id == item.id;
                final alreadySent = _isSentFree(item);
                return _GiftTile(
                  item: item,
                  isSelected: isSelected,
                  alreadySent: alreadySent,
                  isDark: isDark,
                  onTap: alreadySent
                      ? null
                      : () {
                          selectionFeedback();
                          setState(() => _selected = isSelected ? null : item);
                        },
                );
              },
            ),
          ),
          // Bottom action
          Container(
            padding: EdgeInsets.fromLTRB(20, 12, 20, bottomPadding + 16),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_selected != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GiftArtworkWidget(item: _selected!, size: 24),
                        const SizedBox(width: 8),
                        Text(
                          _selected!.name,
                          style: theme.textTheme.titleSmall,
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: _selected!.isFree
                                ? AppTheme.secondaryContainer
                                : AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _selected!.formattedPrice,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: _selected!.isFree
                                  ? AppTheme.secondary
                                  : AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _selected != null ? _onContinue : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: isDark
                          ? AppTheme.borderDark
                          : AppTheme.borderLight,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
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

class _GiftTile extends StatelessWidget {
  final GiftCatalogItem item;
  final bool isSelected;
  final bool alreadySent;
  final bool isDark;
  final VoidCallback? onTap;

  const _GiftTile({
    required this.item,
    required this.isSelected,
    required this.alreadySent,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${item.name}, ${item.formattedPrice}${alreadySent ? ", already sent" : ""}',
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.primaryContainer
                : (isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? AppTheme.primary
                  : (isDark ? AppTheme.borderDark : AppTheme.borderLight),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Center(
                        child: Opacity(
                          opacity: alreadySent ? 0.5 : 1.0,
                          child: GiftArtworkWidget(item: item, size: 52),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.name,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppTheme.textPrimaryDark
                            : AppTheme.textPrimaryLight,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      alreadySent ? 'Sent ✓' : item.formattedPrice,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: alreadySent
                            ? AppTheme.secondary
                            : (item.isFree
                                  ? AppTheme.secondary
                                  : AppTheme.primary),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Confirmation Sheet ────────────────────────────────────────────────────────

class GiftConfirmationSheet extends StatefulWidget {
  final JourneyObject journey;
  final GiftCatalogItem selectedItem;
  final String participantId;
  final String participantName;
  final String? participantStopId;
  final bool hasJoined;

  const GiftConfirmationSheet({
    required this.journey,
    required this.selectedItem,
    required this.participantId,
    required this.participantName,
    this.participantStopId,
    required this.hasJoined,
    super.key,
  });

  @override
  State<GiftConfirmationSheet> createState() => _GiftConfirmationSheetState();
}

class _GiftConfirmationSheetState extends State<GiftConfirmationSheet> {
  final _messageController = TextEditingController();
  final _repo = GiftRepository();
  bool _isSubmitting = false;
  String? _errorMessage;
  late String _operationId;

  @override
  void initState() {
    super.initState();
    _operationId = 'op-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _changeGift() {
    Navigator.of(context).pop();
    showManagedModalBottomSheet(
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
    );
  }

  Future<void> _confirm() async {
    if (_isSubmitting) return;
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final message = _messageController.text.trim().isEmpty
        ? null
        : _messageController.text.trim();
    GiftAddResult result;

    if (widget.selectedItem.isFree) {
      result = await _repo.addFreeGift(
        objectId: widget.journey.id,
        objectIsActive: widget.journey.state == JourneyState.active,
        participantId: widget.participantId,
        displayName: widget.participantName,
        stopId: widget.participantStopId,
        hasJoined: widget.hasJoined,
        catalogueGiftId: widget.selectedItem.id,
        message: message,
        operationId: _operationId,
      );
    } else {
      result = await _repo.addDemoPaidGift(
        objectId: widget.journey.id,
        objectIsActive: widget.journey.state == JourneyState.active,
        participantId: widget.participantId,
        displayName: widget.participantName,
        stopId: widget.participantStopId,
        hasJoined: widget.hasJoined,
        catalogueGiftId: widget.selectedItem.id,
        message: message,
        operationId: _operationId,
      );
    }

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result == GiftAddResult.success || result == GiftAddResult.duplicate) {
      Navigator.of(context).pop();
      showManagedModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => GiftSuccessSheet(
          journey: widget.journey,
          giftItem: widget.selectedItem,
        ),
      );
    } else if (result == GiftAddResult.saveFailed) {
      setState(
        () => _errorMessage = 'Could not save your gift. Please try again.',
      );
      // Reset operation ID so retry is safe
      _operationId = 'op-${DateTime.now().millisecondsSinceEpoch}-retry';
    } else if (result == GiftAddResult.alreadySentFreeGift) {
      setState(
        () => _errorMessage =
            'You\'ve already sent this free gift to this journey.',
      );
    } else {
      setState(() => _errorMessage = 'Something went wrong. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding =
        MediaQuery.of(context).padding.bottom +
        MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            // Gift preview
            Center(
              child: Column(
                children: [
                  GiftArtworkWidget(
                    item: widget.selectedItem,
                    size: 80,
                    showShadow: true,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'A ${widget.selectedItem.name} for ${widget.journey.name}',
                    style: theme.textTheme.headlineSmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: widget.journey.type.accentColor.withAlpha(40),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: ObjectArtworkWidget(
                            type: widget.journey.type,
                            size: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        widget.journey.name,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark
                              ? AppTheme.textSecondaryDark
                              : AppTheme.textSecondaryLight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: widget.selectedItem.isFree
                          ? AppTheme.secondaryContainer
                          : AppTheme.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      widget.selectedItem.isFree
                          ? 'Free'
                          : widget.selectedItem.formattedPrice,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.selectedItem.isFree
                            ? AppTheme.secondary
                            : AppTheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Sender preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.backgroundLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppTheme.primaryContainer,
                    child: Text(
                      widget.participantName.isNotEmpty
                          ? widget.participantName[0].toUpperCase()
                          : 'Y',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From ${widget.participantName}',
                        style: theme.textTheme.titleSmall,
                      ),
                      Text(
                        'Sender',
                        style: theme.textTheme.bodySmall?.copyWith(
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
            const SizedBox(height: 16),
            // Message field
            Text('Add a message (optional)', style: theme.textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLength: 120,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'For our fearless traveller!',
                filled: true,
                fillColor: isDark
                    ? AppTheme.backgroundDark
                    : AppTheme.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppTheme.primary,
                    width: 1.5,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
              ),
            ),
            if (!widget.selectedItem.isFree) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Demo purchase — no real payment.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.error.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(fontSize: 12, color: AppTheme.error),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Actions
            Row(
              children: [
                TextButton(
                  onPressed: _isSubmitting ? null : _changeGift,
                  child: const Text(
                    'Change gift',
                    style: TextStyle(color: AppTheme.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              widget.selectedItem.isFree
                                  ? 'Send free gift'
                                  : 'Add demo gift · ${widget.selectedItem.formattedPrice}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                    ),
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

// ─── Success Sheet ─────────────────────────────────────────────────────────────

class GiftSuccessSheet extends StatefulWidget {
  final JourneyObject journey;
  final GiftCatalogItem giftItem;
  final VoidCallback? onViewGifts;

  const GiftSuccessSheet({
    required this.journey,
    required this.giftItem,
    this.onViewGifts,
    super.key,
  });

  @override
  State<GiftSuccessSheet> createState() => _GiftSuccessSheetState();
}

class _GiftSuccessSheetState extends State<GiftSuccessSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = Tween<double>(
      begin: 0.6,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );
    _controller.forward();
    selectionFeedback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(24, 20, 24, bottomPadding + 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          const SizedBox(height: 32),
          FadeTransition(
            opacity: _fadeAnim,
            child: ScaleTransition(
              scale: _scaleAnim,
              child: GiftArtworkWidget(
                item: widget.giftItem,
                size: 96,
                showShadow: true,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Your gift joined the adventure.',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Your ${widget.giftItem.name} is now part of this journey.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    widget.onViewGifts?.call();
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'View gifts',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
