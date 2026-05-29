import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/orpheus_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(OrpheusApp(prefs: prefs));
}
