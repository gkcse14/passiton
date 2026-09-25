import '../models/journey_models.dart';

const String kLocalUserId = 'local-user-001';
const String kLocalUserName = 'You';

final List<Map<String, dynamic>> sampleJourneyMaps = [
  {
    'id': 'journey-001',
    'type': 'potato',
    'name': 'The Internet Potato',
    'mission': 'Help me visit 20 countries.',
    'openingNote':
        'I started life in a cozy kitchen in Delhi. Now I want to see the world.',
    'creatorId': kLocalUserId,
    'creatorName': 'You',
    'createdAt': '2026-07-15T09:00:00.000Z',
    'goalType': 'countries',
    'goalTarget': 20,
    'originVisibility': 'city',
    'originCity': 'Delhi',
    'originCountry': 'India',
    'state': 'active',
    'isSampleData': false,
    'isFollowed': false,
  },
  {
    'id': 'journey-002',
    'type': 'heart',
    'name': 'A Little Kindness',
    'mission': 'Leave a kind word for the next person.',
    'openingNote': 'Pass this along with a warm thought.',
    'creatorId': 'user-amara',
    'creatorName': 'Amara Osei',
    'createdAt': '2026-08-01T14:30:00.000Z',
    'goalType': 'people',
    'goalTarget': 50,
    'originVisibility': 'city',
    'originCity': 'Accra',
    'originCountry': 'Ghana',
    'state': 'active',
    'isSampleData': true,
    'isFollowed': true,
  },
  {
    'id': 'journey-003',
    'type': 'star',
    'name': 'The Wandering Star',
    'mission': 'Find a night sky that takes your breath away.',
    'openingNote': null,
    'creatorId': 'user-kenji',
    'creatorName': 'Kenji Watanabe',
    'createdAt': '2026-06-10T20:00:00.000Z',
    'goalType': 'none',
    'goalTarget': null,
    'originVisibility': 'city',
    'originCity': 'Kyoto',
    'originCountry': 'Japan',
    'state': 'active',
    'isSampleData': true,
    'isFollowed': false,
  },
  {
    'id': 'journey-004',
    'type': 'paperPlane',
    'name': 'One Brave Paper Plane',
    'mission': 'Fold me and send me somewhere new.',
    'openingNote': 'Every fold is a fresh start.',
    'creatorId': 'user-sofia',
    'creatorName': 'Sofia Mendez',
    'createdAt': '2026-05-20T11:15:00.000Z',
    'goalType': 'countries',
    'goalTarget': 15,
    'originVisibility': 'city',
    'originCity': 'Buenos Aires',
    'originCountry': 'Argentina',
    'state': 'active',
    'isSampleData': true,
    'isFollowed': false,
  },
  {
    'id': 'journey-005',
    'type': 'seedling',
    'name': 'Seeds of Hope',
    'mission': 'Plant a small act of hope wherever you are.',
    'openingNote': null,
    'creatorId': 'user-priya',
    'creatorName': 'Priya Nair',
    'createdAt': '2026-09-01T08:00:00.000Z',
    'goalType': 'people',
    'goalTarget': 30,
    'originVisibility': 'city',
    'originCity': 'Mumbai',
    'originCountry': 'India',
    'state': 'active',
    'isSampleData': true,
    'isFollowed': false,
  },
  {
    'id': 'journey-006',
    'type': 'lotus',
    'name': 'The Quiet Lotus',
    'mission': 'Carry a moment of stillness to someone who needs it.',
    'openingNote': 'Breathe in. Pass it on.',
    'creatorId': 'user-lin',
    'creatorName': 'Lin Xiaomei',
    'createdAt': '2026-07-25T07:00:00.000Z',
    'goalType': 'none',
    'goalTarget': null,
    'originVisibility': 'city',
    'originCity': 'Chengdu',
    'originCountry': 'China',
    'state': 'active',
    'isSampleData': true,
    'isFollowed': false,
  },
];

