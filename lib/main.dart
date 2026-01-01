import 'package:flutter/cupertino.dart';
import 'package:munch_nearby/app/app.dart';

import 'core/services/hive/hive_service.dart';

Future<void> main() async {
  await HiveService().init();
  runApp(App());
}