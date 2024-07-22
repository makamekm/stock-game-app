import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_game_app/src/push_button/pushable_button.dart';
import 'package:stock_game_app/src/welcome/main_video_player.dart';
import 'package:stock_game_app/src/welcome/video_controller.dart';

class MainVideoScreenMin extends HookWidget {
  final bool visible;

  MainVideoScreenMin({
    super.key,
    required this.visible,
  });

  final getIt = GetIt.instance;

  final aspect = 1.778;
  final contHeight = 48.0;
  final height = 48.0 + 16;
  final animationDuration = const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final controler = getIt<VideoController>();
    final mainVideoControllerStream = useStream(controler.mainVideoController);
    useStream(controler.mainVideoControllerCounter);

    isPlayingGet() => mainVideoControllerStream.data?.value.isPlaying == true;
    final isPlaying = isPlayingGet();

    open() {
      controler.isOpened.add(true);
      HapticFeedback.lightImpact();
    }

    close() {
      controler.isOpened.add(false);
      HapticFeedback.lightImpact();
    }

    stop() {
      controler.stopMainController();
    }

    return Container(
      padding: const EdgeInsets.only(right: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          SizedBox(
            width: height * aspect,
            child: MainVideoPlayer(visible: visible),
          ),
          const SizedBox(width: 8),
          PushableButton(
            height: contHeight,
            width: contHeight,
            // disabled: true,
            hslColor: HSLColor.fromColor(Colors.black),
            bottomHslColor: HSLColor.fromColor(Colors.black),
            bottomHslColorBottom: HSLColor.fromColor(Colors.black),
            topHslColor: HSLColor.fromColor(Colors.black),
            patternOpacity: 0.3,
            onPressed: () => print('Button Pressed!'),
            child: const Icon(
              Icons.thumb_down_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          PushableButton(
            height: contHeight,
            width: contHeight,
            hslColor: HSLColor.fromColor(Colors.black),
            bottomHslColor: HSLColor.fromColor(Colors.black),
            bottomHslColorBottom: HSLColor.fromColor(Colors.black),
            topHslColor: HSLColor.fromColor(Colors.black),
            patternOpacity: 0.3,
            onPressed: () => print('Button Pressed!'),
            child: const Icon(
              Icons.thumb_up_rounded,
              color: Colors.white,
            ),
          ),
          const Expanded(
            child: SizedBox(width: 4),
          ),
          PushableButton(
            height: contHeight,
            width: contHeight,
            hslColor: HSLColor.fromColor(Colors.black),
            bottomHslColor: HSLColor.fromColor(Colors.black),
            bottomHslColorBottom: HSLColor.fromColor(Colors.black),
            topHslColor: HSLColor.fromColor(Colors.black),
            patternOpacity: 0.2,
            onPressed: () {
              open();
            },
            child: const Icon(
              Icons.fullscreen_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          PushableButton(
            height: contHeight,
            width: contHeight,
            hslColor: HSLColor.fromColor(Colors.deepOrange).withAlpha(0.6),
            onPressed: () {
              close();
              stop();
            },
            child: const Icon(
              Icons.stop_rounded,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          PushableButton(
            height: contHeight,
            width: contHeight,
            hslColor: HSLColor.fromColor(Colors.blue).withAlpha(0.6),
            onPressed: () {
              controler.toggleMainController();
            },
            child: Icon(
              isPlaying ? Icons.play_arrow_rounded : Icons.pause_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