final List<Map<String, dynamic>> sampleStopMaps = [
  // Journey 001 — The Internet Potato
  {
    'id': 'stop-001-origin',
    'objectId': 'journey-001',
    'parentStopId': null,
    'participantId': kLocalUserId,
    'displayName': 'You',
    'message': 'I started this little potato in Delhi. Where will it end up?',
    'locationVisibility': 'city',
    'cityName': 'Delhi',
    'countryName': 'India',
    'countryCode': 'IN',
    'lat': 28.6139,
    'lng': 77.2090,
    'createdAt': '2026-07-15T09:00:00.000Z',
    'isOrigin': true,
    'isSampleData': false,
  },
  {
    'id': 'stop-001-maya',
    'objectId': 'journey-001',
    'parentStopId': 'stop-001-origin',
    'participantId': 'user-maya',
    'displayName': 'Maya Al-Hassan',
    'message': 'Received this in Dubai! Passing it to someone in Singapore.',
    'locationVisibility': 'city',
    'cityName': 'Dubai',
    'countryName': 'UAE',
    'countryCode': 'AE',
    'lat': 25.2048,
    'lng': 55.2708,
    'createdAt': '2026-07-22T14:30:00.000Z',
    'isOrigin': false,
    'isSampleData': true,
  },
  {
    'id': 'stop-001-alex',
    'objectId': 'journey-001',
    'parentStopId': 'stop-001-origin',
    'participantId': 'user-alex',
    'displayName': 'Alex Thornton',
    'message': 'A potato in London! Brilliant. Sending it onward.',
    'locationVisibility': 'city',
    'cityName': 'London',
    'countryName': 'UK',
    'countryCode': 'GB',
    'lat': 51.5074,
    'lng': -0.1278,
    'createdAt': '2026-07-23T09:00:00.000Z',
    'isOrigin': false,
    'isSampleData': true,
  },
  {
    'id': 'stop-001-sam',
    'objectId': 'journey-001',
    'parentStopId': 'stop-001-maya',
    'participantId': 'user-sam',
    'displayName': 'Sam Tan',
    'message':
        'All the way from Dubai to Singapore! The potato is well-travelled.',
    'locationVisibility': 'city',
    'cityName': 'Singapore',
    'countryName': 'Singapore',
    'countryCode': 'SG',
    'lat': 1.3521,
    'lng': 103.8198,
    'createdAt': '2026-08-01T11:00:00.000Z',
    'isOrigin': false,
    'isSampleData': true,
  },
  {
    'id': 'stop-001-hidden',
    'objectId': 'journey-001',
    'parentStopId': 'stop-001-alex',
    'participantId': 'user-anon',
    'displayName': 'Anonymous',
    'message': 'Keeping my location a mystery, but I love this potato!',
    'locationVisibility': 'hidden',
    'cityName': null,
    'countryName': null,
    'countryCode': null,
    'lat': null,
    'lng': null,
    'createdAt': '2026-08-05T16:00:00.000Z',
    'isOrigin': false,
    'isSampleData': true,
  },
  // Journey 002 — A Little Kindness
  {
    'id': 'stop-002-origin',
    'objectId': 'journey-002',
    'parentStopId': null,
    'participantId': 'user-amara',
    'displayName': 'Amara Osei',
    'message': 'Starting this heart in Accra with all the warmth I have.',
    'locationVisibility': 'city',
    'cityName': 'Accra',
    'countryName': 'Ghana',
    'countryCode': 'GH',
    'lat': 5.6037,
    'lng': -0.1870,
    'createdAt': '2026-08-01T14:30:00.000Z',
    'isOrigin': true,
    'isSampleData': true,
  },
  {
    'id': 'stop-002-b',
    'objectId': 'journey-002',
    'parentStopId': 'stop-002-origin',
    'participantId': 'user-fatima',
    'displayName': 'Fatima Zahra',
    'message': 'Sending kindness from Casablanca!',
    'locationVisibility': 'city',
    'cityName': 'Casablanca',
    'countryName': 'Morocco',
    'countryCode': 'MA',
    'lat': 33.5731,
    'lng': -7.5898,
    'createdAt': '2026-08-10T10:00:00.000Z',
    'isOrigin': false,
    'isSampleData': true,
  },
  {
    'id': 'stop-002-c',
    'objectId': 'journey-002',
    'parentStopId': 'stop-002-b',
    'participantId': 'user-lena',
    'displayName': 'Lena Bergström',
    'message': 'From Morocco to Stockholm — kindness travels far.',
    'locationVisibility': 'city',
    'cityName': 'Stockholm',
    'countryName': 'Sweden',
    'countryCode': 'SE',
    'lat': 59.3293,
    'lng': 18.0686,
    'createdAt': '2026-08-18T16:00:00.000Z',
    'isOrigin': false,
    'isSampleData': true,
  },
  // Journey 003 — The Wandering Star
  {
    'id': 'stop-003-origin',
    'objectId': 'journey-003',
    'parentStopId': null,
    'participantId': 'user-kenji',
    'displayName': 'Kenji Watanabe',
    'message': 'From the bamboo forests of Kyoto, a star sets out.',
    'locationVisibility': 'city',
    'cityName': 'Kyoto',
    'countryName': 'Japan',
    'countryCode': 'JP',
    'lat': 35.0116,
    'lng': 135.7681,
    'createdAt': '2026-06-10T20:00:00.000Z',
    'isOrigin': true,
    'isSampleData': true,
  },
  {
    'id': 'stop-003-b',
    'objectId': 'journey-003',
    'parentStopId': 'stop-003-origin',
    'participantId': 'user-ravi',
    'displayName': 'Ravi Shankar',
    'message': 'Watching stars from Chennai tonight.',
    'locationVisibility': 'city',
    'cityName': 'Chennai',
    'countryName': 'India',
    'countryCode': 'IN',
    'lat': 13.0827,
    'lng': 80.2707,
    'createdAt': '2026-06-25T21:00:00.000Z',
    'isOrigin': false,
    'isSampleData': true,
  },
  {
    'id': 'stop-003-c',
    'objectId': 'journey-003',
    'parentStopId': 'stop-003-b',
    'participantId': 'user-yuki',
    'displayName': 'Yuki Nakamura',
    'message': 'The Milky Way from the Australian outback. Breathtaking.',
    'locationVisibility': 'countryOnly',
    'cityName': null,
    'countryName': 'Australia',
    'countryCode': 'AU',
    'lat': null,
    'lng': null,
    'createdAt': '2026-07-10T22:00:00.000Z',
    'isOrigin': false,
    'isSampleData': true,
  },
];

