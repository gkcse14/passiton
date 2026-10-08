import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

final reduceMotionNotifier = ValueNotifier<bool>(false);

Future<void> initMotionPreference() async {
  final prefs = await SharedPreferences.getInstance();
  reduceMotionNotifier.value = prefs.getBool('reduce_motion') ?? false;
}
