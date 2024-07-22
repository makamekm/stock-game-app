import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_game_app/src/welcome/video_controller.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  }

  final settingsController = SettingsController(SettingsService());
  await settingsController.loadSettings();

  GetIt.instance.registerSingleton<SettingsController>(settingsController);
  GetIt.instance.registerSingleton<VideoController>(VideoController());

  GetIt.instance.get<VideoController>().portrait();

  runApp(MyApp(
    settingsController: settingsController,
  ));
}
