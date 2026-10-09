import 'dart:async';
import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import '../data/sample_data.dart';
import '../models/journey_models.dart';

class DiscoveryArea {
  final String city;
  final String country;
  final double latitude;
  final double longitude;
  final bool fromDevice;
  const DiscoveryArea(
    this.city,
    this.country,
    this.latitude,
    this.longitude, {
    this.fromDevice = false,
  });
  String get label => fromDevice ? 'Your current area' : city;
}

List<DiscoveryArea> get discoveryCities {
  final areas = <String, DiscoveryArea>{};
  for (final map in sampleStopMaps) {
    final stop = JourneyStop.fromMap(map);
    if (stop.locationVisibility == LocationVisibility.city &&
        stop.cityName != null &&
        stop.lat != null &&
        stop.lng != null) {
      areas['${stop.cityName},${stop.countryName}'] = DiscoveryArea(
        stop.cityName!,
        stop.countryName ?? '',
        stop.lat!,
        stop.lng!,
      );
    }
  }
  for (final area in const [
    DiscoveryArea('Bengaluru', 'India', 12.9716, 77.5946),
    DiscoveryArea('Hyderabad', 'India', 17.3850, 78.4867),
    DiscoveryArea('Chennai', 'India', 13.0827, 80.2707),
    DiscoveryArea('Pune', 'India', 18.5204, 73.8567),
    DiscoveryArea('Kolkata', 'India', 22.5726, 88.3639),
  ]) {
    areas['${area.city},${area.country}'] = area;
  }
  return areas.values.toList()..sort((a, b) => a.city.compareTo(b.city));
}

DiscoveryArea? cityArea(String? city, String? country) {
  for (final area in discoveryCities) {
    if (area.city.toLowerCase() == city?.trim().toLowerCase() &&
        area.country.toLowerCase() == country?.trim().toLowerCase()) {
      return area;
    }
  }
  return null;
}

double distanceKm(double lat1, double lng1, double lat2, double lng2) {
  const rad = math.pi / 180;
  final a =
      math.pow(math.sin((lat2 - lat1) * rad / 2), 2) +
      math.cos(lat1 * rad) *
          math.cos(lat2 * rad) *
          math.pow(math.sin((lng2 - lng1) * rad / 2), 2);
  return 6371 * 2 * math.asin(math.sqrt(a.clamp(0, 1)));
}

class NearbyJourney {
  final JourneyObject journey;
  final JourneyStop? latestStop;
  final double? distance;
  const NearbyJourney(this.journey, this.latestStop, this.distance);
}

/// Only the latest stop can locate an object. Never reveal an earlier public
/// stop after its current participant has chosen a hidden/country-only location.
List<NearbyJourney> discoverJourneys(
  List<JourneyObject> journeys,
  List<JourneyStop> stops, {
  DiscoveryArea? area,
  double radiusKm = 50,
  ObjectType? type,
}) {
  final result = <NearbyJourney>[];
  for (final journey in journeys) {
    if (journey.state != JourneyState.active ||
        (type != null && journey.type != type)) {
      continue;
    }
    final journeyStops = stops.where((s) => s.objectId == journey.id).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final latest = journeyStops.isEmpty ? null : journeyStops.first;
    double? distance;
    if (area != null) {
      if (latest == null ||
          latest.locationVisibility != LocationVisibility.city ||
          latest.lat == null ||
          latest.lng == null) {
        continue;
      }
      distance = distanceKm(
        area.latitude,
        area.longitude,
        latest.lat!,
        latest.lng!,
      );
      if (!distance.isFinite || distance > radiusKm) continue;
    }
    result.add(NearbyJourney(journey, latest, distance));
  }
  result.sort(
    (a, b) => area != null
        ? a.distance!.compareTo(b.distance!)
        : b.journey.createdAt.compareTo(a.journey.createdAt),
  );
  return result;
}

class NearbyLocationService {
  Future<DiscoveryArea> locate() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationIssue(
        'Location is switched off. Choose a city below or turn it on and try again.',
      );
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationIssue(
        'Location access wasn’t allowed. You can still choose a city below.',
      );
    }
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return DiscoveryArea(
        '',
        '',
        position.latitude,
        position.longitude,
        fromDevice: true,
      );
    } on TimeoutException {
      throw const LocationIssue(
        'Finding your area took too long. Try again or choose a city below.',
      );
    }
  }
}

class LocationIssue implements Exception {
  final String message;
  const LocationIssue(this.message);
}
