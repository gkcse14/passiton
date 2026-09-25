import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

enum ObjectType { potato, heart, lotus, paperPlane, star, seedling }

enum JourneyState { active, archived }

enum LocationVisibility { city, countryOnly, hidden }

enum GoalType { none, people, countries }

extension ObjectTypeExt on ObjectType {
  String get displayName {
    switch (this) {
      case ObjectType.potato:
        return 'Potato';
      case ObjectType.heart:
        return 'Heart';
      case ObjectType.lotus:
        return 'Lotus';
      case ObjectType.paperPlane:
        return 'Paper Plane';
      case ObjectType.star:
        return 'Star';
      case ObjectType.seedling:
        return 'Seedling';
    }
  }

  String get personality {
    switch (this) {
      case ObjectType.potato:
        return 'Here for the adventure.';
      case ObjectType.heart:
        return 'A little love goes a long way.';
      case ObjectType.lotus:
        return 'Peace in every petal.';
      case ObjectType.paperPlane:
        return 'Made to go places.';
      case ObjectType.star:
        return 'Shine wherever you land.';
      case ObjectType.seedling:
        return 'Small start, big story.';
    }
  }

  Color get accentColor {
    switch (this) {
      case ObjectType.potato:
        return AppTheme.potatoAccent;
      case ObjectType.heart:
        return AppTheme.heartAccent;
      case ObjectType.lotus:
        return AppTheme.lotusAccent;
      case ObjectType.paperPlane:
        return AppTheme.paperPlaneAccent;
      case ObjectType.star:
        return AppTheme.starAccent;
      case ObjectType.seedling:
        return AppTheme.seedlingAccent;
    }
  }

  String get emoji {
    switch (this) {
      case ObjectType.potato:
        return '🥔';
      case ObjectType.heart:
        return '💛';
      case ObjectType.lotus:
        return '🪷';
      case ObjectType.paperPlane:
        return '✈️';
      case ObjectType.star:
        return '⭐';
      case ObjectType.seedling:
        return '🌱';
    }
  }
}

class ObjectTemplate {
  final ObjectType type;
  final String name;
  final String personality;
  final List<String> missionSuggestions;
  final List<String> nameSuggestions;

  const ObjectTemplate({
    required this.type,
    required this.name,
    required this.personality,
    required this.missionSuggestions,
    required this.nameSuggestions,
  });
}

class JourneyStop {
  final String id;
  final String objectId;
  final String? parentStopId;
  final String participantId;
  final String displayName;
  final String? message;
  final LocationVisibility locationVisibility;
  final String? cityName;
  final String? countryName;
  final String? countryCode;
  final double? lat;
  final double? lng;
  final DateTime createdAt;
  final bool isOrigin;
  final bool isSampleData;

  const JourneyStop({
    required this.id,
    required this.objectId,
    this.parentStopId,
    required this.participantId,
    required this.displayName,
    this.message,
    required this.locationVisibility,
    this.cityName,
    this.countryName,
    this.countryCode,
    this.lat,
    this.lng,
    required this.createdAt,
    this.isOrigin = false,
    this.isSampleData = false,
  });

