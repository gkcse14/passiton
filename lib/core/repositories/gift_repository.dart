import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/gift_models.dart';
import '../data/gift_catalogue.dart';

const String _kContributionsKey = 'gift_contributions_v1';
const String _kSeedDoneKey = 'gift_seed_done_v1';

/// Result of an add-gift operation.
enum GiftAddResult {
  success,
  alreadySentFreeGift,
  notJoined,
  objectNotActive,
  catalogueItemInactive,
  messageTooLong,
  duplicate,
  saveFailed,
}

class GiftRepository extends ChangeNotifier {
  static final GiftRepository _instance = GiftRepository._();
  factory GiftRepository() => _instance;
  GiftRepository._();

  List<GiftContribution> _contributions = [];
  bool _loaded = false;

  // ── Initialise ─────────────────────────────────────────────────────────────

  Future<void> init() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_kContributionsKey) ?? [];
    _contributions = raw
        .map((s) {
          try {
            return GiftContribution.fromMap(
              jsonDecode(s) as Map<String, dynamic>,
            );
          } catch (_) {
            return null;
          }
        })
        .whereType<GiftContribution>()
        .toList();

    // Seed once
    final seeded = prefs.getBool(_kSeedDoneKey) ?? false;
    if (!seeded) {
      for (final m in kSeedGiftContributions) {
        final c = GiftContribution.fromMap(m);
        if (!_contributions.any((x) => x.id == c.id)) {
          _contributions.add(c);
        }
      }
      await _persist(prefs);
      await prefs.setBool(_kSeedDoneKey, true);
    }
    _loaded = true;
  }

  Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kContributionsKey);
    await prefs.remove(_kSeedDoneKey);
    _loaded = false;
    await init();
    notifyListeners();
  }

  // ── Read ───────────────────────────────────────────────────────────────────

  List<GiftCatalogItem> getCatalogue() => List.unmodifiable(kGiftCatalogue);

  List<GiftContribution> getContributions(String objectId) =>
      _contributions.where((c) => c.objectId == objectId).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<GiftGroupedItem> getGroupedCollection(String objectId) {
    final contribs = getContributions(objectId);
    final Map<String, List<GiftContribution>> grouped = {};
    for (final c in contribs) {
      grouped.putIfAbsent(c.catalogueGiftId, () => []).add(c);
    }
    final result = <GiftGroupedItem>[];
    for (final entry in grouped.entries) {
      final item = catalogItemById(entry.key);
      if (item == null) continue;
      final sorted = entry.value
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      result.add(
        GiftGroupedItem(
          catalogItem: item,
          totalCount: sorted.length,
          mostRecentDate: sorted.first.createdAt,
          contributions: sorted,
        ),
      );
    }
    result.sort((a, b) => b.mostRecentDate.compareTo(a.mostRecentDate));
    return result;
  }

  List<GiftSupporter> getSupporters(String objectId) {
    final contribs = getContributions(objectId);
    final Map<String, List<GiftContribution>> byParticipant = {};
    for (final c in contribs) {
      byParticipant.putIfAbsent(c.senderParticipantId, () => []).add(c);
    }
    final result = <GiftSupporter>[];
    for (final entry in byParticipant.entries) {
      final sorted = entry.value
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final giftedItems = sorted
          .map((c) => catalogItemById(c.catalogueGiftId))
          .whereType<GiftCatalogItem>()
          .toList();
      result.add(
        GiftSupporter(
          participantId: entry.key,
          displayName: sorted.first.senderDisplayName,
          giftCount: sorted.length,
          giftedItems: giftedItems,
          mostRecentAt: sorted.first.createdAt,
        ),
      );
    }
    result.sort((a, b) => b.mostRecentAt.compareTo(a.mostRecentAt));
    return result;
  }

  JourneyGiftSummary getSummary(String objectId) {
    final contribs = getContributions(objectId);
    final distinctSupporters = contribs
        .map((c) => c.senderParticipantId)
        .toSet()
        .length;
    final seenGiftIds = <String>{};
    final previewItems = <GiftCatalogItem>[];
    for (final c in contribs) {
      if (!seenGiftIds.contains(c.catalogueGiftId)) {
        final item = catalogItemById(c.catalogueGiftId);
        if (item != null) {
          previewItems.add(item);
          seenGiftIds.add(c.catalogueGiftId);
        }
      }
      if (previewItems.length >= 4) break;
    }
    return JourneyGiftSummary(
      objectId: objectId,
      totalGifts: contribs.length,
      distinctSupporters: distinctSupporters,
      previewItems: previewItems,
    );
  }

  List<GiftContribution> getGiftsSentByUser(String participantId) =>
      _contributions
          .where((c) => c.senderParticipantId == participantId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  bool hasSentFreeGift(String participantId, String objectId, String giftId) =>
      _contributions.any(
        (c) =>
            c.senderParticipantId == participantId &&
            c.objectId == objectId &&
            c.catalogueGiftId == giftId &&
            (c.source == GiftSource.free ||
                c.source == GiftSource.seededDemo &&
                    catalogItemById(giftId)?.isFree == true),
      );

  // ── Supported journey rankings ─────────────────────────────────────────────

  /// Returns objectIds sorted by distinct supporters (most first).
  List<String> rankByMostSupported(List<String> eligibleObjectIds) {
    final counts = <String, int>{};
    for (final id in eligibleObjectIds) {
      counts[id] = getSupporters(id).length;
    }
    final sorted = List<String>.from(eligibleObjectIds)
      ..sort((a, b) {
        final diff = (counts[b] ?? 0) - (counts[a] ?? 0);
        if (diff != 0) return diff;
        // Tie-break: most recent gift, then stable ID
        final aRecent = _mostRecentGiftTime(a);
        final bRecent = _mostRecentGiftTime(b);
        if (aRecent != null && bRecent != null) {
          return bRecent.compareTo(aRecent);
        }
        return a.compareTo(b);
      });
    return sorted;
  }

  /// Returns objectIds sorted by total gift count (most first).
  List<String> rankByMostGifted(List<String> eligibleObjectIds) {
    final counts = <String, int>{};
    for (final id in eligibleObjectIds) {
      counts[id] = getContributions(id).length;
    }
    final sorted = List<String>.from(eligibleObjectIds)
      ..sort((a, b) {
        final diff = (counts[b] ?? 0) - (counts[a] ?? 0);
        if (diff != 0) return diff;
        final aRecent = _mostRecentGiftTime(a);
        final bRecent = _mostRecentGiftTime(b);
        if (aRecent != null && bRecent != null) {
          return bRecent.compareTo(aRecent);
        }
        return a.compareTo(b);
      });
    return sorted;
  }

  /// Returns objectIds that had at least one new supporter this week.
  List<String> rankByThisWeek(List<String> eligibleObjectIds) {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final result = <String>[];
    for (final id in eligibleObjectIds) {
      final contribs = getContributions(id);
      final recentSupporters = contribs
          .where((c) => c.createdAt.isAfter(weekAgo))
          .map((c) => c.senderParticipantId)
          .toSet();
      if (recentSupporters.isNotEmpty) result.add(id);
    }
    result.sort((a, b) {
      final aRecent = _mostRecentGiftTime(a, since: weekAgo);
      final bRecent = _mostRecentGiftTime(b, since: weekAgo);
      if (aRecent != null && bRecent != null) return bRecent.compareTo(aRecent);
      return a.compareTo(b);
    });
    return result;
  }

  DateTime? _mostRecentGiftTime(String objectId, {DateTime? since}) {
    final contribs = getContributions(objectId);
    final filtered = since != null
        ? contribs.where((c) => c.createdAt.isAfter(since)).toList()
        : contribs;
    if (filtered.isEmpty) return null;
    return filtered
        .map((c) => c.createdAt)
        .reduce((a, b) => a.isAfter(b) ? a : b);
  }

  // ── Write ──────────────────────────────────────────────────────────────────

  Future<GiftAddResult> addFreeGift({
    required String objectId,
    required bool objectIsActive,
    required String participantId,
    required String displayName,
    String? stopId,
    required bool hasJoined,
    required String catalogueGiftId,
    String? message,
    String? operationId,
  }) async {
    if (!objectIsActive) return GiftAddResult.objectNotActive;
    if (!hasJoined) return GiftAddResult.notJoined;
    final item = catalogItemById(catalogueGiftId);
    if (item == null || !item.isActive) {
      return GiftAddResult.catalogueItemInactive;
    }
    if ((message?.length ?? 0) > 120) return GiftAddResult.messageTooLong;
    if (hasSentFreeGift(participantId, objectId, catalogueGiftId)) {
      return GiftAddResult.alreadySentFreeGift;
    }
    // Idempotency
    if (operationId != null && _contributions.any((c) => c.id == operationId)) {
      return GiftAddResult.duplicate;
    }
    final contribution = GiftContribution(
      id: operationId ?? _generateId(),
      objectId: objectId,
      senderParticipantId: participantId,
      senderDisplayName: displayName,
      senderStopId: stopId,
      catalogueGiftId: catalogueGiftId,
      message: message?.isEmpty == true ? null : message,
      createdAt: DateTime.now(),
      source: GiftSource.free,
    );
    _contributions.add(contribution);
    try {
      final prefs = await SharedPreferences.getInstance();
      await _persist(prefs);
      notifyListeners();
      return GiftAddResult.success;
    } catch (_) {
      _contributions.remove(contribution);
      return GiftAddResult.saveFailed;
    }
  }

  Future<GiftAddResult> addDemoPaidGift({
    required String objectId,
    required bool objectIsActive,
    required String participantId,
    required String displayName,
    String? stopId,
    required bool hasJoined,
    required String catalogueGiftId,
    String? message,
    String? operationId,
  }) async {
    if (!objectIsActive) return GiftAddResult.objectNotActive;
    if (!hasJoined) return GiftAddResult.notJoined;
    final item = catalogItemById(catalogueGiftId);
    if (item == null || !item.isActive) {
      return GiftAddResult.catalogueItemInactive;
    }
    if ((message?.length ?? 0) > 120) return GiftAddResult.messageTooLong;
    if (operationId != null && _contributions.any((c) => c.id == operationId)) {
      return GiftAddResult.duplicate;
    }
    final contribution = GiftContribution(
      id: operationId ?? _generateId(),
      objectId: objectId,
      senderParticipantId: participantId,
      senderDisplayName: displayName,
      senderStopId: stopId,
      catalogueGiftId: catalogueGiftId,
      message: message?.isEmpty == true ? null : message,
      createdAt: DateTime.now(),
      source: GiftSource.demoPaid,
      pricePaidMinorUnits: item.demoPriceMinorUnits,
      currencySnapshot: item.currencyCode,
    );
    _contributions.add(contribution);
    try {
      final prefs = await SharedPreferences.getInstance();
      await _persist(prefs);
      notifyListeners();
      return GiftAddResult.success;
    } catch (_) {
      _contributions.remove(contribution);
      return GiftAddResult.saveFailed;
    }
  }

  /// Used by demo controls to simulate another participant adding a gift.
  Future<GiftAddResult> addSeededDemoGift({
    required String objectId,
    required String participantId,
    required String displayName,
    String? stopId,
    required String catalogueGiftId,
    String? message,
  }) async {
    final item = catalogItemById(catalogueGiftId);
    if (item == null) return GiftAddResult.catalogueItemInactive;
    final contribution = GiftContribution(
      id: _generateId(),
      objectId: objectId,
      senderParticipantId: participantId,
      senderDisplayName: displayName,
      senderStopId: stopId,
      catalogueGiftId: catalogueGiftId,
      message: message,
      createdAt: DateTime.now(),
      source: GiftSource.seededDemo,
      pricePaidMinorUnits: item.isFree ? null : item.demoPriceMinorUnits,
      currencySnapshot: item.isFree ? null : item.currencyCode,
    );
    _contributions.add(contribution);
    try {
      final prefs = await SharedPreferences.getInstance();
      await _persist(prefs);
      notifyListeners();
      return GiftAddResult.success;
    } catch (_) {
      _contributions.remove(contribution);
      return GiftAddResult.saveFailed;
    }
  }

  // ── Persistence ────────────────────────────────────────────────────────────

  Future<void> _persist(SharedPreferences prefs) async {
    final raw = _contributions.map((c) => jsonEncode(c.toMap())).toList();
    if (!await prefs.setStringList(_kContributionsKey, raw)) {
      throw StateError('Could not save gifts.');
    }
  }

  String _generateId() =>
      'gc-${DateTime.now().millisecondsSinceEpoch}-${_contributions.length}';
}