final List<Map<String, dynamic>> sampleActivityMaps = [
  {
    'id': 'act-001',
    'objectId': 'journey-001',
    'title': 'Sam joined your potato\'s journey',
    'subtitle': 'The Internet Potato reached Singapore',
    'objectType': 'potato',
    'createdAt': '2026-08-01T11:00:00.000Z',
    'isRead': false,
    'stopId': 'stop-001-sam',
  },
  {
    'id': 'act-002',
    'objectId': 'journey-001',
    'title': 'Your journey reached 5 stops',
    'subtitle': 'The Internet Potato is growing!',
    'objectType': 'potato',
    'createdAt': '2026-08-05T16:00:00.000Z',
    'isRead': false,
    'stopId': null,
  },
  {
    'id': 'act-003',
    'objectId': 'journey-002',
    'title': 'A Little Kindness reached Europe',
    'subtitle': 'Lena joined from Stockholm, Sweden',
    'objectType': 'heart',
    'createdAt': '2026-08-18T16:00:00.000Z',
    'isRead': true,
    'stopId': 'stop-002-c',
  },
  {
    'id': 'act-004',
    'objectId': 'journey-003',
    'title': 'The Wandering Star reached a new country',
    'subtitle': 'Now visiting Australia',
    'objectType': 'star',
    'createdAt': '2026-07-10T22:00:00.000Z',
    'isRead': true,
    'stopId': 'stop-003-c',
  },
];

// Compute stats from stops
JourneyStats computeStats(String journeyId, List<JourneyStop> stops) {
  final journeyStops = stops.where((s) => s.objectId == journeyId).toList();
  final uniquePeople = journeyStops.map((s) => s.participantId).toSet().length;
  final cities = journeyStops
      .where(
        (s) =>
            s.locationVisibility == LocationVisibility.city &&
            s.cityName != null,
      )
      .map((s) => '${s.cityName}-${s.countryCode}')
      .toSet()
      .length;
  final countries = journeyStops
      .where(
        (s) =>
            s.locationVisibility != LocationVisibility.hidden &&
            s.countryCode != null,
      )
      .map((s) => s.countryCode!)
      .toSet()
      .length;

  double totalKm = 0;
  for (final stop in journeyStops) {
    if (stop.parentStopId == null) continue;
    final parent = journeyStops.firstWhere(
      (s) => s.id == stop.parentStopId,
      orElse: () => stop,
    );
    if (stop.lat != null &&
        stop.lng != null &&
        parent.lat != null &&
        parent.lng != null) {
      totalKm += _haversineKm(parent.lat!, parent.lng!, stop.lat!, stop.lng!);
    }
  }

  return JourneyStats(
    people: uniquePeople,
    countries: countries,
    cities: cities,
    estimatedKm: totalKm > 0 ? totalKm : null,
  );
}

double _haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  final dLat = _toRad(lat2 - lat1);
  final dLng = _toRad(lng2 - lng1);
  final a =
      _sin2(dLat / 2) +
      _cos(_toRad(lat1)) * _cos(_toRad(lat2)) * _sin2(dLng / 2);
  final c = 2 * _asin(_sqrt(a));
  return r * c;
}

double _toRad(double d) => d * 3.141592653589793 / 180;
double _sin2(double x) => _sin(x) * _sin(x);
double _sin(double x) => x - x * x * x / 6 + x * x * x * x * x / 120;
double _cos(double x) => 1 - x * x / 2 + x * x * x * x / 24;
double _asin(double x) => x + x * x * x / 6;
double _sqrt(double x) {
  if (x <= 0) return 0;
  double z = x;
  for (int i = 0; i < 20; i++) {
    z = (z + x / z) / 2;
  }
  return z;
}