  factory JourneyStop.fromMap(Map<String, dynamic> map) {
    return JourneyStop(
      id: map['id'] as String,
      objectId: map['objectId'] as String,
      parentStopId: map['parentStopId'] as String?,
      participantId: map['participantId'] as String,
      displayName: map['displayName'] as String,
      message: map['message'] as String?,
      locationVisibility: _locationVisibilityFromString(
        map['locationVisibility'] as String,
      ),
      cityName: map['cityName'] as String?,
      countryName: map['countryName'] as String?,
      countryCode: map['countryCode'] as String?,
      lat: (map['lat'] as num?)?.toDouble(),
      lng: (map['lng'] as num?)?.toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isOrigin: map['isOrigin'] as bool? ?? false,
      isSampleData: map['isSampleData'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'objectId': objectId,
    'parentStopId': parentStopId,
    'participantId': participantId,
    'displayName': displayName,
    'message': message,
    'locationVisibility': locationVisibility.name,
    'cityName': cityName,
    'countryName': countryName,
    'countryCode': countryCode,
    'lat': lat,
    'lng': lng,
    'createdAt': createdAt.toIso8601String(),
    'isOrigin': isOrigin,
    'isSampleData': isSampleData,
  };

  static LocationVisibility _locationVisibilityFromString(String v) {
    switch (v) {
      case 'city':
        return LocationVisibility.city;
      case 'countryOnly':
        return LocationVisibility.countryOnly;
      case 'hidden':
        return LocationVisibility.hidden;
      default:
        return LocationVisibility.hidden;
    }
  }

  String get displayLocation {
    switch (locationVisibility) {
      case LocationVisibility.city:
        return [cityName, countryName].where((e) => e != null).join(', ');
      case LocationVisibility.countryOnly:
        return countryName ?? '';
      case LocationVisibility.hidden:
        return 'Hidden location';
    }
  }
}

class JourneyObject {
  final String id;
  final ObjectType type;
  final String name;
  final String mission;
  final String? openingNote;
  final String creatorId;
  final String creatorName;
  final DateTime createdAt;
  final GoalType goalType;
  final int? goalTarget;
  final LocationVisibility originVisibility;
  final String? originCity;
  final String? originCountry;
  final JourneyState state;
  final bool isSampleData;
  final bool isFollowed;

  const JourneyObject({
    required this.id,
    required this.type,
    required this.name,
    required this.mission,
    this.openingNote,
    required this.creatorId,
    required this.creatorName,
    required this.createdAt,
    this.goalType = GoalType.none,
    this.goalTarget,
    this.originVisibility = LocationVisibility.city,
    this.originCity,
    this.originCountry,
    this.state = JourneyState.active,
    this.isSampleData = false,
    this.isFollowed = false,
  });

  factory JourneyObject.fromMap(Map<String, dynamic> map) {
    return JourneyObject(
      id: map['id'] as String,
      type: _objectTypeFromString(map['type'] as String),
      name: map['name'] as String,
      mission: map['mission'] as String,
      openingNote: map['openingNote'] as String?,
      creatorId: map['creatorId'] as String,
      creatorName: map['creatorName'] as String,
      createdAt: DateTime.parse(map['createdAt'] as String),
      goalType: _goalTypeFromString(map['goalType'] as String? ?? 'none'),
      goalTarget: map['goalTarget'] as int?,
      originVisibility: JourneyStop._locationVisibilityFromString(
        map['originVisibility'] as String? ?? 'city',
      ),
      originCity: map['originCity'] as String?,
      originCountry: map['originCountry'] as String?,
      state: map['state'] == 'archived'
          ? JourneyState.archived
          : JourneyState.active,
      isSampleData: map['isSampleData'] as bool? ?? false,
      isFollowed: map['isFollowed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'type': type.name,
    'name': name,
    'mission': mission,
    'openingNote': openingNote,
    'creatorId': creatorId,
    'creatorName': creatorName,
    'createdAt': createdAt.toIso8601String(),
    'goalType': goalType.name,
    'goalTarget': goalTarget,
    'originVisibility': originVisibility.name,
    'originCity': originCity,
    'originCountry': originCountry,
    'state': state.name,
    'isSampleData': isSampleData,
    'isFollowed': isFollowed,
  };

  JourneyObject copyWith({bool? isFollowed, JourneyState? state}) {
    return JourneyObject(
      id: id,
      type: type,
      name: name,
      mission: mission,
      openingNote: openingNote,
      creatorId: creatorId,
      creatorName: creatorName,
      createdAt: createdAt,
      goalType: goalType,
      goalTarget: goalTarget,
      originVisibility: originVisibility,
      originCity: originCity,
      originCountry: originCountry,
      state: state ?? this.state,
      isSampleData: isSampleData,
      isFollowed: isFollowed ?? this.isFollowed,
    );
  }

  static ObjectType _objectTypeFromString(String v) {
    switch (v) {
      case 'potato':
        return ObjectType.potato;
      case 'heart':
        return ObjectType.heart;
      case 'lotus':
        return ObjectType.lotus;
      case 'paperPlane':
        return ObjectType.paperPlane;
      case 'star':
        return ObjectType.star;
      case 'seedling':
        return ObjectType.seedling;
      default:
        return ObjectType.potato;
    }
  }

  static GoalType _goalTypeFromString(String v) {
    switch (v) {
      case 'people':
        return GoalType.people;
      case 'countries':
        return GoalType.countries;
      default:
        return GoalType.none;
    }
  }
}

class ActivityItem {
  final String id;
  final String objectId;
  final String title;
  final String subtitle;
  final ObjectType objectType;
  final DateTime createdAt;
  final bool isRead;
  final String? stopId;

  const ActivityItem({
    required this.id,
    required this.objectId,
    required this.title,
    required this.subtitle,
    required this.objectType,
    required this.createdAt,
    this.isRead = false,
    this.stopId,
  });

  factory ActivityItem.fromMap(Map<String, dynamic> map) {
    return ActivityItem(
      id: map['id'] as String,
      objectId: map['objectId'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      objectType: JourneyObject._objectTypeFromString(
        map['objectType'] as String,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      isRead: map['isRead'] as bool? ?? false,
      stopId: map['stopId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'objectId': objectId,
    'title': title,
    'subtitle': subtitle,
    'objectType': objectType.name,
    'createdAt': createdAt.toIso8601String(),
    'isRead': isRead,
    'stopId': stopId,
  };

  ActivityItem copyWith({bool? isRead}) => ActivityItem(
    id: id,
    objectId: objectId,
    title: title,
    subtitle: subtitle,
    objectType: objectType,
    createdAt: createdAt,
    isRead: isRead ?? this.isRead,
    stopId: stopId,
  );
}

// Statistics derived from stops
class JourneyStats {
  final int people;
  final int countries;
  final int cities;
  final double? estimatedKm;
  final int goalProgress;

  const JourneyStats({
    required this.people,
    required this.countries,
    required this.cities,
    this.estimatedKm,
    this.goalProgress = 0,
  });
}
