import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

final hapticsNotifier = ValueNotifier<bool>(true);

void selectionFeedback() {
  if (hapticsNotifier.value) HapticFeedback.selectionClick();
}

final reduceMotionNotifier = ValueNotifier<bool>(false);

Future<void> initMotionPreference() async {
  final prefs = await SharedPreferences.getInstance();
  hapticsNotifier.value = prefs.getBool('haptics') ?? true;
  reduceMotionNotifier.value = prefs.getBool('reduce_motion') ?? false;
}
