import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/sample_data.dart';
import '../models/journey_models.dart';

/// Device-local journey state. A shared service can replace this boundary later.
class JourneyRepository extends ChangeNotifier {
  static final instance = JourneyRepository();
  static const storageKey = 'journey_collection_v1';
  JourneyRepository({bool seed = true})
    : _journeys = seed
          ? sampleJourneyMaps
                .map((m) => JourneyObject.fromMap({...m, 'isSampleData': true}))
                .toList()
          : [],
      _stops = seed
          ? sampleStopMaps
                .map((m) => JourneyStop.fromMap({...m, 'isSampleData': true}))
                .toList()
          : [];

  List<JourneyObject> _journeys;
  List<JourneyStop> _stops;
  SharedPreferences? _preferences;
  bool _saving = false;
  List<JourneyObject> get journeys => List.unmodifiable(_journeys);
  List<JourneyStop> get stops => List.unmodifiable(_stops);
  JourneyObject? find(String id) {
    for (final journey in _journeys) {
      if (journey.id == id) return journey;
    }
    return null;
  }

  Future<void> init({SharedPreferences? preferences}) async {
    if (_preferences != null) return;
    _preferences = preferences ?? await SharedPreferences.getInstance();
    final raw = _preferences!.getString(storageKey);
    if (raw == null) return;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final journeys = (map['journeys'] as List)
          .map((m) => JourneyObject.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      final stops = (map['stops'] as List)
          .map((m) => JourneyStop.fromMap(Map<String, dynamic>.from(m)))
          .toList();
      _journeys = journeys;
      _stops = stops;
      notifyListeners();
    } catch (_) {
      // Keep the preview usable when an older or interrupted snapshot is invalid.
    }
  }

  Future<void> _save(
    List<JourneyObject> journeys,
    List<JourneyStop> stops,
  ) async {
    if (_saving) throw StateError('A journey is already being saved.');
    _saving = true;
    try {
      final prefs = _preferences ?? await SharedPreferences.getInstance();
      final saved = await prefs.setString(
        storageKey,
        jsonEncode({
          'journeys': journeys.map((j) => j.toMap()).toList(),
          'stops': stops.map((s) => s.toMap()).toList(),
        }),
      );
      if (!saved) throw StateError('Could not save your journey.');
      _journeys = journeys;
      _stops = stops;
      notifyListeners();
    } finally {
      _saving = false;
    }
  }

  Future<void> reset() async {
    final defaults = JourneyRepository();
    await _save(defaults.journeys, defaults.stops);
    defaults.dispose();
  }

  Future<String> displayName() async {
    final prefs = _preferences ?? await SharedPreferences.getInstance();
    final name = prefs.getString('display_name')?.trim();
    return name == null || name.isEmpty ? kLocalUserName : name;
  }

  Future<JourneyObject> create({
    required ObjectType type,
    required String name,
    required String mission,
    String? openingNote,
    GoalType goalType = GoalType.none,
    int? goalTarget,
    LocationVisibility visibility = LocationVisibility.hidden,
    String? city,
    String? country,
    double? lat,
    double? lng,
  }) async {
    if (name.trim().length < 3 || mission.trim().length < 5) {
      throw ArgumentError('Add a name and mission first.');
    }
    final creatorDisplayName = await displayName();
    final now = DateTime.now();
    final id = 'local-${now.microsecondsSinceEpoch}';
    final journey = JourneyObject(
      id: id,
      type: type,
      name: name.trim(),
      mission: mission.trim(),
      openingNote: openingNote?.trim(),
      creatorId: kLocalUserId,
      creatorName: creatorDisplayName,
      createdAt: now,
      goalType: goalType,
      goalTarget: goalTarget,
      originVisibility: visibility,
      originCity: visibility == LocationVisibility.city ? city : null,
      originCountry: visibility != LocationVisibility.hidden ? country : null,
    );
    final stop = JourneyStop(
      id: '$id-origin',
      objectId: id,
      participantId: kLocalUserId,
      displayName: await displayName(),
      message: openingNote?.trim(),
      locationVisibility: visibility,
      cityName: journey.originCity,
      countryName: journey.originCountry,
      lat: visibility == LocationVisibility.city ? lat : null,
      lng: visibility == LocationVisibility.city ? lng : null,
      createdAt: now,
      isOrigin: true,
    );
    await _save([journey, ..._journeys], [..._stops, stop]);
    return journey;
  }

  Future<void> follow(String id, bool followed) async {
    if (find(id) == null) throw StateError('Journey not found.');
    await _save(
      _journeys
          .map((j) => j.id == id ? j.copyWith(isFollowed: followed) : j)
          .toList(),
      _stops,
    );
  }

  Future<void> join(String id, {String? message}) async {
    final journey = find(id);
    if (journey == null || journey.state != JourneyState.active) {
      throw StateError('This journey is no longer active.');
    }
    if (_stops.any(
      (s) => s.objectId == id && s.participantId == kLocalUserId,
    )) {
      return;
    }
    final previous = _stops.where((s) => s.objectId == id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    await _save(_journeys, [
      ..._stops,
      JourneyStop(
        id: 'stop-${DateTime.now().microsecondsSinceEpoch}',
        objectId: id,
        parentStopId: previous.isEmpty ? null : previous.first.id,
        participantId: kLocalUserId,
        displayName: await displayName(),
        message: message?.trim(),
        locationVisibility: LocationVisibility.hidden,
        createdAt: DateTime.now(),
        isSampleData: journey.isSampleData,
      ),
    ]);
  }
}
