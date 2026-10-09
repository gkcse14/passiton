import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:passiton/core/data/sample_data.dart';
import 'package:passiton/core/models/journey_models.dart';
import 'package:passiton/core/repositories/journey_repository.dart';
import 'package:passiton/core/services/nearby_journeys.dart';

JourneyObject journey(
  String id, {
  JourneyState state = JourneyState.active,
  ObjectType type = ObjectType.potato,
}) => JourneyObject(
  id: id,
  type: type,
  name: id,
  mission: 'A little adventure',
  creatorId: 'another-user',
  creatorName: 'Another traveller',
  createdAt: DateTime(2026, 1),
  state: state,
);

JourneyStop stop(
  String id,
  double lat, {
  int day = 1,
  LocationVisibility visibility = LocationVisibility.city,
}) => JourneyStop(
  id: '$id-$day',
  objectId: id,
  participantId: 'another-user',
  displayName: 'Traveller',
  locationVisibility: visibility,
  lat: lat,
  lng: 0,
  createdAt: DateTime(2026, 1, day),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test(
    'nearby ranks current public locations and respects radius and object filter',
    () {
      final objects = [
        journey('further'),
        journey('close', type: ObjectType.heart),
        journey('far-away'),
      ];
      final stops = [
        stop('further', .2),
        stop('close', .05),
        stop('far-away', 2),
      ];
      const area = DiscoveryArea('Origin', '', 0, 0);
      final results = discoverJourneys(
        objects,
        stops,
        area: area,
        radiusKm: 50,
      );
      expect(results.map((r) => r.journey.id), ['close', 'further']);
      expect(results.first.distance, closeTo(5.56, .1));
      expect(
        discoverJourneys(
          objects,
          stops,
          area: area,
          type: ObjectType.heart,
        ).single.journey.id,
        'close',
      );
      expect(distanceKm(0, 0, 0, 0), 0);
    },
  );

  test('hidden latest stop never falls back to an older public location', () {
    final objects = [
      journey('hidden'),
      journey('country'),
      journey('archived', state: JourneyState.archived),
      journey('missing'),
    ];
    final stops = [
      stop('hidden', 0),
      stop('hidden', 0, day: 2, visibility: LocationVisibility.hidden),
      stop('country', 0, visibility: LocationVisibility.countryOnly),
      stop('archived', 0),
    ];
    expect(
      discoverJourneys(objects, stops, area: const DiscoveryArea('', '', 0, 0)),
      isEmpty,
    );
    expect(discoverJourneys(objects, stops).length, 3);
  });

  test(
    'created journey, origin, and saved state survive a repository reload',
    () async {
      final repo = JourneyRepository(seed: false);
      await repo.init();
      final created = await repo.create(
        type: ObjectType.seedling,
        name: '  Little Hope  ',
        mission: '  Help kindness grow  ',
        openingNote: 'First chapter',
        visibility: LocationVisibility.city,
        city: 'Mumbai',
        country: 'India',
        lat: 19.076,
        lng: 72.8777,
      );
      await repo.follow(created.id, true);
      final restored = JourneyRepository(seed: false);
      await restored.init();
      expect(restored.find(created.id)!.name, 'Little Hope');
      expect(restored.find(created.id)!.isFollowed, isTrue);
      expect(restored.find(created.id)!.isSampleData, isFalse);
      expect(restored.stops.single.isOrigin, isTrue);
      expect(restored.stops.single.lat, 19.076);
      expect(
        discoverJourneys(
          restored.journeys,
          restored.stops,
          area: const DiscoveryArea('Mumbai', 'India', 19.076, 72.8777),
        ).single.journey.id,
        created.id,
      );
    },
  );

  test(
    'joining is idempotent and does not publish a device location',
    () async {
      final repo = JourneyRepository();
      await repo.init();
      final target = repo.journeys.firstWhere(
        (j) => !repo.stops.any(
          (s) => s.objectId == j.id && s.participantId == kLocalUserId,
        ),
      );
      await repo.join(target.id, message: 'Wishing you a wonderful next stop');
      await repo.join(target.id, message: 'Second click');
      final mine = repo.stops
          .where(
            (s) => s.objectId == target.id && s.participantId == kLocalUserId,
          )
          .single;
      expect(mine.message, 'Wishing you a wonderful next stop');
      expect(mine.locationVisibility, LocationVisibility.hidden);
      expect(mine.lat, isNull);
      expect(mine.lng, isNull);
      expect(repo.journeys.every((j) => j.isSampleData), isTrue);
      final restored = JourneyRepository();
      await restored.init();
      expect(restored.stops.where((s) => s.id == mine.id).length, 1);
    },
  );

  test(
    'hidden origins discard coordinates and archived journeys cannot be joined',
    () async {
      final repo = JourneyRepository(seed: false);
      await repo.init();
      final created = await repo.create(
        type: ObjectType.lotus,
        name: 'Quiet Lotus',
        mission: 'Carry a quiet moment',
        visibility: LocationVisibility.hidden,
        city: 'Delhi',
        country: 'India',
        lat: 28.6,
        lng: 77.2,
      );
      expect(repo.stops.single.lat, isNull);
      expect(repo.stops.single.cityName, isNull);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        JourneyRepository.storageKey,
        jsonEncode({
          'journeys': [created.copyWith(state: JourneyState.archived).toMap()],
          'stops': [],
        }),
      );
      final archived = JourneyRepository(seed: false);
      await archived.init();
      await expectLater(archived.join(created.id), throwsStateError);
    },
  );
}
